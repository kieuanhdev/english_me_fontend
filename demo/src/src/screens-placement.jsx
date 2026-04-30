/* EnglishMe — Placement Test + Result screens */

const PLACEMENT_QUESTIONS = [
  {
    type: "grammar", topic: "Ngữ pháp",
    q: "Choose the correct form: \"She ___ to the gym every morning.\"",
    options: ["go", "goes", "going", "is go"], answer: 1,
  },
  {
    type: "vocab", topic: "Từ vựng",
    q: "What does \"diligent\" mean?",
    options: ["Lười biếng", "Chăm chỉ", "Thông minh", "Hài hước"], answer: 1,
  },
  {
    type: "listening", topic: "Nghe hiểu",
    q: "Listen and choose: What is the speaker ordering?",
    audio: true,
    options: ["A coffee", "A tea", "A hot chocolate", "A latte"], answer: 3,
  },
  {
    type: "grammar", topic: "Ngữ pháp",
    q: "If I ___ rich, I would travel the world.",
    options: ["am", "was", "were", "be"], answer: 2,
  },
  {
    type: "vocab", topic: "Từ vựng",
    q: "Which word is the opposite of \"generous\"?",
    options: ["Kind", "Stingy", "Brave", "Quiet"], answer: 1,
  },
];

function PlacementIntro({ goto }) {
  return (
    <div className="screen">
      <StatusBar/>
      <div className="screen-scroll" style={{padding:"20px 24px"}}>
        <div style={{display:"flex", flexDirection:"column", alignItems:"center", marginTop: 30}}>
          <Mascot size={140} mood="proud"/>
        </div>
        <div className="h1" style={{textAlign:"center", marginTop: 20, fontSize: 26}}>Kiểm tra trình độ</div>
        <div className="body" style={{textAlign:"center", marginTop: 8, padding: "0 8px"}}>
          Echo sẽ hỏi bạn vài câu để gợi ý lộ trình phù hợp. Chỉ mất khoảng <b>3 phút</b>.
        </div>
        <div style={{marginTop: 28, display:"flex", flexDirection:"column", gap: 12}}>
          {[
            {icon:"📚", title:"Ngữ pháp", desc:"Cấu trúc câu, thì"},
            {icon:"🔤", title:"Từ vựng", desc:"Từ đồng – trái nghĩa"},
            {icon:"🎧", title:"Nghe hiểu", desc:"Đoạn hội thoại ngắn"},
          ].map(it => (
            <div key={it.title} className="card" style={{display:"flex", alignItems:"center", gap: 14}}>
              <div style={{width: 48, height: 48, borderRadius: 14, background: "var(--teal-50)", display:"flex", alignItems:"center", justifyContent:"center", fontSize: 26}}>{it.icon}</div>
              <div style={{flex:1}}>
                <div className="h3">{it.title}</div>
                <div className="muted" style={{fontSize: 13}}>{it.desc}</div>
              </div>
              <Icon.ChevronRight width="20" height="20" color="var(--ink-300)"/>
            </div>
          ))}
        </div>
      </div>
      <div style={{padding:"16px 24px 28px"}}>
        <button className="btn btn-primary" onClick={()=>goto("placement-test")}>Bắt đầu kiểm tra</button>
      </div>
    </div>
  );
}

