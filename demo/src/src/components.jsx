/* Shared UI primitives + mascot for EnglishMe */

/* ── Mascot: "Echo" the parrot — SVG, scalable ── */
function Mascot({ size = 80, mood = "happy", style = {} }) {
  // mood: happy | wink | sleepy | proud | worried | cheer
  const eyeR = 5;
  const mouth = {
    happy:   <path d="M38 58 Q48 66 58 58" stroke="#5B3A00" strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
    wink:    <path d="M38 58 Q48 66 58 58" stroke="#5B3A00" strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
    sleepy:  <path d="M40 60 L56 60" stroke="#5B3A00" strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
    proud:   <path d="M38 58 Q48 68 58 58" stroke="#5B3A00" strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
    worried: <path d="M40 62 Q48 56 56 62" stroke="#5B3A00" strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
    cheer:   <path d="M36 56 Q48 70 60 56 Q48 62 36 56 Z" fill="#5B3A00"/>,
  }[mood];
  const lEye = mood === "wink"
    ? <path d="M34 44 L40 44" stroke="#1A1A1A" strokeWidth="3" strokeLinecap="round"/>
    : <circle cx="37" cy="44" r={eyeR} fill="#1A1A1A"/>;
  const rEye = mood === "sleepy"
    ? <path d="M54 44 L60 44" stroke="#1A1A1A" strokeWidth="3" strokeLinecap="round"/>
    : <circle cx="57" cy="44" r={eyeR} fill="#1A1A1A"/>;
  return (
    <svg width={size} height={size} viewBox="0 0 96 96" style={style}>
      {/* body */}
      <ellipse cx="48" cy="58" rx="32" ry="30" fill="var(--teal-500)"/>
      <ellipse cx="48" cy="62" rx="22" ry="20" fill="var(--teal-100)"/>
      {/* wing */}
      <path d="M20 54 Q14 64 22 74 Q28 70 28 58 Z" fill="var(--teal-600)"/>
      {/* head feathers */}
      <path d="M38 22 Q40 12 46 18 Q48 10 52 18 Q54 10 58 20 Q60 30 48 30 Z" fill="var(--teal-400)"/>
      {/* eyes */}
      <circle cx="37" cy="44" r="8" fill="#fff"/>
      <circle cx="57" cy="44" r="8" fill="#fff"/>
      {lEye}{rEye}
      {/* beak */}
      <path d="M43 50 Q48 56 53 50 Q48 54 43 50 Z" fill="var(--accent)" stroke="#D99428" strokeWidth="1"/>
      <path d="M44 51 Q48 57 52 51 L48 54 Z" fill="#E89A1F"/>
      {/* mouth under beak */}
      {mouth}
      {/* cheeks */}
      <circle cx="28" cy="52" r="4" fill="#FF8FB1" opacity="0.55"/>
      <circle cx="68" cy="52" r="4" fill="#FF8FB1" opacity="0.55"/>
      {/* feet */}
      <path d="M40 88 L40 92 M44 88 L44 92" stroke="#D99428" strokeWidth="3" strokeLinecap="round"/>
      <path d="M52 88 L52 92 M56 88 L56 92" stroke="#D99428" strokeWidth="3" strokeLinecap="round"/>
    </svg>
  );
}

