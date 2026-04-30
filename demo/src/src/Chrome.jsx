// Status bar (iOS style), bottom nav
const StatusBar = () => (
  <div className="statusbar" data-screen-label="statusbar">
    <span>9:41</span>
    <div className="icons">
      {/* signal */}
      <svg width="18" height="12" viewBox="0 0 18 12" fill="currentColor"><rect x="0" y="8" width="3" height="4" rx="1"/><rect x="5" y="5" width="3" height="7" rx="1"/><rect x="10" y="2" width="3" height="10" rx="1"/><rect x="15" y="0" width="3" height="12" rx="1"/></svg>
      {/* wifi */}
      <svg width="16" height="12" viewBox="0 0 16 12" fill="none" stroke="currentColor" strokeWidth="1.8" strokeLinecap="round"><path d="M1 4a10 10 0 0 1 14 0"/><path d="M4 7a6 6 0 0 1 8 0"/><circle cx="8" cy="10" r="1" fill="currentColor" stroke="none"/></svg>
      {/* battery */}
      <svg width="26" height="12" viewBox="0 0 26 12" fill="none" stroke="currentColor" strokeWidth="1.2"><rect x="0.6" y="0.6" width="22" height="10.8" rx="2.4"/><rect x="24" y="4" width="1.6" height="4" rx="1" fill="currentColor"/><rect x="2" y="2" width="18" height="8" rx="1.4" fill="currentColor"/></svg>
    </div>
  </div>
);

const BottomNav = ({ active, onNav }) => {
  const items = [
    { key: 'home', label: 'Trang chủ', icon: 'home' },
    { key: 'flash', label: 'Từ vựng', icon: 'cards' },
    { key: 'ai', label: 'AI', icon: 'mic' },
    { key: 'achieve', label: 'Thành tích', icon: 'trophy' },
    { key: 'profile', label: 'Cá nhân', icon: 'user' },
  ];
  return (
    <div className="bottomnav">
      {items.map(it => (
        <button
          key={it.key}
          className={active === it.key ? 'active' : ''}
          onClick={() => onNav && onNav(it.key)}
        >
          <Icon name={it.icon} size={26}/>
          {it.label}
        </button>
      ))}
    </div>
  );
};

// Small chunky back button
const BackBtn = ({ onClick }) => (
  <button
    onClick={onClick}
    style={{
      width: 40, height: 40, borderRadius: 12,
      border: '2px solid var(--border)', background: 'var(--surface)',
      color: 'var(--text-muted)', cursor: 'pointer',
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      boxShadow: 'var(--shadow-btn-white)',
    }}
  >
    <Icon name="chevron-left" size={22}/>
  </button>
);

Object.assign(window, { StatusBar, BottomNav, BackBtn });
