import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, addDoc, deleteDoc, doc, onSnapshot, serverTimestamp, updateDoc, query, orderBy } from 'firebase/firestore';
import { FiPlus, FiTrash2, FiEdit2, FiCalendar } from 'react-icons/fi';

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
            {loading ? 'Saving...' : 'Save Event'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function EventsPage() {
  const [events, setEvents] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ month: 'January', date_start: '', date_end: '', description: '', venue: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = query(collection(db, 'events'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, snap => {
      setEvents(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const openNew = () => { setEditing(null); setForm({ month: 'January', date_start: '', date_end: '', description: '', venue: '' }); setShowModal(true); };
  const openEdit = (ev) => { setEditing(ev); setForm({ month: ev.month || 'January', date_start: ev.date_start || '', date_end: ev.date_end || '', description: ev.description || '', venue: ev.venue || '' }); setShowModal(true); };

  const save = async () => {
    if (!form.description) return;
    setLoading(true);
    try {
      if (editing) {
        await updateDoc(doc(db, 'events', editing.id), form);
      } else {
        await addDoc(collection(db, 'events'), { ...form, createdAt: serverTimestamp() });
      }
      setShowModal(false);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (confirm('Delete this event?')) await deleteDoc(doc(db, 'events', id));
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Events</h1>
          <p>Manage church events and community gatherings</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}><FiPlus /> New Event</button>
      </div>

      <div className="card">
        {events.length === 0 ? (
          <div className="empty-state">
            <FiCalendar />
            <h3>No events</h3>
            <p>Add upcoming church events for the community</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr><th>Description</th><th>Month</th><th>Date</th><th>Venue</th><th>Actions</th></tr>
              </thead>
              <tbody>
                {events.map(ev => (
                  <tr key={ev.id}>
                    <td><strong>{ev.description}</strong></td>
                    <td>{ev.month}</td>
                    <td>{ev.date_start}{ev.date_end ? ` - ${ev.date_end}` : ''}</td>
                    <td>{ev.venue || '—'}</td>
                    <td>
                      <div style={{ display: 'flex', gap: 6 }}>
                        <button className="btn btn-outline btn-sm btn-icon" onClick={() => openEdit(ev)}><FiEdit2 size={14} /></button>
                        <button className="btn btn-danger btn-sm btn-icon" onClick={() => remove(ev.id)}><FiTrash2 size={14} /></button>
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
        <Modal title={editing ? 'Edit Event' : 'New Event'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-group">
            <label className="form-label">Description</label>
            <input className="form-control" placeholder="e.g. Sunday Morning Service" value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} />
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Month</label>
              <select className="form-control" value={form.month} onChange={e => setForm(f => ({ ...f, month: e.target.value }))}>
                {['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'].map(m => (
                  <option key={m} value={m}>{m}</option>
                ))}
              </select>
            </div>
            <div className="form-group">
              <label className="form-label">Date Start (Day)</label>
              <input type="text" className="form-control" placeholder="e.g. 1" value={form.date_start} onChange={e => setForm(f => ({ ...f, date_start: e.target.value }))} />
            </div>
          </div>
          <div className="form-row">
            <div className="form-group">
              <label className="form-label">Date End (Day, optional)</label>
              <input type="text" className="form-control" placeholder="e.g. 2" value={form.date_end} onChange={e => setForm(f => ({ ...f, date_end: e.target.value }))} />
            </div>
            <div className="form-group">
              <label className="form-label">Venue</label>
              <input className="form-control" placeholder="Venue or address" value={form.venue} onChange={e => setForm(f => ({ ...f, venue: e.target.value }))} />
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