/* ── Icons — stroke-based, consistent 24 ── */
const Icon = {
  Home: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M4 11L12 4l8 7v9a1 1 0 01-1 1h-5v-6h-4v6H5a1 1 0 01-1-1v-9z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/></svg>,
  Learn: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M4 6l8-3 8 3v10l-8 3-8-3V6z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/><path d="M4 6l8 3 8-3M12 9v10" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/></svg>,
  AI: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M12 3l2 4 4 2-4 2-2 4-2-4-4-2 4-2 2-4z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/><circle cx="19" cy="17" r="2" stroke="currentColor" strokeWidth="2.2"/></svg>,
  Trophy: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M6 4h12v4a6 6 0 01-12 0V4zM4 5h2v3a3 3 0 01-3-3h1zm16 0h1a3 3 0 01-3 3V5h2zM9 18h6l1 3H8l1-3zm3-4v4" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/></svg>,
  User: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><circle cx="12" cy="8" r="4" stroke="currentColor" strokeWidth="2.2"/><path d="M4 20c1.5-4 4.5-6 8-6s6.5 2 8 6" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>,
  Flame: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M12 3s4 4 4 8a4 4 0 01-8 0c0-2 1-3 1-3s0 3 2 3 1-3 1-5zm0 18a6 6 0 006-6c0 4-2 7-6 7s-6-3-6-7a6 6 0 006 6z" fill="#FF6B4A"/></svg>,
  Bolt: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z" fill="#FDBA38" stroke="#D99428" strokeWidth="1.5" strokeLinejoin="round"/></svg>,
  Check: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M4 12l5 5L20 6" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  X: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M6 6l12 12M18 6L6 18" stroke="currentColor" strokeWidth="3" strokeLinecap="round"/></svg>,
  ChevronLeft: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M15 6l-6 6 6 6" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  ChevronRight: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M9 6l6 6-6 6" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  Speaker: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M5 9h4l5-4v14l-5-4H5V9z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round" fill="currentColor"/><path d="M17 9a5 5 0 010 6M19 6a9 9 0 010 12" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>,
  Play: (p) => <svg viewBox="0 0 24 24" fill="currentColor" {...p}><path d="M7 4l14 8-14 8V4z"/></svg>,
  Pause: (p) => <svg viewBox="0 0 24 24" fill="currentColor" {...p}><rect x="6" y="4" width="4" height="16" rx="1"/><rect x="14" y="4" width="4" height="16" rx="1"/></svg>,
  Mic: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><rect x="9" y="3" width="6" height="12" rx="3" stroke="currentColor" strokeWidth="2.2" fill="currentColor"/><path d="M5 11a7 7 0 0014 0M12 18v3" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>,
  Replay: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M4 12a8 8 0 108-8 8 8 0 00-6 2.7M4 4v4h4" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>,
  Google: (p) => <svg viewBox="0 0 24 24" {...p}><path d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.9h5.4a4.6 4.6 0 01-2 3v2.5h3.3c1.9-1.8 3-4.4 3-7.4z" fill="#4285F4"/><path d="M12 22c2.7 0 5-.9 6.7-2.4l-3.3-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.8-5.6-4.1H3v2.6A10 10 0 0012 22z" fill="#34A853"/><path d="M6.4 14a6 6 0 010-4V7.4H3A10 10 0 003 16.6L6.4 14z" fill="#FBBC05"/><path d="M12 5.9a5.4 5.4 0 013.8 1.5l2.9-2.9A10 10 0 003 7.4L6.4 10c.8-2.4 3-4.1 5.6-4.1z" fill="#EA4335"/></svg>,
  Warning: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M12 3l10 18H2L12 3z" fill="#FDBA38" stroke="#D99428" strokeWidth="1.5" strokeLinejoin="round"/><path d="M12 10v5M12 18v.5" stroke="#5B3A00" strokeWidth="2.5" strokeLinecap="round"/></svg>,
  Heart: (p) => <svg viewBox="0 0 24 24" fill="#FF4B4B" {...p}><path d="M12 21s-8-5-8-11a5 5 0 019-3 5 5 0 019 3c0 6-8 11-8 11h-2z"/></svg>,
  Trophy2: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M6 3h12v5a6 6 0 01-12 0V3z" fill="#FDBA38" stroke="#D99428" strokeWidth="1.8"/><path d="M3 5h3v3a3 3 0 01-3-3zm15 0h3a3 3 0 01-3 3V5z" stroke="#D99428" strokeWidth="1.8"/><path d="M9 20h6l-1-4h-4l-1 4zm3-6v2" stroke="#B8820F" strokeWidth="2" strokeLinecap="round"/></svg>,
  Lock: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><rect x="5" y="11" width="14" height="10" rx="2" stroke="currentColor" strokeWidth="2.2"/><path d="M8 11V7a4 4 0 118 0v4" stroke="currentColor" strokeWidth="2.2"/></svg>,
  Target: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2.2"/><circle cx="12" cy="12" r="5" stroke="currentColor" strokeWidth="2.2"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/></svg>,
  Settings: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="2.2"/><path d="M19.4 15a1.7 1.7 0 00.3 1.8l.1.1a2 2 0 11-2.8 2.8l-.1-.1a1.7 1.7 0 00-1.8-.3 1.7 1.7 0 00-1 1.5V21a2 2 0 11-4 0v-.1a1.7 1.7 0 00-1-1.5 1.7 1.7 0 00-1.8.3l-.1.1a2 2 0 11-2.8-2.8l.1-.1a1.7 1.7 0 00.3-1.8 1.7 1.7 0 00-1.5-1H3a2 2 0 110-4h.1a1.7 1.7 0 001.5-1 1.7 1.7 0 00-.3-1.8l-.1-.1a2 2 0 112.8-2.8l.1.1a1.7 1.7 0 001.8.3h0a1.7 1.7 0 001-1.5V3a2 2 0 114 0v.1a1.7 1.7 0 001 1.5 1.7 1.7 0 001.8-.3l.1-.1a2 2 0 112.8 2.8l-.1.1a1.7 1.7 0 00-.3 1.8v0a1.7 1.7 0 001.5 1H21a2 2 0 110 4h-.1a1.7 1.7 0 00-1.5 1z" stroke="currentColor" strokeWidth="2"/></svg>,
  Edit: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M4 20h4l10-10-4-4L4 16v4z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round"/></svg>,
  Eye: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12z" stroke="currentColor" strokeWidth="2.2"/><circle cx="12" cy="12" r="3" stroke="currentColor" strokeWidth="2.2"/></svg>,
  EyeOff: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M3 3l18 18M9.9 5.1A10 10 0 0112 5c6.5 0 10 7 10 7a17 17 0 01-3.2 4.3M6.6 6.6A17 17 0 002 12s3.5 7 10 7a10 10 0 004.6-1.1" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>,
  Send: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><path d="M3 11l18-8-8 18-2-8-8-2z" stroke="currentColor" strokeWidth="2.2" strokeLinejoin="round" fill="currentColor"/></svg>,
  Calendar: (p) => <svg viewBox="0 0 24 24" fill="none" {...p}><rect x="3" y="5" width="18" height="16" rx="2" stroke="currentColor" strokeWidth="2.2"/><path d="M3 9h18M8 3v4M16 3v4" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"/></svg>,
};

