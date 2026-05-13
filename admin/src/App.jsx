import { useState } from 'react';
import { useAuth } from './contexts/AuthContext';
import Sidebar from './components/Sidebar';
import Dashboard from './pages/Dashboard';
import NoticesPage from './pages/NoticesPage';
import MediaPage from './pages/MediaPage';
import GivingPage from './pages/GivingPage';
import UsersPage from './pages/UsersPage';
import SocietiesPage from './pages/SocietiesPage';
import DistrictsPage from './pages/DistrictsPage';
import CircuitsPage from './pages/CircuitsPage';
import MinistersPage from './pages/MinistersPage';
import TransactionsPage from './pages/TransactionsPage';
import MarketplacePage from './pages/MarketplacePage';
import TicketsPage from './pages/TicketsPage';
import AnalyticsPage from './pages/AnalyticsPage';
import SettingsPage from './pages/SettingsPage';
import EventsPage from './pages/EventsPage';
import LoginPage from './pages/LoginPage';

const PAGE_TITLES = {
  dashboard: { title: 'Dashboard', subtitle: 'Overview of your Tingungu community' },
  notices: { title: 'Notices', subtitle: 'Push announcements to all app users' },
  media: { title: 'Media / Videos', subtitle: 'Manage Tingungu TV content' },
  giving: { title: 'Giving Options', subtitle: 'Manage tithes, offerings and pledges' },
  events: { title: 'Events', subtitle: 'Church events and gatherings' },
  users: { title: 'Users', subtitle: 'Registered community members' },
  societies: { title: 'Societies', subtitle: 'Church societies' },
  districts: { title: 'Districts', subtitle: 'Church districts' },
  circuits: { title: 'Circuits', subtitle: 'Church circuits' },
  ministers: { title: 'Ministers', subtitle: 'Church ministers and appointments' },
  transactions: { title: 'Transactions', subtitle: 'All wallet and payment activity' },
  marketplace: { title: 'Marketplace', subtitle: 'Church store products' },
  tickets: { title: 'Support Tickets', subtitle: 'User-submitted issues' },
  analytics: { title: 'Analytics', subtitle: 'App and website traffic insights' },
  settings: { title: 'Settings', subtitle: 'API keys and integrations' },
};

const PAGE_COMPONENTS = {
  dashboard: Dashboard,
  notices: NoticesPage,
  media: MediaPage,
  giving: GivingPage,
  events: EventsPage,
  users: UsersPage,
  societies: SocietiesPage,
  districts: DistrictsPage,
  circuits: CircuitsPage,
  ministers: MinistersPage,
  transactions: TransactionsPage,
  marketplace: MarketplacePage,
  tickets: TicketsPage,
  analytics: AnalyticsPage,
  settings: SettingsPage,
};

function AdminApp() {
  const [activePage, setActivePage] = useState('dashboard');
  const { user } = useAuth();
  const info = PAGE_TITLES[activePage] || {};
  const PageComponent = PAGE_COMPONENTS[activePage] || Dashboard;

  if (!user) return <LoginPage />;

  return (
    <div className="admin-layout">
      <Sidebar activePage={activePage} setActivePage={setActivePage} />
      <main className="main-content">
        <header className="topbar">
          <div className="topbar-title">
            <h2>{info.title}</h2>
            <p>{info.subtitle}</p>
          </div>
          <div className="topbar-actions">
            <span style={{ fontSize: 13, color: 'var(--text-secondary)' }}>
              {new Date().toLocaleDateString('en-ZA', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}
            </span>
          </div>
        </header>
        <div className="page-content">
          <PageComponent />
        </div>
      </main>
    </div>
  );
}

export default function App() {
  const { loading } = useAuth();
  if (loading) return (
    <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div className="spinner" />
    </div>
  );
  return <AdminApp />;
}
