import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { FiMail } from 'react-icons/fi';
import { format } from 'date-fns';

export default function TestingProgramPage() {
  const [testers, setTesters] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    // Order by createdAt descending (newest first)
    const q = query(collection(db, 'test_program_emails'), orderBy('createdAt', 'desc'));
    return onSnapshot(q, snap => {
      setTesters(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const filtered = testers.filter(t =>
    (t.email || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Testing Program</h1>
          <p>{testers.length} users interested in early access</p>
        </div>
        <div className="search-bar">
          <FiMail size={16} />
          <input placeholder="Search by email..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <FiMail />
            <h3>No testers found</h3>
            <p>{search ? 'Try a different search term' : 'No users signed up yet'}</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Email</th>
                  <th>Source</th>
                  <th>Date Joined</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(t => (
                  <tr key={t.id}>
                    <td>
                      <div style={{ fontWeight: 600 }}>{t.email || '—'}</div>
                    </td>
                    <td>
                      <span className="badge badge-primary" style={{ backgroundColor: 'var(--bg-alt)', color: 'var(--primary)' }}>
                        {t.source || 'Web'}
                      </span>
                    </td>
                    <td style={{ color: 'var(--text-secondary)', fontSize: 13 }}>
                      {t.createdAt?.toDate ? format(t.createdAt.toDate(), 'dd MMM yyyy, HH:mm') : '—'}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
