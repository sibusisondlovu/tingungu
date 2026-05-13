import { useState, useEffect } from 'react';
import { FiPlus, FiTrash2, FiEdit2, FiMapPin } from 'react-icons/fi';
import { API_BASE_URL } from '../config';

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
            {loading ? 'Saving...' : 'Save'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function SocietiesPage() {
  const [societies, setSocieties] = useState([]);
  const [circuits, setCircuits] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', circuit_id: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchSocieties();
    fetchCircuits();
  }, []);

  const fetchSocieties = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/societies`);
      const data = await res.json();
      setSocieties(data);
    } catch (err) {
      console.error('Error fetching societies:', err);
    }
  };

  const fetchCircuits = async () => {
    try {
      const res = await fetch(`${API_BASE_URL}/circuits`);
      const data = await res.json();
      setCircuits(data);
    } catch (err) {
      console.error('Error fetching circuits:', err);
    }
  };

  const openNew = () => { 
    setEditing(null); 
    setForm({ name: '', circuit_id: circuits[0]?.circuit_id || '' }); 
    setShowModal(true); 
  };
  
  const openEdit = (s) => { 
    setEditing(s); 
    setForm({ name: s.society_name, circuit_id: s.circuit_id }); 
    setShowModal(true); 
  };

  const save = async () => {
    if (!form.name || !form.circuit_id) return;
    setLoading(true);
    try {
      const url = editing 
        ? `${API_BASE_URL}/societies/${editing.society_id}` 
        : `${API_BASE_URL}/societies`;
      
      const method = editing ? 'PUT' : 'POST';

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: form.name,
          circuit_id: form.circuit_id
        }),
      });

      if (res.ok) {
        fetchSocieties();
        setShowModal(false);
      }
    } catch (err) {
      console.error('Error saving society:', err);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (!confirm('Delete this society?')) return;
    try {
      const res = await fetch(`${API_BASE_URL}/societies/${id}`, { method: 'DELETE' });
      if (res.ok) fetchSocieties();
    } catch (err) {
      console.error('Error deleting society:', err);
    }
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Societies</h1>
          <p>Manage church societies and circuits (MySQL)</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}><FiPlus /> Add Society</button>
      </div>

      <div className="card">
        {societies.length === 0 ? (
          <div className="empty-state">
            <FiMapPin />
            <h3>No societies</h3>
            <p>Add church societies from the MySQL database</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Society Name</th>
                  <th>Circuit</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {societies.map(s => (
                  <tr key={s.society_id}>
                    <td><span className="badge badge-outline">#{s.society_id}</span></td>
                    <td><strong>{s.society_name}</strong></td>
                    <td>{s.circuit_name || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(s)}><FiEdit2 size={14} /></button>
                        <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(s.society_id)}><FiTrash2 size={14} /></button>
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
        <Modal title={editing ? 'Edit Society' : 'Add Society'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-group">
            <label className="form-label">Society Name</label>
            <input 
              className="form-control" 
              placeholder="e.g. Zion Society" 
              value={form.name} 
              onChange={e => setForm(f => ({ ...f, name: e.target.value }))} 
            />
          </div>
          <div className="form-group">
            <label className="form-label">Circuit</label>
            <select 
              className="form-control" 
              value={form.circuit_id} 
              onChange={e => setForm(f => ({ ...f, circuit_id: e.target.value }))}
            >
              {circuits.map(c => (
                <option key={c.circuit_id} value={c.circuit_id}>
                  {c.circuit_name} ({c.circuit_code})
                </option>
              ))}
            </select>
          </div>
        </Modal>
      )}
    </div>
  );
}
