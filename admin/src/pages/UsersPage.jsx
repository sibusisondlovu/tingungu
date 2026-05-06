import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { FiUsers } from 'react-icons/fi';
import { format } from 'date-fns';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [search, setSearch] = useState('');

  useEffect(() => {
    return onSnapshot(collection(db, 'users'), snap => {
      setUsers(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });
  }, []);

  const filtered = users.filter(u =>
    (u.displayname || u.email || '').toLowerCase().includes(search.toLowerCase())
  );

  const initials = (u) => {
    const name = u.displayname || u.email || '?';
    return name.slice(0, 2).toUpperCase();
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Users</h1>
          <p>{users.length} registered members</p>
        </div>
        <div className="search-bar">
          <FiUsers size={16} />
          <input placeholder="Search by name or email..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <FiUsers />
            <h3>No users found</h3>
            <p>{search ? 'Try a different search term' : 'No users registered yet'}</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Member</th>
                  <th>Email</th>
                  <th>Society</th>
                  <th>Wallet Balance</th>
                  <th>Status</th>
                  <th>Joined</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(u => (
                  <tr key={u.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div className="avatar">{initials(u)}</div>
                        <div>
                          <div style={{ fontWeight: 600, fontSize: 14 }}>{u.displayname || '—'}</div>
                          <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>{u.id.slice(0, 8)}...</div>
                        </div>
                      </div>
                    </td>
                    <td>{u.email || '—'}</td>
                    <td>{u.society || <span style={{ color: 'var(--text-secondary)' }}>Not set</span>}</td>
                    <td>
                      <span style={{ fontWeight: 600, color: 'var(--maroon)' }}>
                        R {(u.wallet_balance || 0).toFixed(2)}
                      </span>
                    </td>
                    <td>
                      <span className={`badge ${u.profile_completed ? 'badge-success' : 'badge-warning'}`}>
                        {u.profile_completed ? 'Complete' : 'Incomplete'}
                      </span>
                    </td>
                    <td style={{ color: 'var(--text-secondary)', fontSize: 13 }}>
                      {u.createdAt?.toDate ? format(u.createdAt.toDate(), 'dd MMM yyyy') : '—'}
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