/* ── Status bar ── */
function StatusBar() {
  return (
    <div className="status-bar">
      <div>9:41</div>
      <div style={{display:"flex", gap:6, alignItems:"center"}}>
        <svg width="18" height="12" viewBox="0 0 18 12"><rect x="0" y="7" width="3" height="5" rx="0.5" fill="currentColor"/><rect x="5" y="4" width="3" height="8" rx="0.5" fill="currentColor"/><rect x="10" y="2" width="3" height="10" rx="0.5" fill="currentColor"/><rect x="15" y="0" width="3" height="12" rx="0.5" fill="currentColor"/></svg>
        <svg width="16" height="12" viewBox="0 0 16 12"><path d="M8 3a7 7 0 014.9 2L14 3.9A9 9 0 008 1.5 9 9 0 002 3.9L3.1 5A7 7 0 018 3z" fill="currentColor"/><path d="M8 6a4 4 0 012.8 1.2L12 6a6 6 0 00-8 0l1.2 1.2A4 4 0 018 6zm0 3a1.5 1.5 0 100 3 1.5 1.5 0 000-3z" fill="currentColor"/></svg>
        <svg width="26" height="12" viewBox="0 0 26 12"><rect x="0" y="0" width="22" height="12" rx="3" stroke="currentColor" strokeWidth="1" fill="none" opacity="0.4"/><rect x="2" y="2" width="16" height="8" rx="1.5" fill="currentColor"/><rect x="23" y="4" width="2" height="4" rx="0.5" fill="currentColor" opacity="0.4"/></svg>
      </div>
    </div>
  );
}

