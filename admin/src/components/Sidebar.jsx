import { useState } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { FiHome, FiUsers, FiVideo, FiBell, FiShoppingBag, FiHeart, FiSettings,
         FiLogOut, FiMessageSquare, FiCalendar, FiDollarSign, FiMapPin, FiBarChart2, FiMap, FiLayers, FiMail } from 'react-icons/fi';

const navItems = [
  { section: 'Overview', items: [
    { id: 'dashboard', label: 'Dashboard', icon: FiHome },
  ]},
  { section: 'Content', items: [
    { id: 'notices', label: 'Notices', icon: FiBell },
    { id: 'media', label: 'Media / Videos', icon: FiVideo },
    { id: 'events', label: 'Events', icon: FiCalendar },
    { id: 'giving', label: 'Giving Options', icon: FiHeart },
  ]},
  { section: 'Community', items: [
    { id: 'users', label: 'Users', icon: FiUsers },
    { id: 'districts', label: 'Districts', icon: FiMap },
    { id: 'circuits', label: 'Circuits', icon: FiLayers },
    { id: 'societies', label: 'Societies', icon: FiMapPin },
    { id: 'ministers', label: 'Ministers', icon: FiUsers },
    { id: 'transactions', label: 'Transactions', icon: FiDollarSign },
    { id: 'marketplace', label: 'Marketplace', icon: FiShoppingBag },
    { id: 'testing', label: 'Testing Program', icon: FiMail },
  ]},
  { section: 'Support & Admin', items: [
    { id: 'tickets', label: 'Support Tickets', icon: FiMessageSquare },
    { id: 'analytics', label: 'Analytics', icon: FiBarChart2 },
    { id: 'settings', label: 'Settings', icon: FiSettings },
  ]},
];

export default function Sidebar({ activePage, setActivePage }) {
  const { user, logout } = useAuth();

  const initial = user?.email?.[0]?.toUpperCase() || 'A';

  return (
    <aside className="sidebar">
      <div className="sidebar-logo">
        <h1>Tingungu<span>.</span></h1>
        <p>Admin Portal</p>
      </div>

      <nav className="sidebar-nav">
        {navItems.map(({ section, items }) => (
          <div key={section}>
            <p className="nav-section-label">{section}</p>
            {items.map(({ id, label, icon: Icon }) => (
              <div
                key={id}
                className={`nav-item ${activePage === id ? 'active' : ''}`}
                onClick={() => setActivePage(id)}
              >
                <Icon />
                {label}
              </div>
            ))}
          </div>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="sidebar-user">
          <div className="sidebar-avatar">{initial}</div>
          <div className="sidebar-user-info">
            <p>Administrator</p>
            <span>{user?.email}</span>
          </div>
        </div>
        <button className="btn-logout" onClick={logout}>
          <FiLogOut size={14} /> Sign Out
        </button>
      </div>
    </aside>
  );
}
