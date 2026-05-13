import { useState, useEffect } from 'react';
import { storage } from '../firebase';
import { ref, uploadBytes, getDownloadURL } from 'firebase/storage';
import { FiPlus, FiTrash2, FiEdit2, FiShoppingBag, FiTag, FiImage, FiLink, FiUpload } from 'react-icons/fi';
import { API_BASE_URL } from '../config';

function Modal({ title, onClose, onSave, loading, children }) {
  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal" style={{ maxWidth: 650 }}>
        <div className="modal-header">
          <h3>{title}</h3>
          <button className="btn-close" onClick={onClose}>✕</button>
        </div>
        <div className="modal-body">{children}</div>
        <div className="modal-footer">
          <button className="btn btn-outline" onClick={onClose}>Cancel</button>
          <button className="btn btn-primary" onClick={onSave} disabled={loading}>
            {loading ? 'Saving...' : 'Save Product'}
          </button>
        </div>
      </div>
    </div>
  );
}

const CATEGORIES = ['Books', 'Clothing', 'Music', 'Accessories', 'Food', 'Glassware', 'Gifting', 'Other'];

export default function MarketplacePage() {
  const [products, setProducts] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ 
    name: '', title: '', seller: '', cost_price: '', selling_price: '', 
    category: 'Other', description: '', stock: '', image_url: '', 
    image_source: 'url' // 'url' or 'file'
  });
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 10;

  useEffect(() => {
    fetchProducts();
  }, []);

  const fetchProducts = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/products`);
      const data = await res.json();
      setProducts(data);
    } catch (err) {
      console.error('Error fetching products:', err);
    }
  };

  const openNew = () => { 
    setEditing(null); 
    setForm({ 
      name: '', title: '', seller: '', cost_price: '', selling_price: '', 
      category: 'Other', description: '', stock: '0', image_url: '', image_source: 'url' 
    }); 
    setShowModal(true); 
  };

  const openEdit = (p) => { 
    setEditing(p); 
    setForm({ 
      name: p.product_name, title: p.product_title || '', seller: p.seller_name || '', 
      cost_price: p.cost_price || '', selling_price: p.selling_price || '', 
      category: p.category || 'Other', description: p.product_description || '', 
      stock: p.stock_quantity || '0', image_url: p.image_url || '', image_source: 'url' 
    }); 
    setShowModal(true); 
  };

  const compressAndUpload = async (file) => {
    setUploading(true);
    try {
      const blob = await new Promise((resolve) => {
        const reader = new FileReader();
        reader.readAsDataURL(file);
        reader.onload = (e) => {
          const img = new Image();
          img.src = e.target.result;
          img.onload = () => {
            const canvas = document.createElement('canvas');
            const MAX_WIDTH = 600; // Lower res
            const scaleSize = MAX_WIDTH / img.width;
            canvas.width = MAX_WIDTH;
            canvas.height = img.height * scaleSize;
            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0, canvas.width, canvas.height);
            canvas.toBlob((b) => resolve(b), 'image/jpeg', 0.6); // 60% quality
          };
        };
      });

      const fileName = `products/${Date.now()}-${file.name}`;
      const storageRef = ref(storage, fileName);
      await uploadBytes(storageRef, blob);
      const url = await getDownloadURL(storageRef);
      setForm(f => ({ ...f, image_url: url }));
    } catch (err) {
      console.error('Upload failed:', err);
      alert('Image upload failed');
    } finally {
      setUploading(false);
    }
  };

  const save = async () => {
    console.log('Attempting to save product...', form);
    if (!form.name) {
      alert('Product Name is required');
      return;
    }
    if (form.selling_price === '' || form.selling_price === null) {
      alert('Selling Price is required');
      return;
    }
    
    setLoading(true);
    try {
      const url = editing 
        ? `${API_BASE_URL}/products/${editing.product_id}` 
        : `${API_BASE_URL}/products`;
      
      const method = editing ? 'PUT' : 'POST';
      const payload = {
        name: form.name,
        title: form.title,
        seller: form.seller,
        cost_price: Number(form.cost_price) || 0,
        selling_price: Number(form.selling_price) || 0,
        description: form.description,
        category: form.category,
        stock: Number(form.stock) || 0,
        image_url: form.image_url
      };

      console.log(`Sending ${method} to ${url}`, payload);

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });

      if (res.ok) {
        console.log('Save successful');
        await fetchProducts();
        setShowModal(false);
      } else {
        const errorText = await res.text();
        console.error('Save failed:', errorText);
        let errorMessage = 'Unknown error';
        try {
          const errorData = JSON.parse(errorText);
          errorMessage = errorData.error || errorMessage;
        } catch (e) {
          errorMessage = errorText.substring(0, 100);
        }
        alert(`Failed to save: ${errorMessage}`);
      }
    } catch (err) {
      console.error('Error saving product:', err);
      alert(`Connection error: ${err.message}. Target: ${API_BASE_URL}`);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (!confirm('Delete this product?')) return;
    try {
      const res = await fetch(`${API_BASE_URL}/products/${id}`, { method: 'DELETE' });
      if (res.ok) fetchProducts();
    } catch (err) {
      console.error('Error deleting product:', err);
    }
  };

  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentItems = products.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(products.length / itemsPerPage);

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Marketplace</h1>
          <p>Manage products available in the church store</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}><FiPlus /> Add Product</button>
      </div>

      <div className="card">
        {products.length === 0 ? (
          <div className="empty-state">
            <FiShoppingBag />
            <h3>No products</h3>
            <p>Add products to the church marketplace</p>
          </div>
        ) : (
          <>
            <div className="table-container">
              <table>
                <thead>
                  <tr><th>Product</th><th>Seller</th><th>Price</th><th>Stock</th><th>Actions</th></tr>
                </thead>
                <tbody>
                  {currentItems.map(p => (
                    <tr key={p.product_id}>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                          <div style={{ width: 44, height: 44, background: '#f5f5f5', borderRadius: 8, overflow: 'hidden', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                            {p.image_url ? (
                              <img src={p.image_url} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                            ) : (
                              <FiTag size={18} style={{ color: 'var(--text-secondary)' }} />
                            )}
                          </div>
                          <div>
                            <strong>{p.product_name}</strong>
                            <div style={{ fontSize: 11, color: 'var(--text-secondary)' }}>{p.category}</div>
                          </div>
                        </div>
                      </td>
                      <td>{p.seller_name || '—'}</td>
                      <td>
                        <div style={{ fontWeight: 700, color: 'var(--maroon)' }}>R {Number(p.selling_price).toFixed(2)}</div>
                        <div style={{ fontSize: 10, color: 'var(--text-secondary)' }}>Cost: R {Number(p.cost_price).toFixed(2)}</div>
                      </td>
                      <td>
                        <span className={`badge ${p.stock_quantity > 0 ? 'badge-success' : 'badge-danger'}`}>
                          {p.stock_quantity > 0 ? `${p.stock_quantity} in stock` : 'Out of stock'}
                        </span>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: 6 }}>
                          <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(p)}><FiEdit2 size={14} /></button>
                          <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(p.product_id)}><FiTrash2 size={14} /></button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            
            {totalPages > 1 && (
              <div className="pagination">
                <button className="btn btn-outline btn-sm" disabled={currentPage === 1} onClick={() => setCurrentPage(prev => prev - 1)}>Previous</button>
                <span className="pagination-info">Page {currentPage} of {totalPages}</span>
                <button className="btn btn-outline btn-sm" disabled={currentPage === totalPages} onClick={() => setCurrentPage(prev => prev + 1)}>Next</button>
              </div>
            )}
          </>
        )}
      </div>

      {showModal && (
        <Modal title={editing ? 'Edit Product' : 'New Product'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Product Name</label>
              <input className="form-control" placeholder="e.g. Hymn Book" value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Internal Title</label>
              <input className="form-control" placeholder="e.g. Bespoke 4pc Set" value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} />
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Seller / Vendor</label>
              <input className="form-control" placeholder="e.g. Xpressive Culture" value={form.seller} onChange={e => setForm(f => ({ ...f, seller: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Category</label>
              <select className="form-control" value={form.category} onChange={e => setForm(f => ({ ...f, category: e.target.value }))}>
                {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
              </select>
            </div>
          </div>

          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Cost Price (R)</label>
              <input type="number" className="form-control" placeholder="0.00" value={form.cost_price} onChange={e => setForm(f => ({ ...f, cost_price: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Selling Price (R)</label>
              <input type="number" className="form-control" placeholder="0.00" value={form.selling_price} onChange={e => setForm(f => ({ ...f, selling_price: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Stock</label>
              <input type="number" className="form-control" placeholder="0" value={form.stock} onChange={e => setForm(f => ({ ...f, stock: e.target.value }))} />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Image Source</label>
            <div style={{ display: 'flex', gap: 12, marginBottom: 8 }}>
              <button className={`btn btn-sm ${form.image_source === 'url' ? 'btn-primary' : 'btn-outline'}`} onClick={() => setForm(f => ({ ...f, image_source: 'url' }))}><FiLink size={12} /> URL</button>
              <button className={`btn btn-sm ${form.image_source === 'file' ? 'btn-primary' : 'btn-outline'}`} onClick={() => setForm(f => ({ ...f, image_source: 'file' }))}><FiUpload size={12} /> Upload</button>
            </div>
            
            {form.image_source === 'url' ? (
              <input className="form-control" placeholder="https://..." value={form.image_url} onChange={e => setForm(f => ({ ...f, image_url: e.target.value }))} />
            ) : (
              <div className="file-upload-zone">
                {uploading ? (
                  <p>Uploading and compressing...</p>
                ) : (
                  <>
                    <input type="file" accept="image/*" onChange={e => e.target.files[0] && compressAndUpload(e.target.files[0])} />
                    {form.image_url && <div style={{ marginTop: 8, fontSize: 12, color: 'var(--text-secondary)' }} className="truncate">Uploaded: {form.image_url}</div>}
                  </>
                )}
              </div>
            )}
          </div>

          <div className="form-group">
            <label className="form-label">Description</label>
            <textarea className="form-control" placeholder="Product details..." value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} rows={2} />
          </div>
        </Modal>
      )}
    </div>
  );
}
