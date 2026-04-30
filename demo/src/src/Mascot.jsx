// Pip — the EnglishMe teal owl mascot.
// Variants: 'wave', 'happy', 'think', 'cheer', 'sleep'
const Mascot = ({ variant = 'wave', size = 160 }) => {
  // body colors
  const teal = 'var(--teal-500)';
  const tealDark = 'var(--teal-700)';
  const belly = '#FFF7E6';
  const bellyShadow = '#FFE7B8';
  const beak = '#F59E0B';
  const beakDark = '#C98416';

  const eyeOpen = (cx, cy) => (
    <g>
      <circle cx={cx} cy={cy} r="11" fill="#fff"/>
      <circle cx={cx} cy={cy} r="11" fill="none" stroke={tealDark} strokeWidth="2"/>
      <circle cx={cx+1} cy={cy+1} r="5.5" fill="#0D1B2A"/>
      <circle cx={cx+3} cy={cy-1} r="2" fill="#fff"/>
    </g>
  );
  const eyeClosed = (cx, cy) => (
    <path d={`M${cx-9} ${cy} Q${cx} ${cy-6} ${cx+9} ${cy}`} stroke={tealDark} strokeWidth="3" fill="none" strokeLinecap="round"/>
  );
  const eyeHappy = (cx, cy) => (
    <path d={`M${cx-8} ${cy+2} Q${cx} ${cy-7} ${cx+8} ${cy+2}`} stroke={tealDark} strokeWidth="3" fill="none" strokeLinecap="round"/>
  );

  // Wing positions per variant
  const leftWing = {
    wave: <g><path d="M32 90 Q8 80 14 50 Q22 30 38 54 Z" fill={teal} stroke={tealDark} strokeWidth="3"/></g>,
    happy: <path d="M30 88 Q10 94 18 70 Q26 60 42 82 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    think: <path d="M30 70 Q18 55 30 42 Q46 40 48 62 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    cheer: <path d="M30 60 Q10 30 26 18 Q44 20 42 48 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    sleep: <path d="M30 88 Q14 90 20 72 Q32 66 44 82 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
  }[variant];

  const rightWing = {
    wave: <path d="M128 88 Q150 90 146 70 Q136 58 122 80 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    happy: <path d="M130 88 Q150 94 142 70 Q134 60 118 82 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    think: <path d="M128 80 Q148 78 144 58 Q130 52 118 74 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    cheer: <path d="M130 60 Q150 30 134 18 Q116 20 118 48 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
    sleep: <path d="M130 88 Q146 90 140 72 Q128 66 116 82 Z" fill={teal} stroke={tealDark} strokeWidth="3"/>,
  }[variant];

  const eyes = {
    wave: (<>{eyeOpen(60, 58)}{eyeOpen(100, 58)}</>),
    happy: (<>{eyeHappy(60, 58)}{eyeHappy(100, 58)}</>),
    think: (<>{eyeOpen(60, 58)}{eyeOpen(100, 58)}</>),
    cheer: (<>{eyeHappy(60, 54)}{eyeHappy(100, 54)}</>),
    sleep: (<>{eyeClosed(60, 58)}{eyeClosed(100, 58)}</>),
  }[variant];

  const mouth = {
    wave: <path d="M76 78 Q80 86 84 78" stroke={beakDark} strokeWidth="2.5" fill={beak} strokeLinejoin="round"/>,
    happy: <path d="M72 76 Q80 88 88 76 Z" fill={beak} stroke={beakDark} strokeWidth="2.5"/>,
    think: <path d="M76 80 L84 80" stroke={beakDark} strokeWidth="3" strokeLinecap="round"/>,
    cheer: <path d="M70 76 Q80 92 90 76 Z" fill={beak} stroke={beakDark} strokeWidth="2.5"/>,
    sleep: <path d="M76 80 Q80 78 84 80" stroke={beakDark} strokeWidth="2.5" fill="none" strokeLinecap="round"/>,
  }[variant];

  return (
    <svg width={size} height={size} viewBox="0 0 160 160" fill="none" style={{display:'block'}}>
      {/* shadow */}
      <ellipse cx="80" cy="145" rx="44" ry="6" fill="rgba(0,0,0,.12)"/>

      {/* body (tear drop) */}
      <path
        d="M80 18
           C 118 18 140 46 140 82
           C 140 118 115 140 80 140
           C 45 140 20 118 20 82
           C 20 46 42 18 80 18 Z"
        fill={teal} stroke={tealDark} strokeWidth="3.5"
      />

      {/* tufts */}
      <path d="M40 28 L52 16 L58 34 Z" fill={teal} stroke={tealDark} strokeWidth="3" strokeLinejoin="round"/>
      <path d="M120 28 L108 16 L102 34 Z" fill={teal} stroke={tealDark} strokeWidth="3" strokeLinejoin="round"/>

      {/* belly */}
      <path d="M80 50 C 106 50 120 76 120 100 C 120 124 104 134 80 134 C 56 134 40 124 40 100 C 40 76 54 50 80 50 Z"
        fill={belly} stroke={tealDark} strokeWidth="3"/>
      <path d="M80 90 C 96 90 106 102 106 114 C 106 124 96 128 80 128 C 64 128 54 124 54 114 C 54 102 64 90 80 90 Z" fill={bellyShadow} opacity=".4"/>

      {/* wings */}
      {leftWing}
      {rightWing}

      {/* eyes */}
      {eyes}

      {/* beak */}
      <path d="M72 68 L88 68 L80 80 Z" fill={beak} stroke={beakDark} strokeWidth="2.5" strokeLinejoin="round"/>
      {mouth}

      {/* feet */}
      <path d="M62 134 L56 144 M62 134 L66 144 M62 134 L62 146" stroke={beakDark} strokeWidth="3" strokeLinecap="round"/>
      <path d="M98 134 L94 144 M98 134 L102 144 M98 134 L98 146" stroke={beakDark} strokeWidth="3" strokeLinecap="round"/>

      {/* cheek blush */}
      <ellipse cx="46" cy="76" rx="6" ry="4" fill="#FF6D94" opacity=".5"/>
      <ellipse cx="114" cy="76" rx="6" ry="4" fill="#FF6D94" opacity=".5"/>

      {/* think bubble */}
      {variant === 'think' && (
        <g>
          <circle cx="130" cy="36" r="10" fill="#fff" stroke={tealDark} strokeWidth="2.5"/>
          <circle cx="116" cy="46" r="5" fill="#fff" stroke={tealDark} strokeWidth="2.5"/>
          <text x="130" y="40" textAnchor="middle" fontSize="12" fontWeight="800" fill={tealDark} fontFamily="Baloo 2, sans-serif">?</text>
        </g>
      )}
      {variant === 'sleep' && (
        <text x="126" y="34" fontSize="22" fontWeight="800" fill={tealDark} fontFamily="Baloo 2, sans-serif">z</text>
      )}
    </svg>
  );
};

window.Mascot = Mascot;
