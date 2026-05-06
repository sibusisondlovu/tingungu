import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, addDoc, deleteDoc, doc, onSnapshot, serverTimestamp, updateDoc, query, orderBy } from 'firebase/firestore';
import { FiPlus, FiTrash2, FiEdit2, FiVideo, FiExternalLink } from 'react-icons/fi';

function extractVideoId(url = '') {
  try {
    if (url.includes('youtu.be/')) return url.split('youtu.be/').pop().split('?')[0];
    if (url.includes('youtube.com/watch')) return new URL(url).searchParams.get('v');
    if (url.includes('youtube.com/live/')) return url.split('live/').pop().split('?')[0];
    if (url.includes('youtube.com/embed/')) return url.split('embed/').pop().split('?')[0];
  } catch {}
  return '';
}

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
            {loading ? 'Saving...' : 'Save Video'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default function MediaPage() {
  const [videos, setVideos] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({ title: '', url: '', description: '' });
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = query(collection(db, 'media'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, snap => {
      setVideos(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const openNew = () => { setEditing(null); setForm({ title: '', url: '', description: '' }); setShowModal(true); };
  const openEdit = (v) => { setEditing(v); setForm({ title: v.title, url: v.url, description: v.description || '' }); setShowModal(true); };

  const getThumbnail = (url) => {
    const id = extractVideoId(url);
    return id ? `https://img.youtube.com/vi/${id}/mqdefault.jpg` : '';
  };

  const save = async () => {
    if (!form.title || !form.url) return;
    setLoading(true);
    const vid = extractVideoId(form.url);
    const thumbnail = vid ? `https://img.youtube.com/vi/${vid}/0.jpg` : '';
    try {
      if (editing) {
        await updateDoc(doc(db, 'media', editing.id), { title: form.title, url: form.url, description: form.description, thumbnail });
      } else {
        await addDoc(collection(db, 'media'), { ...form, thumbnail, createdAt: serverTimestamp() });
      }
      setShowModal(false);
    } finally {
      setLoading(false);
    }
  };

  const remove = async (id) => {
    if (confirm('Delete this video?')) await deleteDoc(doc(db, 'media', id));
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Media / Videos</h1>
          <p>Manage videos displayed in the Tingungu TV section of the app</p>
        </div>
        <button className="btn btn-primary" onClick={openNew}>
          <FiPlus /> Add Video
        </button>
      </div>

      {videos.length === 0 ? (
        <div className="card">
          <div className="empty-state">
            <FiVideo />
            <h3>No videos yet</h3>
            <p>Add YouTube links to populate the Tingungu Media screen</p>
          </div>
        </div>
      ) : (
        <div className="video-grid">
          {videos.map(v => {
            const thumb = v.thumbnail || getThumbnail(v.url);
            return (
              <div className="video-card" key={v.id}>
                <div className="video-thumb">
                  {thumb
                    ? <img src={thumb} alt={v.title} onError={e => e.target.style.display='none'} />
                    : <div className="video-thumb-fallback"><FiVideo size={36} /></div>
                  }
                  <span className="video-play-badge">▶ YouTube</span>
                </div>
                <div className="video-info">
                  <h4>{v.title}</h4>
                  {v.description && <p>{v.description}</p>}
                  <div className="video-actions">
                    <button className="btn btn-outline btn-sm" onClick={() => openEdit(v)}><FiEdit2 size={13} /> Edit</button>
                    <a href={v.url} target="_blank" rel="noreferrer" className="btn btn-outline btn-sm"><FiExternalLink size={13} /> Watch</a>
                    <button className="btn btn-danger btn-sm" onClick={() => remove(v.id)}><FiTrash2 size={13} /></button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {showModal && (
        <Modal title={editing ? 'Edit Video' : 'Add Video'} onClose={() => setShowModal(false)} onSave={save} loading={loading}>
          <div className="form-group">
            <label className="form-label">Title</label>
            <input className="form-control" placeholder="e.g. Sunday Morning Service" value={form.title} onChange={e => setForm(f => ({ ...f, title: e.target.value }))} />
          </div>
          <div className="form-group">
            <label className="form-label">YouTube URL</label>
            <input className="form-control" placeholder="https://www.youtube.com/live/..." value={form.url} onChange={e => setForm(f => ({ ...f, url: e.target.value }))} />
            {form.url && extractVideoId(form.url) && (
              <div style={{ marginTop: 10, borderRadius: 8, overflow: 'hidden' }}>
                <img src={getThumbnail(form.url)} alt="Preview" style={{ width: '100%', borderRadius: 8 }} />
              </div>
            )}
          </div>
          <div className="form-group">
            <label className="form-label">Description (optional)</label>
            <textarea className="form-control" placeholder="Brief description of the video..." value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} rows={3} />
          </div>
        </Modal>
      )}
    </div>
  );
}
