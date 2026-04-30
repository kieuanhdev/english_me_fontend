// App shell — screen switcher + tweaks panel + routing
const { useState, useEffect } = React;

const THEMES = {
  teal:   { primary:'#0EA5A4', dark:'#086B6B', soft:'#E6FAF9', accent:'#FDBA38' },
  violet: { primary:'#6D5BFF', dark:'#3F2FD1', soft:'#EEEBFF', accent:'#FF8FB1' },
  coral:  { primary:'#FF6B4A', dark:'#C3452C', soft:'#FFEAE3', accent:'#FFD166' },
  lime:   { primary:'#65A30D', dark:'#3F6212', soft:'#ECFCCB', accent:'#FDBA38' },
};

function applyTheme(name, dark) {
  const t = THEMES[name] || THEMES.teal;
  const r = document.documentElement;
  r.style.setProperty('--primary', t.primary);
  r.style.setProperty('--primary-dark', t.dark);
  r.style.setProperty('--primary-soft', dark ? shade(t.primary, -50) : t.soft);
  r.style.setProperty('--accent', t.accent);
  r.style.setProperty('--shadow-btn', `0 4px 0 0 ${t.dark}`);
  r.dataset.theme = dark ? 'dark' : 'light';
}
function shade(hex, pct) { return hex; }

const SCREENS = [
  { key:'welcome',  label:'Welcome / Auth' },
  { key:'placement',label:'Placement Test' },
  { key:'home',     label:'Dashboard' },
  { key:'flash',    label:'Flashcard' },
];

function App() {
  const saved = (() => { try { return JSON.parse(localStorage.getItem('em_state') || '{}'); } catch { return {}; } })();
  const [screen, setScreen] = useState(saved.screen || 'welcome');
  const [tweaksOn, setTweaksOn] = useState(false);
  const [theme, setTheme] = useState(window.__TWEAKS__.primary || 'teal');
  const [dark, setDark] = useState(!!window.__TWEAKS__.dark);

  useEffect(() => { applyTheme(theme, dark); }, [theme, dark]);
  useEffect(() => { localStorage.setItem('em_state', JSON.stringify({ screen })); }, [screen]);

  // Tweaks protocol
  useEffect(() => {
    const handler = (e) => {
      if (!e.data || typeof e.data !== 'object') return;
      if (e.data.type === '__activate_edit_mode') setTweaksOn(true);
      if (e.data.type === '__deactivate_edit_mode') setTweaksOn(false);
    };
    window.addEventListener('message', handler);
    window.parent.postMessage({ type:'__edit_mode_available' }, '*');
    return () => window.removeEventListener('message', handler);
  }, []);

  const persist = (edits) => {
    window.parent.postMessage({ type:'__edit_mode_set_keys', edits }, '*');
  };

  const nav = (key) => {
    // bottom-nav hooks
    if (key === 'flash') setScreen('flash');
    else if (key === 'home') setScreen('home');
    else setScreen('home'); // ai/achieve/profile not built in this batch
  };

  let content;
  if (screen === 'welcome') {
    content = <Welcome onEnter={() => setScreen('placement')}/>;
  } else if (screen === 'placement') {
    content = <Placement onFinish={() => setScreen('home')} onBack={() => setScreen('welcome')}/>;
  } else if (screen === 'home') {
    content = <Dashboard onOpenFlash={() => setScreen('flash')} onNav={nav}/>;
  } else if (screen === 'flash') {
    content = <Flashcard onBack={() => setScreen('home')}/>;
  }

  return (
    <>
      {/* Screen switcher */}
      <div className="switcher">
        <h4>Màn hình</h4>
        {SCREENS.map((s, i) => (
          <button
            key={s.key}
            className={'switcher-btn' + (screen === s.key || (s.key === 'welcome' && screen === 'welcome') ? ' active' : '')}
            onClick={() => setScreen(s.key)}
          >
            <span className="num">{String(i+1).padStart(2,'0')}</span>{s.label}
          </button>
        ))}
        <div style={{marginTop:10, padding:'8px 10px', fontSize:11, color:'#7B8FA3', lineHeight:1.4, fontWeight:600}}>
          Prototype tương tác — nhấn vào các nút bên trong để điều hướng.
        </div>
      </div>

      <div className="stage">
        <div className="phone">
          {content}
        </div>
      </div>

      {/* Tweaks */}
      {tweaksOn && (
        <div className="tweaks">
          <h4>Tweaks</h4>
          <div className="tweak-row">
            <label>Màu chủ đạo</label>
            <div className="swatches">
              {Object.entries(THEMES).map(([k, t]) => (
                <button
                  key={k}
                  className={'swatch' + (theme === k ? ' active' : '')}
                  style={{background: t.primary}}
                  onClick={() => { setTheme(k); persist({ primary:k }); }}
                />
              ))}
            </div>
          </div>
          <div className="tweak-row">
            <div className={'toggle' + (dark ? ' on' : '')} onClick={() => { setDark(!dark); persist({ dark: !dark }); }}>
              <span>Chế độ tối</span>
              <div className="track"/>
            </div>
          </div>
        </div>
      )}
    </>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
