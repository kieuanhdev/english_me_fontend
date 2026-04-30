// Flashcard screen with SM-2 rating
const DECK = [
  { word:'diligent', ipa:'/ˈdɪlɪdʒənt/', pos:'adj', meaning:'chăm chỉ, siêng năng',
    example:'She is a diligent student who always does her homework.',
    exampleVi:'Cô ấy là một học sinh chăm chỉ luôn làm bài tập về nhà.',
    img:'📚' },
  { word:'adventure', ipa:'/ədˈventʃər/', pos:'n', meaning:'cuộc phiêu lưu',
    example:'Going to a new country is always a great adventure.',
    exampleVi:'Đi đến một đất nước mới luôn là một cuộc phiêu lưu tuyệt vời.',
    img:'🧭' },
  { word:'grateful', ipa:'/ˈɡreɪtfəl/', pos:'adj', meaning:'biết ơn',
    example:"I'm grateful for your help today.",
    exampleVi:'Tôi biết ơn vì sự giúp đỡ của bạn hôm nay.',
    img:'🙏' },
];

const Flashcard = ({ onBack }) => {
  const [idx, setIdx] = React.useState(0);
  const [flipped, setFlipped] = React.useState(false);
  const [done, setDone] = React.useState(false);

  const card = DECK[idx];
  const progress = ((idx + (flipped ? 0.5 : 0)) / DECK.length) * 100;

  const rate = (level) => {
    // SM-2 rating — just advances in prototype
    if (idx + 1 >= DECK.length) {
      setDone(true);
    } else {
      setIdx(idx+1);
      setFlipped(false);
    }
  };

  if (done) {
    return (
      <div className="screen" data-screen-label="04 Flashcard Done">
        <StatusBar/>
        <div style={{padding:'8px 20px'}}><BackBtn onClick={onBack}/></div>
        <div style={{padding:'24px 28px', textAlign:'center'}}>
          <div className="pop-in" style={{display:'flex', justifyContent:'center', marginBottom:18}}>
            <Mascot variant="cheer" size={180}/>
          </div>
          <h1 style={{fontSize:26, fontWeight:800, marginBottom:8}}>Tuyệt vời!</h1>
          <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:14, marginBottom:24}}>
            Bạn vừa ôn xong {DECK.length} thẻ từ vựng.
          </p>

          <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:12, marginBottom:24}}>
            <div className="card" style={{padding:16}}>
              <div style={{display:'flex', alignItems:'center', justifyContent:'center', width:40, height:40, borderRadius:10, background:'var(--yellow-400)', color:'#8a5a00', margin:'0 auto 8px'}}>
                <Icon name="bolt" size={22}/>
              </div>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:22}}>+30</div>
              <div style={{color:'var(--text-muted)', fontSize:12, fontWeight:700}}>XP kiếm được</div>
            </div>
            <div className="card" style={{padding:16}}>
              <div style={{display:'flex', alignItems:'center', justifyContent:'center', width:40, height:40, borderRadius:10, background:'var(--red-500)', color:'#fff', margin:'0 auto 8px'}}>
                <Icon name="flame" size={22}/>
              </div>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:22}}>8 ngày</div>
              <div style={{color:'var(--text-muted)', fontSize:12, fontWeight:700}}>Streak</div>
            </div>
          </div>

          <button className="btn btn-primary btn-block btn-lg" onClick={onBack}>
            Quay lại trang chủ
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="screen" data-screen-label={`04 Flashcard ${idx+1}`}>
      <StatusBar/>

      {/* header: close + progress + hearts */}
      <div style={{padding:'8px 20px 0', display:'flex', alignItems:'center', gap: 12}}>
        <button onClick={onBack} style={{border:'none', background:'none', color:'var(--ink-400)', cursor:'pointer', padding:6}}>
          <Icon name="x" size={26}/>
        </button>
        <div style={{flex:1}}>
          <div className="progress"><div className="progress-fill" style={{width:`${progress}%`}}/></div>
        </div>
        <div style={{display:'flex', alignItems:'center', gap:4, color:'var(--ink-700)', fontFamily:'var(--font-display)', fontWeight:800, fontSize:13}}>
          {idx+1}/{DECK.length}
        </div>
      </div>

      <div style={{padding:'20px 24px'}}>
        <div style={{textAlign:'center', marginBottom:16}}>
          <span className="pill">
            <Icon name="cards" size={14}/> TỪ VỰNG • SM-2
          </span>
        </div>

        {/* Flip card */}
        <div
          onClick={() => setFlipped(f => !f)}
          style={{
            perspective:'1200px',
            height: 380,
            marginBottom: 24,
            cursor:'pointer',
          }}
        >
          <div style={{
            position:'relative', width:'100%', height:'100%',
            transformStyle:'preserve-3d',
            transition:'transform .5s cubic-bezier(.4,.8,.3,1.3)',
            transform: flipped ? 'rotateY(180deg)' : 'rotateY(0)',
          }}>
            {/* Front */}
            <div style={{
              position:'absolute', inset:0, backfaceVisibility:'hidden',
              background:'var(--surface)', borderRadius:24, border:'2px solid var(--border)',
              boxShadow:'0 6px 0 0 var(--border)',
              display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
              padding:24,
            }}>
              <div style={{fontSize:72, marginBottom:20, filter:'drop-shadow(0 4px 8px rgba(0,0,0,.1))'}}>{card.img}</div>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:36, color:'var(--text)', marginBottom:6, textAlign:'center'}}>
                {card.word}
              </div>
              <div style={{color:'var(--text-muted)', fontWeight:600, fontSize:15, marginBottom:4}}>
                {card.ipa}
              </div>
              <div style={{color:'var(--primary)', fontFamily:'var(--font-display)', fontWeight:700, fontSize:12, textTransform:'uppercase', letterSpacing:'.1em', marginBottom:20}}>
                {card.pos}
              </div>

              <button
                onClick={(e) => { e.stopPropagation(); }}
                style={{
                  width:56, height:56, borderRadius:'50%',
                  background:'var(--primary-soft)', color:'var(--primary)',
                  border:'2px solid var(--primary)', cursor:'pointer',
                  display:'flex', alignItems:'center', justifyContent:'center',
                  boxShadow:'0 3px 0 0 var(--primary)',
                }}
              >
                <Icon name="speaker" size={24}/>
              </button>

              <div style={{position:'absolute', bottom:16, color:'var(--text-muted)', fontSize:12, fontWeight:700, fontFamily:'var(--font-display)', letterSpacing:'.05em'}}>
                CHẠM ĐỂ XEM NGHĨA
              </div>
            </div>

            {/* Back */}
            <div style={{
              position:'absolute', inset:0, backfaceVisibility:'hidden',
              transform:'rotateY(180deg)',
              background:'var(--primary)', borderRadius:24,
              boxShadow:'0 6px 0 0 var(--primary-dark)',
              display:'flex', flexDirection:'column', padding:24, color:'#fff',
            }}>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, marginBottom:2}}>
                {card.word}
              </div>
              <div style={{opacity:.8, fontSize:13, fontWeight:600, marginBottom:16}}>
                {card.ipa} • {card.pos}
              </div>
              <div style={{
                background:'rgba(255,255,255,.18)', borderRadius:14, padding:14,
                marginBottom:14,
              }}>
                <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:11, opacity:.8, textTransform:'uppercase', letterSpacing:'.08em', marginBottom:4}}>Nghĩa</div>
                <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:22, lineHeight:1.2}}>{card.meaning}</div>
              </div>
              <div style={{
                background:'rgba(255,255,255,.12)', borderRadius:14, padding:14, flex:1,
              }}>
                <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:11, opacity:.8, textTransform:'uppercase', letterSpacing:'.08em', marginBottom:6}}>Ví dụ</div>
                <div style={{fontSize:14, fontWeight:700, lineHeight:1.4, marginBottom:8}}>
                  {card.example}
                </div>
                <div style={{fontSize:13, fontWeight:600, opacity:.85, lineHeight:1.4, fontStyle:'italic'}}>
                  {card.exampleVi}
                </div>
              </div>
              <div style={{textAlign:'center', marginTop:12, opacity:.7, fontSize:12, fontWeight:700, fontFamily:'var(--font-display)', letterSpacing:'.05em'}}>
                ĐÁNH GIÁ KHẢ NĂNG GHI NHỚ BÊN DƯỚI ↓
              </div>
            </div>
          </div>
        </div>

        {/* SM-2 rating */}
        {flipped ? (
          <div className="slide-up" style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:10}}>
            {[
              { label:'Quên', sub:'< 1 phút', bg:'var(--red-500)', sd:'#A01717' },
              { label:'Khó', sub:'6 phút', bg:'#F97316', sd:'#B84F06' },
              { label:'Dễ', sub:'1 ngày', bg:'var(--teal-500)', sd:'var(--teal-700)' },
              { label:'Rất dễ', sub:'4 ngày', bg:'var(--green-500)', sd:'#15803D' },
            ].map((r, i) => (
              <button key={r.label} onClick={() => rate(i)}
                style={{
                  padding:'14px 12px', borderRadius:14, border:'none', cursor:'pointer',
                  background:r.bg, color:'#fff', boxShadow:`0 4px 0 0 ${r.sd}`,
                  display:'flex', flexDirection:'column', alignItems:'center', gap:2,
                }}
              >
                <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:16}}>{r.label}</div>
                <div style={{fontSize:11, fontWeight:700, opacity:.85}}>{r.sub}</div>
              </button>
            ))}
          </div>
        ) : (
          <button className="btn btn-primary btn-block btn-lg" onClick={() => setFlipped(true)}>
            Xem nghĩa
          </button>
        )}
      </div>
    </div>
  );
};

window.Flashcard = Flashcard;
