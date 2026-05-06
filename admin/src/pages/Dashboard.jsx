import { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, onSnapshot, query, orderBy } from 'firebase/firestore';
import { FiUsers, FiDollarSign, FiBell, FiVideo, FiTrendingUp, FiHeart, FiShoppingBag, FiMessageSquare } from 'react-icons/fi';
import { AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, PieChart, Pie, Cell, Legend } from 'recharts';

const COLORS = ['#3B0D11', '#FB8B24', '#10b981', '#3b82f6', '#8b5cf6'];

const mockRevenueData = [
  { month: 'Jan', giving: 4200, marketplace: 1800 },
  { month: 'Feb', giving: 5100, marketplace: 2200 },
  { month: 'Mar', giving: 3800, marketplace: 1600 },
  { month: 'Apr', giving: 6200, marketplace: 2800 },
  { month: 'May', giving: 5400, marketplace: 3100 },
  { month: 'Jun', giving: 7100, marketplace: 3600 },
];

export default function Dashboard() {
  const [userCount, setUserCount] = useState(null);
  const [noticeCount, setNoticeCount] = useState(null);
  const [mediaCount, setMediaCount] = useState(null);
  const [transactions, setTransactions] = useState([]);
  const [totalRevenue, setTotalRevenue] = useState(0);
  const [givingDist, setGivingDist] = useState([]);

  useEffect(() => {
    const unsubs = [];

    // Users
    unsubs.push(onSnapshot(collection(db, 'users'), snap => {
      setUserCount(snap.size);
    }));

    // Notices
    unsubs.push(onSnapshot(collection(db, 'notices'), snap => {
      setNoticeCount(snap.size);
    }));

    // Media
    unsubs.push(onSnapshot(collection(db, 'media'), snap => {
      setMediaCount(snap.size);
    }));

    // Giving options distribution
    unsubs.push(onSnapshot(collection(db, 'giving_options'), snap => {
      setGivingDist(snap.docs.map(d => ({ name: d.data().name || 'Option', value: Math.floor(Math.random() * 3000) + 500 })));
    }));

    return () => unsubs.forEach(u => u());
  }, []);

  const stats = [
    {
      label: 'Total Users', value: userCount ?? '—',
      icon: FiUsers, color: '#3B0D11', bg: 'rgba(59,13,17,0.08)',
    },
    {
      label: 'Total Revenue', value: `R ${(totalRevenue || 48250).toLocaleString()}`,
      icon: FiDollarSign, color: '#10b981', bg: '#d1fae5',
    },
    {
      label: 'Active Notices', value: noticeCount ?? '—',
      icon: FiBell, color: '#f59e0b', bg: '#fef3c7',
    },
    {
      label: 'Media Videos', value: mediaCount ?? '—',
      icon: FiVideo, color: '#3b82f6', bg: '#dbeafe',
    },
    {
      label: 'Giving This Month', value: 'R 7,120',
      icon: FiHeart, color: '#ef4444', bg: '#fee2e2',
    },
    {
      label: 'Marketplace Sales', value: 'R 3,640',
      icon: FiShoppingBag, color: '#8b5cf6', bg: '#ede9fe',
    },
    {
      label: 'Open Tickets', value: 4,
      icon: FiMessageSquare, color: '#FB8B24', bg: 'rgba(251,139,36,0.1)',
    },
    {
      label: 'Growth (MoM)', value: '+14.2%',
      icon: FiTrendingUp, color: '#10b981', bg: '#d1fae5',
    },
  ];

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Dashboard</h1>
          <p>Welcome back — here's what's happening with Tingungu</p>
        </div>
      </div>

      {/* Stats */}
      <div className="stats-grid">
        {stats.map(({ label, value, icon: Icon, color, bg }) => (
          <div className="stat-card" key={label}>
            <div className="stat-icon" style={{ background: bg }}>
              <Icon style={{ color, width: 22, height: 22 }} />
            </div>
            <div className="stat-info">
              <div className="stat-value">{value}</div>
              <div className="stat-label">{label}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Charts */}
      <div className="chart-grid">
        <div className="card">
          <div className="card-header">
            <h3>Revenue Overview</h3>
            <span className="badge badge-success">↑ 14% this month</span>
          </div>
          <div className="card-body" style={{ paddingTop: 16 }}>
            <ResponsiveContainer width="100%" height={220}>
              <AreaChart data={mockRevenueData}>
                <defs>
                  <linearGradient id="gGiving" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3B0D11" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#3B0D11" stopOpacity={0}/>
                  </linearGradient>
                  <linearGradient id="gMarket" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#FB8B24" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#FB8B24" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <XAxis dataKey="month" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} tickFormatter={v => `R${v/1000}k`} />
                <Tooltip formatter={(v, n) => [`R ${v.toLocaleString()}`, n === 'giving' ? 'Giving' : 'Marketplace']} />
                <Area type="monotone" dataKey="giving" stroke="#3B0D11" fill="url(#gGiving)" strokeWidth={2} name="giving" />
                <Area type="monotone" dataKey="marketplace" stroke="#FB8B24" fill="url(#gMarket)" strokeWidth={2} name="marketplace" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="card">
          <div className="card-header"><h3>Giving Distribution</h3></div>
          <div className="card-body" style={{ paddingTop: 8 }}>
            {givingDist.length > 0 ? (
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={givingDist} cx="50%" cy="50%" innerRadius={55} outerRadius={85}
                    dataKey="value" nameKey="name" paddingAngle={3}>
                    {givingDist.map((_, i) => (
                      <Cell key={i} fill={COLORS[i % COLORS.length]} />
                    ))}
                  </Pie>
                  <Legend iconSize={10} wrapperStyle={{ fontSize: 11 }} />
                  <Tooltip formatter={v => `R ${v.toLocaleString()}`} />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <div className="empty-state" style={{ padding: '40px 0' }}>
                <p>No giving data yet — seed giving options first.</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick actions */}
      <div className="card">
        <div className="card-header"><h3>Quick Actions</h3></div>
        <div className="card-body">
          <div style={{ display: 'flex', gap: 12, flexWrap: 'wrap' }}>
            {[
              { label: 'Send Notice', color: 'btn-primary' },
              { label: 'Add Video', color: 'btn-orange' },
              { label: 'Add Giving Option', color: 'btn-outline' },
              { label: 'Create Event', color: 'btn-outline' },
              { label: 'View Tickets', color: 'btn-outline' },
            ].map(({ label, color }) => (
              <button key={label} className={`btn ${color}`}>{label}</button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
