/* EnglishMe — Auth screens: Welcome, SignUp, Login */

function WelcomeScreen({ goto }) {
  return (
    <div className="screen" style={{background: "linear-gradient(180deg, var(--teal-50) 0%, var(--bg) 40%)"}}>
      <StatusBar/>
      <div className="screen-scroll" style={{padding:"0 24px"}}>
        <div style={{display:"flex", flexDirection:"column", alignItems:"center", marginTop: 40}}>
          <Mascot size={150} mood="cheer"/>
          <div style={{marginTop: 14, fontFamily:"var(--font-display)", fontWeight: 900, fontSize: 36, color:"var(--teal-700)", letterSpacing:"-0.5px"}}>EnglishMe</div>
          <div style={{color:"var(--ink-500)", fontSize: 14, fontWeight: 700, letterSpacing: "2px"}}>HỌC TIẾNG ANH CÙNG ECHO</div>
        </div>
        <div style={{marginTop: 48, textAlign: "center"}}>
          <div className="h1" style={{fontSize: 26, marginBottom: 10}}>Học mỗi ngày.<br/>Tiến bộ mỗi tuần.</div>
          <div className="body" style={{padding: "0 10px"}}>Lộ trình cá nhân hoá theo trình độ CEFR, từ A1 đến C1 — miễn phí.</div>
        </div>
        <div style={{marginTop:36, display:"flex", flexDirection:"column", gap: 12}}>
          <div style={{display:"flex", gap: 16, justifyContent:"center", marginBottom: 8}}>
            {["A1","A2","B1","B2","C1"].map(l => (
              <div key={l} style={{
                width: 40, height: 40, borderRadius: "50%",
                background: l==="A1"?"var(--green)":l==="A2"?"var(--blue)":l==="B1"?"var(--purple)":l==="B2"?"var(--pink)":"var(--accent)",
                color:"#fff", display:"flex", alignItems:"center", justifyContent:"center",
                fontWeight: 900, fontSize: 13, fontFamily:"var(--font-display)",
                boxShadow: "0 3px 0 rgba(0,0,0,0.15)",
              }}>{l}</div>
            ))}
          </div>
        </div>
      </div>
      <div style={{padding: "16px 24px 28px", display:"flex", flexDirection:"column", gap:12}}>
        <button className="btn btn-primary" onClick={() => goto("signup")}>Bắt đầu học</button>
        <button className="btn btn-secondary" onClick={() => goto("login")}>Tôi đã có tài khoản</button>
      </div>
    </div>
  );
}

function SignUpScreen({ goto }) {
  const [email, setEmail] = React.useState("");
  const [pw, setPw] = React.useState("");
  const [pw2, setPw2] = React.useState("");
  const [errors, setErrors] = React.useState({});
  const [toast, setToast] = React.useState(null);
  const [show, setShow] = React.useState(false);

  const submit = () => {
    const e = {};
    if (!email.includes("@")) e.email = "Email không hợp lệ";
    else if (email === "duplicate@test.com") e.email = "Email đã được sử dụng. Thử email khác.";
    if (pw.length < 6) e.pw = "Mật khẩu cần ít nhất 6 ký tự";
    if (pw !== pw2) e.pw2 = "Mật khẩu xác nhận không khớp";
    setErrors(e);
    if (Object.keys(e).length === 0) {
      setToast({type:"success", msg:"Đăng ký thành công! Đang thiết lập..."});
      setTimeout(() => goto("placement-intro"), 900);
    }
  };

  return (
    <div className="screen">
      <StatusBar/>
      {toast && <Toast type={toast.type}>{toast.msg}</Toast>}
      <div className="screen-scroll" style={{padding:"0 24px"}}>
        <button onClick={() => goto("welcome")} style={{background:"none", border:"none", padding:"10px 0", cursor:"pointer", color:"var(--ink-700)"}}>
          <Icon.ChevronLeft width="28" height="28"/>
        </button>
        <div style={{display:"flex", alignItems:"center", gap: 14, marginBottom: 8}}>
          <Mascot size={64} mood="happy"/>
          <div>
            <div className="h1" style={{fontSize: 24}}>Tạo tài khoản</div>
            <div className="muted" style={{fontSize: 13}}>Miễn phí mãi mãi, không quảng cáo.</div>
          </div>
        </div>
        <div style={{marginTop: 20, display:"flex", flexDirection:"column", gap: 16}}>
          <div>
            <div className="field-label">Email</div>
            <input className={"field" + (errors.email?" error":"")} type="email" placeholder="ban@email.com" value={email} onChange={e=>setEmail(e.target.value)}/>
            {errors.email && <div className="field-error"><Icon.Warning width="14" height="14"/> {errors.email}</div>}
          </div>
          <div>
            <div className="field-label">Mật khẩu</div>
            <div style={{position:"relative"}}>
              <input className={"field" + (errors.pw?" error":"")} type={show?"text":"password"} placeholder="Ít nhất 6 ký tự" value={pw} onChange={e=>setPw(e.target.value)} style={{paddingRight: 48}}/>
              <button onClick={()=>setShow(!show)} style={{position:"absolute", right:14, top:14, background:"none", border:"none", cursor:"pointer", color:"var(--ink-500)"}}>
                {show ? <Icon.EyeOff width="22" height="22"/> : <Icon.Eye width="22" height="22"/>}
              </button>
            </div>
            {errors.pw && <div className="field-error"><Icon.Warning width="14" height="14"/> {errors.pw}</div>}
          </div>
          <div>
            <div className="field-label">Xác nhận mật khẩu</div>
            <input className={"field" + (errors.pw2?" error":"")} type={show?"text":"password"} placeholder="Nhập lại mật khẩu" value={pw2} onChange={e=>setPw2(e.target.value)}/>
            {errors.pw2 && <div className="field-error"><Icon.Warning width="14" height="14"/> {errors.pw2}</div>}
          </div>
          <div className="muted" style={{fontSize: 12, lineHeight: 1.5}}>
            Bằng việc đăng ký, bạn đồng ý với <span className="link">Điều khoản</span> và <span className="link">Chính sách bảo mật</span> của EnglishMe.
          </div>
        </div>
      </div>
      <div style={{padding: "16px 24px 28px", display:"flex", flexDirection:"column", gap:12}}>
        <button className="btn btn-primary" onClick={submit}>Đăng ký</button>
        <div style={{textAlign:"center", fontSize:14, fontWeight: 700, color:"var(--ink-500)"}}>
          Đã có tài khoản? <span className="link" onClick={()=>goto("login")}>Đăng nhập</span>
        </div>
      </div>
    </div>
  );
}

