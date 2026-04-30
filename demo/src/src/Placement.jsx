// Placement test — intro, questions, results
const QUESTIONS = [
  {
    type: 'grammar',
    category: 'Ngữ pháp',
    prompt: 'Chọn đáp án đúng:',
    sentence: 'She ___ to school every morning.',
    choices: ['go', 'goes', 'going', 'went'],
    answer: 1,
  },
  {
    type: 'vocab',
    category: 'Từ vựng',
    prompt: 'Từ "diligent" có nghĩa là gì?',
    choices: ['Lười biếng', 'Chăm chỉ', 'Thông minh', 'Tò mò'],
    answer: 1,
  },
  {
    type: 'grammar',
    category: 'Ngữ pháp',
    prompt: 'Hoàn thành câu sau:',
    sentence: 'If I ___ rich, I would travel the world.',
    choices: ['am', 'was', 'were', 'be'],
    answer: 2,
  },
  {
    type: 'listening',
    category: 'Nghe hiểu',
    prompt: 'Nghe và chọn câu trả lời đúng:',
    audio: true,
    choices: ['At the library', 'At the market', 'At the airport', 'At the hospital'],
    answer: 2,
  },
  {
    type: 'vocab',
    category: 'Từ vựng',
    prompt: 'Chọn từ đồng nghĩa với "happy":',
    choices: ['sad', 'joyful', 'angry', 'tired'],
    answer: 1,
  },
];

