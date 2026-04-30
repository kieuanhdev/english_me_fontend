// Welcome / Login / Register screen
const Welcome = ({ onEnter }) => {
  const [mode, setMode] = React.useState('welcome'); // welcome | login | register

  if (mode === 'welcome') {
    return (
      <div className="screen" data-screen-label="01 Welcome">
        <StatusBar />
        <div style={{padding: '40px 28px 24px', textAlign: 'center'}}>
          {/* logo lockup */}
          <div style={{display:'flex', alignItems:'center', justifyContent:'center', gap:8, marginBottom:48}}>
            <span style={{
              fontFamily:'var(--font-display)', fontWeight:800, fontSize:22,
              color:'var(--primary)', letterSpacing:'-.01em'
            }}>EnglishMe</span>
          </div>

          <div className="pop-in" style={{marginBottom: 32, display:'flex', justifyContent:'center'}}>
            <Mascot variant="wave" size={200}/>
          </div>

          <h1 style={{fontSize: 30, fontWeight: 800, lineHeight: 1.15, marginBottom: 14, textWrap:'balance'}}>
            Học tiếng Anh miễn phí<br/>
            <span style={{color:'var(--primary)'}}>vui hơn mỗi ngày</span>
          </h1>
          <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:15, marginBottom:40, textWrap:'pretty'}}>
            Cá nhân hóa theo trình độ. Học từ vựng theo phương pháp SM-2, luyện phát âm cùng AI.
          </p>

          <button className="btn btn-primary btn-block btn-lg" onClick={() => setMode('register')} style={{marginBottom: 12}}>
            Bắt đầu
          </button>
          <button className="btn btn-white btn-block btn-lg" onClick={() => setMode('login')}>
            Tôi đã có tài khoản
          </button>

          <div style={{display:'flex', alignItems:'center', justifyContent:'center', gap:8, marginTop:28, color:'var(--text-muted)', fontSize:12, fontWeight:700}}>
            <Icon name="globe" size={16}/> Tiếng Việt
          </div>
        </div>
      </div>
    );
  }

  // Login / Register form
  const isLogin = mode === 'login';
  return (
    <div className="screen" data-screen-label={isLogin ? '01b Login' : '01a Register'}>
      <StatusBar />
      <div style={{padding: '8px 20px 24px', display:'flex', alignItems:'center', gap: 12}}>
        <BackBtn onClick={() => setMode('welcome')}/>
        <div style={{flex:1, height:12, background:'var(--ink-200)', borderRadius:999, overflow:'hidden'}}>
          <div style={{width: '30%', height:'100%', background:'var(--primary)', borderRadius:999}}/>
        </div>
      </div>

      <div style={{padding: '16px 28px 28px'}}>
        <h1 style={{fontSize: 26, fontWeight: 800, marginBottom: 6}}>
          {isLogin ? 'Chào mừng trở lại!' : 'Tạo tài khoản'}
        </h1>
        <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:14, marginBottom: 24}}>
          {isLogin ? 'Đăng nhập để tiếp tục lộ trình học của bạn.' : 'Chỉ cần vài bước để bắt đầu học.'}
        </p>

        {!isLogin && (
          <div style={{marginBottom: 14}}>
            <label style={lbl}>Tên hiển thị</label>
            <input className="input" placeholder="Minh Anh" defaultValue="Minh Anh"/>
          </div>
        )}
        <div style={{marginBottom: 14}}>
          <label style={lbl}>Email</label>
          <input className="input" type="email" placeholder="ban@vidu.com" defaultValue="minhanh@englishme.vn"/>
        </div>
        <div style={{marginBottom: isLogin ? 8 : 14}}>
          <label style={lbl}>Mật khẩu</label>
          <input className="input" type="password" placeholder="••••••••" defaultValue="password123"/>
        </div>
        {!isLogin && (
          <div style={{marginBottom: 14}}>
            <label style={lbl}>Xác nhận mật khẩu</label>
            <input className="input" type="password" placeholder="••••••••" defaultValue="password123"/>
          </div>
        )}
        {isLogin && (
          <div style={{textAlign:'right', marginBottom:18}}>
            <button className="btn btn-ghost" style={{padding:'6px 0', fontSize:13}}>Quên mật khẩu?</button>
          </div>
        )}

        <button className="btn btn-primary btn-block btn-lg" style={{marginBottom:16}} onClick={onEnter}>
          {isLogin ? 'Đăng nhập' : 'Đăng ký'}
        </button>

        <div style={{display:'flex', alignItems:'center', gap:10, margin:'18px 0', color:'var(--text-muted)', fontSize:12, fontWeight:700}}>
          <div style={{flex:1, height:2, background:'var(--border)'}}/>
          HOẶC
          <div style={{flex:1, height:2, background:'var(--border)'}}/>
        </div>

        <button className="btn btn-white btn-block" style={{textTransform:'none', fontSize:15}}>
          <svg width="20" height="20" viewBox="0 0 20 20"><path fill="#4285F4" d="M19.6 10.23c0-.71-.06-1.4-.18-2.06H10v3.9h5.38a4.6 4.6 0 0 1-2 3.02v2.51h3.23c1.89-1.74 2.98-4.3 2.98-7.37z"/><path fill="#34A853" d="M10 20c2.7 0 4.96-.9 6.6-2.43l-3.22-2.5c-.9.6-2.04.96-3.38.96-2.6 0-4.8-1.75-5.6-4.11H1.08v2.58A10 10 0 0 0 10 20z"/><path fill="#FBBC05" d="M4.4 11.92a6 6 0 0 1 0-3.83V5.51H1.08a10 10 0 0 0 0 8.98z"/><path fill="#EA4335" d="M10 3.96c1.47 0 2.79.5 3.83 1.5l2.87-2.87C14.96.98 12.7 0 10 0A10 10 0 0 0 1.08 5.51L4.4 8.08C5.2 5.71 7.4 3.96 10 3.96z"/></svg>
          Tiếp tục với Google
        </button>

        <p style={{textAlign:'center', marginTop:20, color:'var(--text-muted)', fontSize:13, fontWeight:600}}>
          {isLogin ? 'Chưa có tài khoản? ' : 'Đã có tài khoản? '}
          <button className="btn btn-ghost" style={{padding:0, fontSize:13}} onClick={() => setMode(isLogin ? 'register' : 'login')}>
            {isLogin ? 'Đăng ký' : 'Đăng nhập'}
          </button>
        </p>
      </div>
    </div>
  );
};

const lbl = {
  display:'block',
  fontSize:12, fontWeight:700, textTransform:'uppercase',
  color:'var(--text-muted)', letterSpacing:'.06em',
  marginBottom:6, marginLeft:4,
  fontFamily:'var(--font-display)',
};

window.Welcome = Welcome;
