import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, addDoc, deleteDoc, doc, onSnapshot, serverTimestamp, updateDoc, query, orderBy } from 'firebase/firestore';
import { FiPlus, FiTrash2, FiEdit2, FiBell } from 'react-icons/fi';
import { format } from 'date-fns';

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

export default function NoticesPage() {
  const [notices, setNotices] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ title: '', message: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = query(collection(db, 'notices'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, snap => {
      setNotices(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const openNew = () => { setEditing(null); setForm({ title: '', message: '' }); setShowModal(true); };
  const openEdit = (n) => { setEditing(n); setForm({ title: n.title, message: n.message }); setShowModal(true); };

  const save = async () => {
    if (!form.title || !form.message) return;
    setLoading(true);
    try {
      if (editing) {
        await updateDoc(doc(db, 'notices', editing.id), { title: form.title, message: form.message });
      } else {
        await addDoc(collection(db, 'notices'), { ...form, createdAt: serverTimestamp() });
      }
      setShowModal(false);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (confirm('Delete this notice?')) await deleteDoc(doc(db, 'notices', id));
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Notices</h1>
          <p>Send announcements to all app users in real-time</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}>
          <FiPlus /> New Notice
        </button>
      </div>

      <div className="card">
        {notices.length === 0 ? (
          <div className="empty-state">
            <FiBell />
            <h3>No notices yet</h3>
            <p>Create your first announcement for the community</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Title</th>
                  <th>Message</th>
                  <th>Date</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {notices.map(n => (
                  <tr key={n.id}>
                    <td><strong>{n.title}</strong></td>
                    <td style={{ maxWidth: 320 }} className="truncate">{n.message}</td>
                    <td style={{ whiteSpace: 'nowrap', color: 'var(--text-secondary)', fontSize: 13 }}>
                      {n.createdAt?.toDate ? format(n.createdAt.toDate(), 'dd MMM yyyy, HH:mm') : '—'}
                    </td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(n)} title="Edit"><FiEdit2 size={14} /></button>
                        <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(n.id)} title="Delete"><FiTrash2 size={14} /></button>
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
        <Modal title={editing ? 'Edit Notice' : 'New Notice'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-group">
            <label className="form-label">Title</label>
            <input className="form-control" placeholder="Notice title..." value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} />
          </div>
          <div className="form-group">
            <label className="form-label">Message</label>
            <textarea className="form-control" placeholder="Write your announcement here..." value={form.message} onChange={e => setForm(f => ({ ...f, message: e.target.value }))} rows={4} />
          </div>
        </Modal>
      )}
    </div>
  );
}