function PlacementTest({ goto }) {
  const [idx, setIdx] = React.useState(0);
  const [answers, setAnswers] = React.useState({});
  const [warn, setWarn] = React.useState(false);
  const [playing, setPlaying] = React.useState(false);
  const q = PLACEMENT_QUESTIONS[idx];
  const selected = answers[idx];

  const next = () => {
    if (idx < PLACEMENT_QUESTIONS.length - 1) setIdx(idx+1);
  };
  const submit = () => {
    if (Object.keys(answers).length < PLACEMENT_QUESTIONS.length) {
      setWarn(true);
      setTimeout(()=>setWarn(false), 2500);
      return;
    }
    goto("placement-result");
  };

  return (
    <div className="screen">
      <StatusBar/>
      {warn && <Toast type="error">Bạn cần trả lời hết {PLACEMENT_QUESTIONS.length} câu</Toast>}
      {/* Top bar: close + progress */}
      <div style={{padding:"8px 20px 16px", display:"flex", alignItems:"center", gap: 12}}>
        <button onClick={()=>goto("placement-intro")} style={{background:"none", border:"none", cursor:"pointer", color:"var(--ink-500)"}}>
          <Icon.X width="28" height="28"/>
        </button>
        <div style={{flex:1}}>
          <Progress value={((idx+1)/PLACEMENT_QUESTIONS.length)*100} color="var(--teal-500)"/>
        </div>
        <div style={{fontWeight:900, color:"var(--ink-500)", fontSize:14}}>{idx+1}/{PLACEMENT_QUESTIONS.length}</div>
      </div>

      <div className="screen-scroll" style={{padding: "0 24px"}}>
        <div style={{display:"flex", alignItems:"center", gap: 8, marginTop: 8}}>
          <div className="chip chip-teal">{q.topic}</div>
        </div>

        <div className="h1" style={{marginTop: 16, fontSize: 22, lineHeight: 1.3}}>{q.q}</div>

        {q.audio && (
          <div style={{marginTop: 24, padding: 20, background:"var(--teal-50)", borderRadius:20, display:"flex", flexDirection:"column", alignItems:"center", gap:12}}>
            <button onClick={()=>setPlaying(!playing)} style={{
              width:72, height:72, borderRadius:"50%", background:"var(--teal-500)", border:"none",
              color:"#fff", display:"flex", alignItems:"center", justifyContent:"center", cursor:"pointer",
              boxShadow: "0 4px 0 var(--teal-700)",
            }}>
              {playing ? <Icon.Pause width="34" height="34"/> : <Icon.Play width="34" height="34" style={{marginLeft: 4}}/>}
            </button>
            {/* waveform */}
            <div style={{display:"flex", alignItems:"center", gap: 3, height: 30}}>
              {[...Array(22)].map((_,i)=>(
                <div key={i} style={{
                  width: 3, borderRadius: 2, background:"var(--teal-500)",
                  height: 6 + Math.abs(Math.sin(i*0.7))*22,
                  opacity: playing ? 1 : 0.5,
                }}/>
              ))}
            </div>
            <div className="muted" style={{fontSize:13}}>Nhấn để nghe lại</div>
          </div>
        )}

        <div style={{marginTop: 20, display:"flex", flexDirection:"column", gap:10}}>
          {q.options.map((o, i) => {
            const isSel = selected === i;
            return (
              <button key={i} onClick={()=>setAnswers({...answers, [idx]: i})}
                style={{
                  textAlign:"left", padding: "16px 18px",
                  background: isSel?"var(--teal-50)":"var(--card)",
                  border: "2px solid " + (isSel?"var(--teal-500)":"var(--border)"),
                  boxShadow: "0 3px 0 " + (isSel?"var(--teal-500)":"var(--border)"),
                  borderRadius: 16, cursor:"pointer", fontFamily:"var(--font)",
                  fontWeight: 700, fontSize: 15, color:"var(--ink-900)",
                  display:"flex", alignItems:"center", gap: 14,
                }}>
                <div style={{
                  width: 28, height: 28, borderRadius: 8, border: "2px solid "+(isSel?"var(--teal-500)":"var(--ink-300)"),
                  display:"flex", alignItems:"center", justifyContent:"center",
                  fontWeight:900, fontSize: 13, color: isSel?"#fff":"var(--ink-500)",
                  background: isSel?"var(--teal-500)":"transparent",
                }}>{String.fromCharCode(65+i)}</div>
                {o}
              </button>
            );
          })}
        </div>
      </div>

      <div style={{padding:"16px 24px 28px", display:"flex", gap: 10}}>
        {idx > 0 && <button className="btn btn-ghost" style={{flex:"0 0 100px"}} onClick={()=>setIdx(idx-1)}>Trước</button>}
        {idx < PLACEMENT_QUESTIONS.length - 1 ? (
          <button className="btn btn-primary" onClick={next} disabled={selected == null}>Tiếp theo</button>
        ) : (
          <button className="btn btn-success" onClick={submit}>Nộp bài</button>
        )}
      </div>
    </div>
  );
}

