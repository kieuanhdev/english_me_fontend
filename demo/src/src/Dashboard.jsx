// Dashboard — streak, daily goal, lesson path
const Dashboard = ({ onOpenFlash, onNav }) => {
  const units = [
    { label: 'Chào hỏi & Giới thiệu', lessons: [
      { type:'done', icon:'star' },
      { type:'done', icon:'star' },
      { type:'current', icon:'star' },
      { type:'locked', icon:'book' },
      { type:'locked', icon:'trophy' },
    ]},
  ];

  return (
    <>
      <div className="screen" data-screen-label="03 Dashboard">
        <StatusBar/>

        {/* Header stats strip */}
        <div style={{padding:'12px 20px 16px', display:'flex', alignItems:'center', gap:10}}>
          <div style={stat('var(--teal-500)')}>
            <Icon name="globe" size={18} color="#fff"/>
            <span>VI</span>
          </div>
          <div style={stat('var(--red-500)')}>
            <Icon name="flame" size={18} color="#fff"/>
            <span>7</span>
          </div>
          <div style={stat('var(--yellow-400)', '#8a5a00')}>
            <Icon name="bolt" size={18} color="#8a5a00"/>
            <span>1,240</span>
          </div>
          <div style={stat('var(--pink-500)')}>
            <Icon name="heart" size={18} color="#fff"/>
            <span>5</span>
          </div>
        </div>

        {/* Greeting + daily goal */}
        <div style={{padding:'0 20px 16px'}}>
          <h2 style={{fontSize:22, fontWeight:800, marginBottom:2}}>Xin chào, Minh Anh! 👋</h2>
          <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:13}}>Hôm nay học thêm 15 phút nhé!</p>
        </div>

        {/* Daily goal card */}
        <div style={{padding:'0 20px 20px'}}>
          <div className="card" style={{padding:16, display:'flex', alignItems:'center', gap:14, background:'linear-gradient(135deg, var(--primary-soft), var(--surface))'}}>
            <div style={{position:'relative', width:58, height:58, flexShrink:0}}>
              <svg width="58" height="58" viewBox="0 0 58 58">
                <circle cx="29" cy="29" r="24" fill="none" stroke="var(--ink-200)" strokeWidth="5"/>
                <circle cx="29" cy="29" r="24" fill="none" stroke="var(--primary)" strokeWidth="5"
                  strokeDasharray={`${(15/30)*150.8} 150.8`} strokeLinecap="round"
                  transform="rotate(-90 29 29)"/>
              </svg>
              <div style={{position:'absolute', inset:0, display:'flex', alignItems:'center', justifyContent:'center', fontFamily:'var(--font-display)', fontWeight:800, fontSize:14}}>50%</div>
            </div>
            <div style={{flex:1}}>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:15, marginBottom:2}}>Mục tiêu hôm nay</div>
              <div style={{color:'var(--text-muted)', fontSize:13, fontWeight:600}}>15 / 30 phút • còn 2 bài học</div>
            </div>
          </div>
        </div>

        {/* Unit banner */}
        <div style={{padding:'0 20px 16px'}}>
          <div style={{
            padding:'14px 16px', borderRadius:16,
            background:'var(--primary)', color:'#fff',
            display:'flex', alignItems:'center', gap:12,
            boxShadow:'0 4px 0 0 var(--primary-dark)',
          }}>
            <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:11, opacity:.85, letterSpacing:'.08em'}}>UNIT 1 • A1</div>
            <div style={{flex:1, fontFamily:'var(--font-display)', fontWeight:800, fontSize:16, marginTop:-2}}>{units[0].label}</div>
            <Icon name="book" size={22}/>
          </div>
        </div>

        {/* Lesson path (zig-zag) */}
        <div style={{padding:'12px 0 24px', position:'relative'}}>
          <div style={{display:'flex', flexDirection:'column', alignItems:'center', gap:4}}>
            {units[0].lessons.map((l, i) => {
              const offsets = [0, 60, 30, -30, -60];
              const x = offsets[i % offsets.length];
              const current = l.type === 'current';
              const done = l.type === 'done';
              const locked = l.type === 'locked';
              return (
                <div key={i} style={{transform:`translateX(${x}px)`, padding:'4px 0', position:'relative'}}>
                  {current && (
                    <div className="pop-in" style={{
                      position:'absolute', top:-30, left:'50%', transform:'translateX(-50%)',
                      background:'#fff', color:'var(--primary)',
                      padding:'4px 10px', borderRadius:8,
                      fontFamily:'var(--font-display)', fontWeight:800, fontSize:11,
                      border:'2px solid var(--primary)',
                      boxShadow:'0 2px 0 0 var(--primary)',
                      whiteSpace:'nowrap',
                    }}>
                      BẮT ĐẦU
                      <div style={{position:'absolute', bottom:-6, left:'50%', transform:'translateX(-50%) rotate(45deg)', width:8, height:8, background:'#fff', borderRight:'2px solid var(--primary)', borderBottom:'2px solid var(--primary)'}}/>
                    </div>
                  )}
                  <button
                    onClick={() => (current || done) && onOpenFlash && onOpenFlash()}
                    style={{
                      width:76, height:76, borderRadius:'50%', border:'none', cursor:'pointer',
                      background: done ? 'var(--yellow-400)' : current ? 'var(--primary)' : 'var(--ink-300)',
                      boxShadow: done ? '0 6px 0 0 #C98416' : current ? '0 6px 0 0 var(--primary-dark)' : '0 4px 0 0 #9EAAB5',
                      display:'flex', alignItems:'center', justifyContent:'center',
                      color:'#fff', position:'relative',
                    }}
                  >
                    {locked ? <Icon name="lock" size={28} color="#fff"/> : <Icon name={l.icon} size={32} color="#fff"/>}
                    {done && (
                      <div style={{position:'absolute', top:-4, right:-4, width:26, height:26, borderRadius:999, background:'#fff', border:'2px solid var(--yellow-400)', display:'flex', alignItems:'center', justifyContent:'center'}}>
                        <Icon name="check" size={14} color="var(--yellow-500)"/>
                      </div>
                    )}
                  </button>
                </div>
              );
            })}
          </div>

          {/* Mascot sitting next to the path */}
          <div style={{position:'absolute', right: 10, top: 130, transform:'rotate(-6deg)'}}>
            <Mascot variant="happy" size={90}/>
          </div>
        </div>

        {/* Next unit teaser */}
        <div style={{padding:'0 20px 28px'}}>
          <div className="card" style={{padding:14, display:'flex', alignItems:'center', gap:12, opacity:.75}}>
            <div style={{width:40, height:40, borderRadius:10, background:'var(--ink-200)', color:'var(--ink-400)', display:'flex', alignItems:'center', justifyContent:'center'}}>
              <Icon name="lock" size={20}/>
            </div>
            <div style={{flex:1}}>
              <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:11, color:'var(--text-muted)', letterSpacing:'.08em'}}>UNIT 2 • A1</div>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:15}}>Gia đình & Bạn bè</div>
            </div>
          </div>
        </div>
      </div>
      <BottomNav active="home" onNav={onNav}/>
    </>
  );
};

const stat = (bg, color='#fff') => ({
  flex:1, display:'flex', alignItems:'center', justifyContent:'center', gap:6,
  padding:'8px 10px', borderRadius:12, background:bg, color,
  fontFamily:'var(--font-display)', fontWeight:800, fontSize:14,
  boxShadow:`0 3px 0 0 rgba(0,0,0,.15)`,
});

window.Dashboard = Dashboard;