function LoginScreen({ goto, onLogin }) {
  const [email, setEmail] = React.useState("");
  const [pw, setPw] = React.useState("");
  const [err, setErr] = React.useState(null);

  const submit = () => {
    if (email === "" || pw === "") { setErr("Vui lòng nhập đầy đủ"); return; }
    if (pw !== "123456" && email !== "demo@englishme.vn") {
      setErr("Thông tin đăng nhập không chính xác");
      return;
    }
    onLogin();
  };

  return (
    <div className="screen">
      <StatusBar/>
      <div className="screen-scroll" style={{padding:"0 24px"}}>
        <button onClick={() => goto("welcome")} style={{background:"none", border:"none", padding:"10px 0", cursor:"pointer", color:"var(--ink-700)"}}>
          <Icon.ChevronLeft width="28" height="28"/>
        </button>
        <div style={{display:"flex", alignItems:"center", gap: 14, marginBottom: 8}}>
          <Mascot size={64} mood="wink"/>
          <div>
            <div className="h1" style={{fontSize: 24}}>Chào mừng trở lại!</div>
            <div className="muted" style={{fontSize: 13}}>Echo đã chờ bạn rồi.</div>
          </div>
        </div>
        <div style={{marginTop: 20, display:"flex", flexDirection:"column", gap: 16}}>
          <div>
            <div className="field-label">Email</div>
            <input className={"field" + (err?" error":"")} type="email" placeholder="ban@email.com" value={email} onChange={e=>{setEmail(e.target.value); setErr(null);}}/>
          </div>
          <div>
            <div className="field-label">Mật khẩu</div>
            <input className={"field" + (err?" error":"")} type="password" placeholder="••••••••" value={pw} onChange={e=>{setPw(e.target.value); setErr(null);}}/>
            {err && <div className="field-error"><Icon.Warning width="14" height="14"/> {err}</div>}
          </div>
          <div style={{textAlign:"right"}}>
            <span className="link" style={{fontSize: 14}}>Quên mật khẩu?</span>
          </div>
        </div>
        <div style={{marginTop:24, display:"flex", alignItems:"center", gap:12, color:"var(--ink-400)"}}>
          <div style={{flex:1, height:2, background:"var(--ink-200)"}}/>
          <div style={{fontWeight: 800, fontSize: 12, letterSpacing: 1}}>HOẶC</div>
          <div style={{flex:1, height:2, background:"var(--ink-200)"}}/>
        </div>
        <button className="btn btn-ghost" style={{marginTop: 16}} onClick={onLogin}>
          <Icon.Google width="22" height="22"/>
          <span style={{textTransform:"none", letterSpacing: 0}}>Tiếp tục với Google</span>
        </button>
        <div style={{marginTop: 12, padding: 12, background: "var(--teal-50)", borderRadius: 12, fontSize: 12, color: "var(--teal-700)", fontWeight: 700, textAlign:"center"}}>
          💡 Dùng demo@englishme.vn / 123456
        </div>
      </div>
      <div style={{padding: "16px 24px 28px"}}>
        <button className="btn btn-primary" onClick={submit}>Đăng nhập</button>
      </div>
    </div>
  );
}

Object.assign(window, { WelcomeScreen, SignUpScreen, LoginScreen });
