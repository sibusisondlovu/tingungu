import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, addDoc, deleteDoc, doc, onSnapshot, serverTimestamp, updateDoc } from 'firebase/firestore';
import { FiPlus, FiTrash2, FiEdit2, FiMapPin } from 'react-icons/fi';

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
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ name: '', circuit: '', location: '', leader: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    return onSnapshot(collection(db, 'societies'), snap => {
      setSocieties(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const openNew = () => { setEditing(null); setForm({ name: '', circuit: '', location: '', leader: '' }); setShowModal(true); };
  const openEdit = (s) => { setEditing(s); setForm({ name: s.name, circuit: s.circuit || '', location: s.location || '', leader: s.leader || '' }); setShowModal(true); };

  const save = async () => {
    if (!form.name) return;
    setLoading(true);
    try {
      if (editing) {
        await updateDoc(doc(db, 'societies', editing.id), form);
      } else {
        await addDoc(collection(db, 'societies'), { ...form, createdAt: serverTimestamp() });
      }
      setShowModal(false);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (confirm('Delete this society?')) await deleteDoc(doc(db, 'societies', id));
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Societies</h1>
          <p>Manage church societies and circuits</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}><FiPlus /> Add Society</button>
      </div>

      <div className="card">
        {societies.length === 0 ? (
          <div className="empty-state">
            <FiMapPin />
            <h3>No societies</h3>
            <p>Add church societies that members can join</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr><th>Society Name</th><th>Circuit</th><th>Location</th><th>Leader</th><th>Actions</th></tr>
              </thead>
              <tbody>
                {societies.map(s => (
                  <tr key={s.id}>
                    <td><strong>{s.name}</strong></td>
                    <td>{s.circuit || '—'}</td>
                    <td>{s.location || '—'}</td>
                    <td>{s.leader || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(s)}><FiEdit2 size={14} /></button>
                        <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(s.id)}><FiTrash2 size={14} /></button>
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
            <input className="form-control" placeholder="e.g. Zion Society" value={form.name} onChange={e => setForm(f => ({ ...f, name: e.target.value }))} />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Circuit</label>
              <input className="form-control" placeholder="Circuit name" value={form.circuit} onChange={e => setForm(f => ({ ...f, circuit: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Location</label>
              <input className="form-control" placeholder="Town / Area" value={form.location} onChange={e => setForm(f => ({ ...f, location: e.target.value }))} />
            </div>
          </div>
          <div className="form-group">
            <label className="form-label">Society Leader</label>
            <input className="form-control" placeholder="Leader name" value={form.leader} onChange={e => setForm(f => ({ ...f, leader: e.target.value }))} />
          </div>
        </Modal>
      )}
    </div>
  );
}
