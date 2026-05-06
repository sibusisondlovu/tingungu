import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collectionGroup, collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { FiDollarSign } from 'react-icons/fi';
import { format } from 'date-fns';

export default function TransactionsPage() {
  const [transactions, setTransactions] = useState([]);
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');

  useEffect(() => {
    // Listen to top-level transactions collection (or collectionGroup if nested under users)
    const unsubs = [];

    // Try collectionGroup for users/{uid}/transactions pattern
    try {
      const q = query(collectionGroup(db, 'transactions'), orderBy('createdAt', 'desc'));
      unsubs.push(onSnapshot(q, snap => {
        setTransactions(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      }));
    } catch {
      unsubs.push(onSnapshot(collection(db, 'transactions'), snap => {
        setTransactions(snap.docs.map(d => ({ id: d.id, ...d.data() })));
      }));
    }

    return () => unsubs.forEach(u => u());
  }, []);

  const types = ['all', 'giving', 'topup', 'marketplace', 'airtime'];

  const filtered = transactions.filter(t => {
    const matchType = filter === 'all' || (t.type || '').toLowerCase() === filter;
    const matchSearch = (t.description || t.type || '').toLowerCase().includes(search.toLowerCase());
    return matchType && matchSearch;
  });

  const total = filtered.reduce((sum, t) => sum + (Number(t.amount) || 0), 0);

  const typeColor = (type = '') => {
    const map = { giving: 'badge-danger', topup: 'badge-success', marketplace: 'badge-info', airtime: 'badge-warning' };
    return map[type.toLowerCase()] || 'badge-neutral';
  };

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Transactions</h1>
          <p>{transactions.length} total transactions</p>
        </div>
        <div className="search-bar">
          <FiDollarSign size={16} />
          <input placeholder="Search transactions..." value={search} onChange={e => setSearch(e.target.value)} />
        </div>
      </div>

      {/* Filters */}
      <div style={{ display: 'flex', gap: 8, marginBottom: 20, flexWrap: 'wrap' }}>
        {types.map(t => (
          <button
            key={t}
            className={`btn btn-sm ${filter === t ? 'btn-primary' : 'btn-outline'}`}
            onClick={() => setFilter(t)}
            style={{ textTransform: 'capitalize' }}
          >
            {t === 'all' ? 'All Types' : t}
          </button>
        ))}
        <div style={{ marginLeft: 'auto', display: 'flex', alignItems: 'center', gap: 8 }}>
          <span style={{ fontSize: 13, color: 'var(--text-secondary)' }}>Showing {filtered.length} records</span>
          <span style={{ fontWeight: 700, color: 'var(--maroon)' }}>Total: R {total.toFixed(2)}</span>
        </div>
      </div>

      <div className="card">
        {filtered.length === 0 ? (
          <div className="empty-state">
            <FiDollarSign />
            <h3>No transactions found</h3>
            <p>Transactions will appear here as users make payments</p>
          </div>
        ) : (
          <div className="table-container">
            <table>
              <thead>
                <tr>
                  <th>Description</th>
                  <th>Type</th>
                  <th>Amount</th>
                  <th>User ID</th>
                  <th>Date</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                {filtered.map(t => (
                  <tr key={t.id}>
                    <td><strong>{t.description || t.type || '—'}</strong></td>
                    <td><span className={`badge ${typeColor(t.type)}`} style={{ textTransform: 'capitalize' }}>{t.type || 'Unknown'}</span></td>
                    <td style={{ fontWeight: 700, color: t.type === 'topup' ? 'var(--success)' : 'var(--maroon)' }}>
                      {t.type === 'topup' ? '+' : '-'}R {(Math.abs(Number(t.amount)) || 0).toFixed(2)}
                    </td>
                    <td style={{ fontFamily: 'monospace', fontSize: 12, color: 'var(--text-secondary)' }}>
                      {t.userId?.slice(0, 12) || '—'}...
                    </td>
                    <td style={{ fontSize: 13, color: 'var(--text-secondary)', whiteSpace: 'nowrap' }}>
                      {t.createdAt?.toDate ? format(t.createdAt.toDate(), 'dd MMM yyyy HH:mm') : '—'}
                    </td>
                    <td><span className="badge badge-success">Completed</span></td>
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