const Placement = ({ onFinish, onBack }) => {
  const [stage, setStage] = React.useState('intro'); // intro | test | result
  const [idx, setIdx] = React.useState(0);
  const [answers, setAnswers] = React.useState([]);
  const [selected, setSelected] = React.useState(null);
  const [showFb, setShowFb] = React.useState(false);

  if (stage === 'intro') {
    return (
      <div className="screen" data-screen-label="02 Placement Intro">
        <StatusBar/>
        <div style={{padding:'8px 20px'}}><BackBtn onClick={onBack}/></div>
        <div style={{padding:'24px 28px', textAlign:'center'}}>
          <div className="pop-in" style={{display:'flex', justifyContent:'center', marginBottom: 20}}>
            <Mascot variant="think" size={170}/>
          </div>
          <span className="pill" style={{marginBottom:14}}>BÀI KIỂM TRA ĐẦU VÀO</span>
          <h1 style={{fontSize:26, fontWeight:800, marginBottom:10, textWrap:'balance'}}>
            Cùng xem trình độ của bạn nhé!
          </h1>
          <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:14, marginBottom:24, textWrap:'pretty'}}>
            Một bài kiểm tra ngắn ~5 phút để hệ thống xếp bạn vào lộ trình phù hợp theo chuẩn CEFR (A1–C1).
          </p>

          <div style={{display:'grid', gridTemplateColumns:'1fr 1fr 1fr', gap:10, marginBottom: 28}}>
            {[
              {icon:'book', label:'Ngữ pháp', c:'var(--teal-500)'},
              {icon:'cards', label:'Từ vựng', c:'var(--yellow-400)'},
              {icon:'headphones', label:'Nghe hiểu', c:'var(--pink-500)'},
            ].map(s => (
              <div key={s.label} className="card" style={{padding:14, textAlign:'center'}}>
                <div style={{width:44, height:44, borderRadius:12, background:s.c, display:'flex', alignItems:'center', justifyContent:'center', margin:'0 auto 8px', color:'#fff'}}>
                  <Icon name={s.icon} size={22}/>
                </div>
                <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:13}}>{s.label}</div>
              </div>
            ))}
          </div>

          <button className="btn btn-primary btn-block btn-lg" onClick={() => setStage('test')}>
            Bắt đầu kiểm tra
          </button>
          <button className="btn btn-ghost" style={{marginTop:10}} onClick={onFinish}>
            Bỏ qua, vào thẳng Dashboard
          </button>
        </div>
      </div>
    );
  }

  if (stage === 'result') {
    const correct = answers.filter(a => a).length;
    const level = correct >= 4 ? 'B1' : correct >= 3 ? 'A2' : 'A1';
    return (
      <div className="screen" data-screen-label="02 Placement Result">
        <StatusBar/>
        <div style={{padding:'40px 28px', textAlign:'center'}}>
          <div className="pop-in" style={{display:'flex', justifyContent:'center', marginBottom:16}}>
            <Mascot variant="cheer" size={180}/>
          </div>
          <span className="pill" style={{background:'var(--yellow-300)', color:'#8a5a00', marginBottom:14}}>
            <Icon name="star" size={14}/> HOÀN THÀNH
          </span>
          <h1 style={{fontSize:26, fontWeight:800, marginBottom:10}}>Trình độ của bạn</h1>

          <div style={{
            display:'inline-flex', flexDirection:'column', alignItems:'center',
            padding:'18px 36px', borderRadius:24,
            background:'var(--primary)', color:'#fff',
            boxShadow:'0 6px 0 0 var(--primary-dark)',
            marginBottom:20,
          }}>
            <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:56, lineHeight:1}}>{level}</div>
            <div style={{fontFamily:'var(--font-display)', fontWeight:700, fontSize:13, opacity:.9, letterSpacing:'.08em'}}>CEFR • {level === 'A1' ? 'Sơ cấp' : level === 'A2' ? 'Cơ bản' : 'Trung cấp'}</div>
          </div>

          <p style={{color:'var(--text-muted)', fontWeight:600, fontSize:14, marginBottom:24, textWrap:'pretty'}}>
            Bạn trả lời đúng <strong style={{color:'var(--text)'}}>{correct}/{QUESTIONS.length}</strong> câu.
            Lộ trình đã được cá nhân hoá cho trình độ {level}.
          </p>

          <div className="card slide-up" style={{padding:16, textAlign:'left', marginBottom:24}}>
            <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:14, marginBottom:12}}>
              Lộ trình đề xuất
            </div>
            {[
              {name:'500 từ vựng thiết yếu', meta:'Flashcards • SM-2', done:false},
              {name:'Ngữ pháp căn bản', meta:'10 bài học', done:false},
              {name:'Nghe hiểu tình huống', meta:'8 hội thoại', done:false},
            ].map((s, i) => (
              <div key={i} style={{display:'flex', alignItems:'center', gap:12, padding:'10px 0', borderTop: i ? '1px dashed var(--border)' : 'none'}}>
                <div style={{width:36, height:36, borderRadius:10, background:'var(--primary-soft)', color:'var(--primary)', display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0}}>
                  <Icon name={['cards','book','headphones'][i]} size={20}/>
                </div>
                <div style={{flex:1}}>
                  <div style={{fontWeight:700, fontSize:14}}>{s.name}</div>
                  <div style={{color:'var(--text-muted)', fontSize:12, fontWeight:600}}>{s.meta}</div>
                </div>
                <Icon name="chevron-right" size={18} color="var(--ink-400)"/>
              </div>
            ))}
          </div>

          <button className="btn btn-primary btn-block btn-lg" onClick={onFinish}>
            Xác nhận lộ trình
          </button>
        </div>
      </div>
    );
  }

  // Test mode
  const q = QUESTIONS[idx];
  const pct = ((idx) / QUESTIONS.length) * 100;
  const progress = ((idx + (showFb ? 1 : 0)) / QUESTIONS.length) * 100;

  const submit = () => {
    if (selected == null) return;
    setShowFb(true);
  };
  const next = () => {
    const correct = selected === q.answer;
    const newAns = [...answers, correct];
    if (idx + 1 >= QUESTIONS.length) {
      setAnswers(newAns);
      setStage('result');
    } else {
      setAnswers(newAns);
      setIdx(idx+1);
      setSelected(null);
      setShowFb(false);
    }
  };

  const correct = selected === q.answer;

  return (
    <div className="screen" data-screen-label={`02 Placement Q${idx+1}`}>
      <StatusBar/>
      <div style={{padding:'8px 20px 0', display:'flex', alignItems:'center', gap: 12}}>
        <button onClick={onBack} style={{border:'none', background:'none', color:'var(--ink-400)', cursor:'pointer', padding:6}}>
          <Icon name="x" size={26}/>
        </button>
        <div style={{flex:1}}>
          <div className="progress"><div className="progress-fill" style={{width:`${progress}%`}}/></div>
        </div>
        <div style={{display:'flex', alignItems:'center', gap:4, color:'var(--red-500)', fontFamily:'var(--font-display)', fontWeight:800}}>
          <Icon name="heart" size={20} color="var(--red-500)"/> 5
        </div>
      </div>

      <div style={{padding:'24px 28px'}}>
        <span className="pill">{q.category}</span>
        <h2 style={{fontSize:22, fontWeight:800, marginTop:12, marginBottom:q.sentence || q.audio ? 20 : 28}}>
          {q.prompt}
        </h2>

        {q.sentence && (
          <div className="card" style={{padding:20, textAlign:'center', marginBottom:24}}>
            <div style={{fontFamily:'var(--font-display)', fontSize:20, fontWeight:700, lineHeight:1.4}}>
              {q.sentence}
            </div>
          </div>
        )}

        {q.audio && (
          <div style={{display:'flex', justifyContent:'center', marginBottom:24}}>
            <button style={{
              width:88, height:88, borderRadius:'50%',
              background:'var(--primary)', color:'#fff',
              border:'none', cursor:'pointer',
              boxShadow:'0 6px 0 0 var(--primary-dark)',
              display:'flex', alignItems:'center', justifyContent:'center',
            }}>
              <Icon name="play" size={40}/>
            </button>
          </div>
        )}

        <div style={{display:'flex', flexDirection:'column', gap:12, marginBottom: 28}}>
          {q.choices.map((c, i) => {
            const isSel = selected === i;
            const isRight = i === q.answer;
            let bg = 'var(--surface)', bd = 'var(--border)', col = 'var(--text)', sh = 'var(--shadow-btn-white)';
            if (showFb && isRight) { bg = '#E8F9EE'; bd='var(--green-500)'; col = '#0A7A33'; sh='0 4px 0 0 var(--green-500)'; }
            else if (showFb && isSel && !isRight) { bg='#FDECEC'; bd='var(--red-500)'; col='#A01717'; sh='0 4px 0 0 var(--red-500)'; }
            else if (isSel) { bg='var(--primary-soft)'; bd='var(--primary)'; col='var(--primary-dark)'; sh='0 4px 0 0 var(--primary)'; }

            return (
              <button
                key={i}
                onClick={() => !showFb && setSelected(i)}
                disabled={showFb}
                style={{
                  padding:'16px 18px', borderRadius:14,
                  border:`2px solid ${bd}`, background:bg, color:col,
                  boxShadow:sh,
                  fontFamily:'var(--font-body)', fontWeight:700, fontSize:15,
                  textAlign:'left', cursor: showFb ? 'default' : 'pointer',
                  display:'flex', alignItems:'center', gap:12,
                }}
              >
                <div style={{
                  width:28, height:28, borderRadius:8,
                  border:`2px solid ${bd}`, color:col,
                  display:'flex', alignItems:'center', justifyContent:'center',
                  fontFamily:'var(--font-display)', fontWeight:800, fontSize:13, flexShrink:0,
                }}>
                  {String.fromCharCode(65+i)}
                </div>
                <span style={{flex:1}}>{c}</span>
                {showFb && isRight && <Icon name="check" size={22} color="var(--green-500)"/>}
                {showFb && isSel && !isRight && <Icon name="x" size={22} color="var(--red-500)"/>}
              </button>
            );
          })}
        </div>

        {!showFb ? (
          <button
            className="btn btn-primary btn-block btn-lg"
            onClick={submit}
            disabled={selected == null}
            style={{opacity: selected == null ? .4 : 1}}
          >
            Kiểm tra
          </button>
        ) : (
          <div className="slide-up" style={{
            padding:16, borderRadius:16,
            background: correct ? '#E8F9EE' : '#FDECEC',
            marginBottom: 12,
          }}>
            <div style={{display:'flex', alignItems:'center', gap:10, marginBottom:6}}>
              <div style={{width:32, height:32, borderRadius:999, background: correct ? 'var(--green-500)':'var(--red-500)', color:'#fff', display:'flex', alignItems:'center', justifyContent:'center'}}>
                <Icon name={correct?'check':'x'} size={20}/>
              </div>
              <div style={{fontFamily:'var(--font-display)', fontWeight:800, fontSize:17, color: correct?'#0A7A33':'#A01717'}}>
                {correct ? 'Chính xác!' : 'Chưa đúng'}
              </div>
            </div>
            {!correct && (
              <div style={{fontSize:13, color:'#A01717', fontWeight:600, marginBottom:12}}>
                Đáp án đúng: <strong>{q.choices[q.answer]}</strong>
              </div>
            )}
            <button className="btn btn-block" onClick={next} style={{
              background: correct?'var(--green-500)':'var(--red-500)',
              color:'#fff', boxShadow: `0 4px 0 0 ${correct?'#0A7A33':'#A01717'}`,
            }}>
              {idx + 1 >= QUESTIONS.length ? 'Xem kết quả' : 'Tiếp tục'}
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

window.Placement = Placement;
