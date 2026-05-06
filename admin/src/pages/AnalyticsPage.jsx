import { FiBarChart2, FiExternalLink } from 'react-icons/fi';

export default function AnalyticsPage() {
  const GA_ID = 'G-XXXXXXXXXX'; // Will be pulled from settings

  return (
    <div>
      <div className="page-header">
        <div>
          <h1>Analytics</h1>
          <p>Monitor app usage, website traffic and engagement</p>
        </div>
        <a
          href="https://analytics.google.com"
          target="_blank"
          rel="noreferrer"
          className="btn btn-outline"
        >
          <FiExternalLink size={14} /> Open Google Analytics
        </a>
      </div>

      <div className="alert alert-info">
        <FiBarChart2 size={16} style={{ flexShrink: 0 }} />
        <span>
          Google Analytics is integrated via your Measurement ID configured in Settings.
          You can also embed your GA dashboard directly below by adding your embed URL.
        </span>
      </div>

      {/* Summary cards */}
      <div className="stats-grid" style={{ marginBottom: 24 }}>
        {[
          { label: 'Active Users (7d)', value: '—', note: 'Via Google Analytics' },
          { label: 'Website Sessions', value: '—', note: 'tingungu.co.za' },
          { label: 'App Opens (7d)', value: '—', note: 'Firebase Analytics' },
          { label: 'Avg Session Duration', value: '—', note: 'seconds' },
        ].map(({ label, value, note }) => (
          <div className="stat-card" key={label}>
            <div className="stat-info">
              <div className="stat-value">{value}</div>
              <div className="stat-label">{label}</div>
              <div style={{ fontSize: 11, color: 'var(--text-secondary)', marginTop: 2 }}>{note}</div>
            </div>
          </div>
        ))}
      </div>

      <div className="card">
        <div className="card-header"><h3>Google Analytics Dashboard Embed</h3></div>
        <div className="card-body">
          <div style={{ background: '#f8f7f4', borderRadius: 8, padding: '60px 20px', textAlign: 'center', border: '2px dashed var(--border)' }}>
            <FiBarChart2 size={40} style={{ color: 'var(--text-secondary)', marginBottom: 16 }} />
            <h3 style={{ fontSize: 16, marginBottom: 8 }}>Embed your Google Analytics Report</h3>
            <p style={{ color: 'var(--text-secondary)', fontSize: 14, marginBottom: 20 }}>
              In Google Analytics → Reports → Share → Embed. Paste the iframe URL in Settings → Google Services.
            </p>
            <a
              href="https://analytics.google.com"
              target="_blank"
              rel="noreferrer"
              className="btn btn-primary"
            >
              <FiExternalLink size={14} /> Open Analytics Dashboard
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