function PlacementResult({ goto }) {
  const skills = [
    {name: "Ngữ pháp", level: 75, color: "var(--green)"},
    {name: "Từ vựng", level: 60, color: "var(--blue)"},
    {name: "Nghe hiểu", level: 40, color: "var(--purple)"},
  ];
  return (
    <div className="screen" style={{background:"linear-gradient(180deg, var(--teal-50) 0%, var(--bg) 35%)"}}>
      <StatusBar/>
      <div className="screen-scroll" style={{padding: "0 24px 20px"}}>
        <div style={{textAlign:"center", marginTop: 20}}>
          <div className="muted" style={{fontSize: 13, letterSpacing: 2}}>TRÌNH ĐỘ CỦA BẠN</div>
          <div style={{marginTop: 20, display:"flex", justifyContent:"center"}}>
            <CefrBadge level="B1" size={140}/>
          </div>
          <div className="h1" style={{marginTop: 28, fontSize: 24}}>Bạn đang ở cấp độ Trung cấp</div>
          <div className="body" style={{marginTop: 8}}>Echo đã dựng sẵn một lộ trình phù hợp với bạn. Hãy xem thử nhé!</div>
        </div>

        <div style={{marginTop: 24, display:"flex", flexDirection:"column", gap: 14}}>
          <div className="h3" style={{textTransform:"uppercase", letterSpacing: 1, color:"var(--ink-500)", fontSize: 12}}>Kết quả chi tiết</div>
          {skills.map(s => (
            <div key={s.name}>
              <div style={{display:"flex", justifyContent:"space-between", marginBottom: 6}}>
                <span className="h3" style={{fontSize:15}}>{s.name}</span>
                <span style={{fontWeight: 900, color: s.color}}>{s.level}%</span>
              </div>
              <Progress value={s.level} color={s.color}/>
            </div>
          ))}
        </div>

        <div style={{marginTop: 28}}>
          <div className="h3" style={{textTransform:"uppercase", letterSpacing: 1, color:"var(--ink-500)", fontSize: 12, marginBottom: 12}}>Lộ trình gợi ý</div>
          <div className="card" style={{padding: 0, overflow: "hidden"}}>
            {[
              {num:1, title:"Củng cố nghe hiểu B1", sub:"20 bài · Kỹ năng yếu nhất", active: true},
              {num:2, title:"Mở rộng từ vựng công việc", sub:"15 bài"},
              {num:3, title:"Ngữ pháp nâng cao", sub:"12 bài"},
              {num:4, title:"Giao tiếp thực tế", sub:"8 chủ đề"},
            ].map((s, i, arr) => (
              <div key={s.num} style={{
                display:"flex", alignItems:"center", gap:14, padding: 16,
                borderBottom: i === arr.length-1 ? "none" : "1px solid var(--border)",
              }}>
                <div style={{
                  width:36, height:36, borderRadius:"50%",
                  background: s.active?"var(--teal-500)":"var(--ink-100)",
                  color: s.active?"#fff":"var(--ink-500)",
                  display:"flex", alignItems:"center", justifyContent:"center",
                  fontWeight: 900, fontSize: 15,
                }}>{s.num}</div>
                <div style={{flex:1}}>
                  <div className="h3" style={{fontSize: 15}}>{s.title}</div>
                  <div className="muted" style={{fontSize: 12}}>{s.sub}</div>
                </div>
                {s.active && <div className="chip chip-teal">Bắt đầu</div>}
              </div>
            ))}
          </div>
        </div>
      </div>
      <div style={{padding:"16px 24px 28px", display:"flex", flexDirection:"column", gap: 8}}>
        <button className="btn btn-primary" onClick={()=>goto("home")}>Xác nhận lộ trình</button>
        <button className="btn btn-ghost" onClick={()=>goto("placement-test")}>Làm lại bài kiểm tra</button>
      </div>
    </div>
  );
}

Object.assign(window, { PlacementIntro, PlacementTest, PlacementResult });
