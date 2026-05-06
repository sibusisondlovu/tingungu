import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, addDoc, deleteDoc, doc, onSnapshot, serverTimestamp, updateDoc, query, orderBy } from 'firebase/firestore';
import { FiPlus, FiTrash2, FiEdit2, FiShoppingBag, FiTag } from 'react-icons/fi';

function Modal({ title, onClose, onSave, loading, children }) {
  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal">
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

const CATEGORIES = ['Books', 'Clothing', 'Music', 'Accessories', 'Food', 'Other'];

export default function MarketplacePage() {
  const [products, setProducts] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', price: '', category: 'Books', description: '', stock: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = query(collection(db, 'products'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, snap => {
      setProducts(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const openNew = () => { setEditing(null); setForm({ name: '', price: '', category: 'Books', description: '', stock: '' }); setShowModal(true); };
  const openEdit = (p) => { setEditing(p); setForm({ name: p.name, price: p.price || '', category: p.category || 'Books', description: p.description || '', stock: p.stock || '' }); setShowModal(true); };

  const save = async () => {
    if (!form.name || !form.price) return;
    setLoading(true);
    const data = { name: form.name, price: Number(form.price), category: form.category, description: form.description, stock: Number(form.stock) || 0 };
    try {
      if (editing) {
        await updateDoc(doc(db, 'products', editing.id), data);
      } else {
        await addDoc(collection(db, 'products'), { ...data, createdAt: serverTimestamp() });
      }
      setShowModal(false);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (confirm('Delete this product?')) await deleteDoc(doc(db, 'products', id));
  };

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
          <div className="table-container">
            <table>
              <thead>
                <tr><th>Product</th><th>Category</th><th>Price</th><th>Stock</th><th>Actions</th></tr>
              </thead>
              <tbody>
                {products.map(p => (
                  <tr key={p.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{ width: 36, height: 36, background: 'rgba(59,13,17,0.08)', borderRadius: 8, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                          <FiTag size={16} style={{ color: 'var(--maroon)' }} />
                        </div>
                        <div>
                          <strong>{p.name}</strong>
                          {p.description && <div style={{ fontSize: 12, color: 'var(--text-secondary)' }} className="truncate">{p.description}</div>}
                        </div>
                      </div>
                    </td>
                    <td><span className="badge badge-info">{p.category || 'Other'}</span></td>
                    <td style={{ fontWeight: 700, color: 'var(--maroon)' }}>R {Number(p.price || 0).toFixed(2)}</td>
                    <td>
                      <span className={`badge ${p.stock > 0 ? 'badge-success' : 'badge-danger'}`}>
                        {p.stock > 0 ? `${p.stock} in stock` : 'Out of stock'}
                      </span>
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(p)}><FiEdit2 size={14} /></button>
                        <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(p.id)}><FiTrash2 size={14} /></button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {showModal && (
        <Modal title={editing ? 'Edit Product' : 'New Product'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-group">
            <label className="form-label">Product Name</label>
            <input className="form-control" placeholder="e.g. Church Hymn Book" value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Price (R)</label>
              <input type="number" className="form-control" placeholder="0.00" value={form.price} onChange={e => setForm(f => ({ ...f, price: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Stock</label>
              <input type="number" className="form-control" placeholder="0" value={form.stock} onChange={e => setForm(f => ({ ...f, stock: e.target.value }))} />
            </div>
          </div>
          <div className="form-group">
            <label className="form-label">Category</label>
            <select className="form-control" value={form.category} onChange={e => setForm(f => ({ ...f, category: e.target.value }))}>
              {CATEGORIES.map(c => <option key={c} value={c}>{c}</option>)}
            </select>
          </div>
          <div className="form-group">
            <label className="form-label">Description</label>
            <textarea className="form-control" placeholder="Product description..." value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} rows={2} />
          </div>
        </Modal>
      )}
    </div>
  );
}