/* ── Bottom nav ── */
function BottomNav({ active, onChange }) {
  const items = [
    { id: "home", label: "Trang chủ", Icon: Icon.Home },
    { id: "learn", label: "Học", Icon: Icon.Learn },
    { id: "ai", label: "AI", Icon: Icon.AI },
    { id: "achievements", label: "Thành tích", Icon: Icon.Trophy },
    { id: "profile", label: "Hồ sơ", Icon: Icon.User },
  ];
  return (
    <div className="bottom-nav">
      {items.map(it => (
        <button key={it.id} className={"nav-item" + (active === it.id ? " active" : "")} onClick={() => onChange(it.id)}>
          <it.Icon />
          <span>{it.label}</span>
        </button>
      ))}
    </div>
  );
}

/* ── Toast ── */
function Toast({ type = "success", children }) {
  return (
    <div className={"toast " + type}>
      {type === "success" && <Icon.Check width="20" height="20" />}
      {type === "error" && <Icon.Warning width="20" height="20" />}
      <span>{children}</span>
    </div>
  );
}

/* ── Chunky header with streak + XP ── */
function TopStats({ streak = 7, xp = 240, hearts = 5, theme }) {
  return (
    <div style={{display:"flex", alignItems:"center", gap: 12, padding: "10px 20px 8px"}}>
      <div style={{display:"flex", alignItems:"center", gap:4, fontWeight: 900, color: "var(--accent-2)"}}>
        <Icon.Flame width="26" height="26" /> <span style={{fontSize:18}}>{streak}</span>
      </div>
      <div style={{display:"flex", alignItems:"center", gap:4, fontWeight: 900, color: "#B8820F"}}>
        <Icon.Bolt width="26" height="26" /> <span style={{fontSize:18}}>{xp}</span>
      </div>
      <div style={{flex:1}}/>
      <div style={{display:"flex", alignItems:"center", gap:4, fontWeight: 900, color: "var(--red)"}}>
        <Icon.Heart width="24" height="24" /> <span style={{fontSize:18}}>{hearts}</span>
      </div>
    </div>
  );
}

/* ── Progress ── */
function Progress({ value = 0, color }) {
  return (
    <div className="progress">
      <div style={{ width: `${value}%`, background: color || 'var(--green)' }} />
    </div>
  );
}

/* ── CEFR Badge ── */
function CefrBadge({ level = "B1", size = 120 }) {
  const colors = {
    A1: ["#58CC02", "#3FA000"],
    A2: ["#1CB0F6", "#0A8ACF"],
    B1: ["#A855F7", "#7E3BCB"],
    B2: ["#FF8FB1", "#D96081"],
    C1: ["#FDBA38", "#D99428"],
  }[level] || ["#58CC02", "#3FA000"];
  return (
    <div style={{
      width: size, height: size, borderRadius: "50%",
      background: `radial-gradient(circle at 30% 25%, ${colors[0]}, ${colors[1]})`,
      display:"flex", alignItems:"center", justifyContent:"center",
      color:"#fff", fontWeight: 900, fontSize: size * 0.42,
      fontFamily: "var(--font-display)",
      boxShadow: `0 8px 0 0 ${colors[1]}, 0 16px 30px rgba(15,23,42,0.18)`,
      border: "6px solid #fff",
      letterSpacing: "-1px",
    }}>
      {level}
    </div>
  );
}

Object.assign(window, {
  Mascot, Icon, StatusBar, BottomNav, Toast, TopStats, Progress, CefrBadge,
});
