/* EnglishMe — Home/Dashboard + Learn hub */

function HomeScreen({ goto, streak, xp }) {
  const goalXp = 50;
  const todayXp = 35;
  const lessons = [
    { id:"flashcards", title:"Từ vựng hôm nay", sub:"12 thẻ · Ôn SM-2", color:"var(--teal-500)", icon:"🃏", progress: 60, screen:"flashcard" },
    { id:"grammar", title:"Thì quá khứ đơn", sub:"Bài giảng + luyện tập", color:"var(--purple)", icon:"📝", progress: 0, screen:"grammar" },
    { id:"listening", title:"Ordering at a café", sub:"Luyện nghe · 3 phút", color:"var(--blue)", icon:"🎧", progress: 0, screen:"listening" },
  ];
  return (
    <div className="screen">
      <StatusBar/>
      <TopStats streak={streak} xp={xp}/>
      <div className="screen-scroll" style={{padding:"0 20px 20px"}}>
        {/* Greeting */}
        <div style={{display:"flex", alignItems:"center", gap:12, marginTop: 6}}>
          <div style={{flex:1}}>
            <div className="muted" style={{fontSize: 12, letterSpacing:1, fontWeight:800}}>CHÀO BUỔI SÁNG</div>
            <div className="h1" style={{fontSize: 24}}>Mai ơi, học tiếp nào! 👋</div>
          </div>
          <Mascot size={60} mood="happy"/>
        </div>

        {/* Daily goal */}
        <div className="card" style={{marginTop: 16, padding: 18, background: "linear-gradient(135deg, var(--teal-500), var(--teal-600))", border:"none", boxShadow:"0 4px 0 var(--teal-700)"}}>
          <div style={{display:"flex", alignItems:"center", gap: 12, color:"#fff"}}>
            <div style={{width: 52, height: 52, borderRadius:14, background:"rgba(255,255,255,0.18)", display:"flex", alignItems:"center", justifyContent:"center"}}>
              <Icon.Target width="30" height="30"/>
            </div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800, fontSize: 15}}>Mục tiêu hôm nay</div>
              <div style={{fontSize: 13, opacity:0.85, fontWeight:700}}>{todayXp} / {goalXp} XP</div>
            </div>
            <div style={{fontSize: 28, fontWeight: 900, fontFamily:"var(--font-display)"}}>{Math.round(todayXp/goalXp*100)}%</div>
          </div>
          <div style={{marginTop: 12, height: 10, background: "rgba(0,0,0,0.15)", borderRadius: 99, overflow:"hidden"}}>
            <div style={{width: `${todayXp/goalXp*100}%`, height:"100%", background:"var(--accent)", borderRadius:99}}/>
          </div>
        </div>

        {/* Unit banner */}
        <div style={{marginTop: 20, marginBottom: 10, display:"flex", alignItems:"center", gap: 10}}>
          <div style={{flex:1, height: 2, background:"var(--border)"}}/>
          <div className="chip chip-teal" style={{fontSize:11, letterSpacing: 1}}>UNIT 3 · B1</div>
          <div style={{flex:1, height: 2, background:"var(--border)"}}/>
        </div>
        <div style={{textAlign:"center", marginBottom: 16}}>
          <div className="h2" style={{fontSize: 18}}>Giao tiếp hàng ngày</div>
          <div className="muted" style={{fontSize: 13}}>Bài 4 / 12</div>
        </div>

        {/* Lesson path — vertical */}
        <div style={{display:"flex", flexDirection:"column", gap: 12}}>
          {lessons.map((l, i) => (
            <button key={l.id} onClick={()=>goto(l.screen)} style={{
              display:"flex", alignItems:"center", gap:14, padding: 16,
              background: "var(--card)", border: "2px solid var(--border)",
              boxShadow: "var(--shadow-card)", borderRadius: 20,
              cursor:"pointer", fontFamily:"var(--font)", textAlign:"left",
            }}>
              <div style={{
                width:56, height:56, borderRadius:"50%",
                background: l.color, display:"flex", alignItems:"center", justifyContent:"center",
                fontSize: 28, boxShadow:"0 3px 0 rgba(0,0,0,0.15)",
              }}>{l.icon}</div>
              <div style={{flex:1}}>
                <div className="h3">{l.title}</div>
                <div className="muted" style={{fontSize: 13, marginBottom: 6}}>{l.sub}</div>
                <Progress value={l.progress}/>
              </div>
              <Icon.ChevronRight width="22" height="22" color="var(--ink-300)"/>
            </button>
          ))}
          {/* Locked */}
          <div style={{
            display:"flex", alignItems:"center", gap:14, padding: 16, opacity: 0.6,
            border: "2px dashed var(--border)", borderRadius: 20,
          }}>
            <div style={{
              width:56, height:56, borderRadius:"50%", background:"var(--ink-100)",
              display:"flex", alignItems:"center", justifyContent:"center", color:"var(--ink-400)",
            }}><Icon.Lock width="24" height="24"/></div>
            <div style={{flex:1}}>
              <div className="h3" style={{color:"var(--ink-500)"}}>Story: At the airport</div>
              <div className="muted" style={{fontSize: 13}}>Hoàn thành 3 bài trên để mở</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function LearnHub({ goto }) {
  const tracks = [
    {id:"vocab", title:"Từ vựng", sub:"Flashcards · SM-2", color:"var(--teal-500)", icon:"🃏", count: "1,240 thẻ", screen:"flashcard"},
    {id:"grammar", title:"Ngữ pháp", sub:"Lý thuyết + luyện tập", color:"var(--purple)", icon:"📝", count: "64 chủ đề", screen:"grammar"},
    {id:"listening", title:"Nghe hiểu", sub:"Audio + câu hỏi", color:"var(--blue)", icon:"🎧", count: "38 bài", screen:"listening"},
    {id:"stories", title:"Truyện ngắn", sub:"Đọc + hiểu", color:"var(--accent-2)", icon:"📖", count: "20 truyện", locked:true},
  ];
  return (
    <div className="screen">
      <StatusBar/>
      <div style={{padding: "10px 20px 12px"}}>
        <div className="muted" style={{fontSize: 12, letterSpacing:1, fontWeight:800}}>HỌC TẬP</div>
        <div className="h1">Chọn kỹ năng</div>
      </div>
      <div className="screen-scroll" style={{padding: "0 20px 20px"}}>
        <div style={{display:"grid", gridTemplateColumns:"1fr 1fr", gap: 12}}>
          {tracks.map(t => (
            <button key={t.id} onClick={()=>!t.locked && goto(t.screen)} disabled={t.locked} style={{
              background:"var(--card)", border:"2px solid var(--border)", boxShadow:"var(--shadow-card)",
              borderRadius: 20, padding: 16, cursor: t.locked?"default":"pointer",
              display:"flex", flexDirection:"column", gap:10, opacity: t.locked?0.55:1,
              fontFamily:"var(--font)", textAlign:"left",
            }}>
              <div style={{
                width: 52, height:52, borderRadius: 16, background: t.color,
                display:"flex", alignItems:"center", justifyContent:"center", fontSize: 26,
                boxShadow:"0 3px 0 rgba(0,0,0,0.12)",
              }}>{t.locked ? <Icon.Lock width="24" height="24" color="#fff"/> : t.icon}</div>
              <div>
                <div className="h3" style={{fontSize:15}}>{t.title}</div>
                <div className="muted" style={{fontSize:12, marginTop: 2}}>{t.sub}</div>
              </div>
              <div className="chip" style={{alignSelf:"flex-start", fontSize: 11}}>{t.count}</div>
            </button>
          ))}
        </div>

        <div style={{marginTop: 20}} className="h3">Đang tiếp tục</div>
        <div className="card" style={{marginTop: 10, display:"flex", gap:14, alignItems:"center"}}>
          <div style={{width:48, height:48, borderRadius:14, background:"var(--teal-50)", display:"flex", alignItems:"center", justifyContent:"center", fontSize: 24}}>🃏</div>
          <div style={{flex:1}}>
            <div className="h3" style={{fontSize:14}}>Từ vựng hôm nay</div>
            <div className="muted" style={{fontSize:12, marginBottom: 6}}>7 / 12 thẻ</div>
            <Progress value={58}/>
          </div>
          <button onClick={()=>goto("flashcard")} style={{background:"var(--teal-500)", border:"none", padding:"10px 14px", borderRadius: 12, color:"#fff", fontWeight:800, cursor:"pointer", fontSize: 13, boxShadow:"0 3px 0 var(--teal-700)"}}>Tiếp</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, LearnHub });
