// Lightweight inline icons (stroke-based, match chunky friendly vibe)
const Icon = ({ name, size = 24, color = 'currentColor', fill = 'none', ...rest }) => {
  const props = {
    width: size, height: size, viewBox: '0 0 24 24',
    fill, stroke: color, strokeWidth: 2.4, strokeLinecap: 'round', strokeLinejoin: 'round',
    ...rest
  };
  switch (name) {
    case 'home': return <svg {...props}><path d="M3 11l9-8 9 8v10a1 1 0 0 1-1 1h-5v-7h-6v7H4a1 1 0 0 1-1-1z"/></svg>;
    case 'cards': return <svg {...props}><rect x="3" y="5" width="14" height="10" rx="2"/><rect x="7" y="9" width="14" height="10" rx="2"/></svg>;
    case 'mic': return <svg {...props}><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0"/><path d="M12 18v3"/></svg>;
    case 'trophy': return <svg {...props}><path d="M7 4h10v4a5 5 0 0 1-10 0z"/><path d="M7 6H4v2a3 3 0 0 0 3 3"/><path d="M17 6h3v2a3 3 0 0 1-3 3"/><path d="M10 15h4v3h2v2H8v-2h2z"/></svg>;
    case 'user': return <svg {...props}><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>;
    case 'chat': return <svg {...props}><path d="M4 5h16v11H8l-4 4z"/></svg>;
    case 'flame': return <svg {...props} fill={color} stroke="none"><path d="M12 2c0 4-5 5-5 10a5 5 0 0 0 10 0c0-2-1-3-2-4 0 2-1 3-2 3 1-3-1-6-1-9z"/></svg>;
    case 'star': return <svg {...props} fill={color} stroke="none"><path d="M12 2l2.9 6.1 6.6.6-5 4.6 1.5 6.6L12 16.8 5.9 19.9 7.5 13.3 2.5 8.7l6.6-.6z"/></svg>;
    case 'gem': return <svg {...props}><path d="M6 3h12l3 5-9 13L3 8z"/><path d="M3 8h18M9 3l3 5 3-5M12 8l-2 13M12 8l2 13"/></svg>;
    case 'lock': return <svg {...props}><rect x="4" y="11" width="16" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/></svg>;
    case 'check': return <svg {...props}><path d="M5 12l5 5L20 7"/></svg>;
    case 'x': return <svg {...props}><path d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'chevron-left': return <svg {...props}><path d="M15 6l-6 6 6 6"/></svg>;
    case 'chevron-right': return <svg {...props}><path d="M9 6l6 6-6 6"/></svg>;
    case 'speaker': return <svg {...props}><path d="M4 9v6h4l5 4V5L8 9z"/><path d="M17 8a5 5 0 0 1 0 8"/><path d="M20 5a9 9 0 0 1 0 14"/></svg>;
    case 'refresh': return <svg {...props}><path d="M3 12a9 9 0 0 1 15-6l3-3v8h-8l3-3a6 6 0 0 0-10 4"/><path d="M21 12a9 9 0 0 1-15 6l-3 3v-8h8l-3 3a6 6 0 0 0 10-4"/></svg>;
    case 'play': return <svg {...props} fill={color} stroke="none"><path d="M6 4l14 8-14 8z"/></svg>;
    case 'heart': return <svg {...props} fill={color} stroke="none"><path d="M12 21s-7-4.5-9.5-9A5.5 5.5 0 0 1 12 6a5.5 5.5 0 0 1 9.5 6C19 16.5 12 21 12 21z"/></svg>;
    case 'bolt': return <svg {...props} fill={color} stroke="none"><path d="M13 2L4 14h6l-1 8 9-12h-6z"/></svg>;
    case 'book': return <svg {...props}><path d="M4 4h7a3 3 0 0 1 3 3v14a3 3 0 0 0-3-3H4z"/><path d="M20 4h-7a3 3 0 0 0-3 3v14a3 3 0 0 1 3-3h7z"/></svg>;
    case 'headphones': return <svg {...props}><path d="M4 15v-3a8 8 0 0 1 16 0v3"/><rect x="3" y="14" width="4" height="7" rx="1.5"/><rect x="17" y="14" width="4" height="7" rx="1.5"/></svg>;
    case 'globe': return <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3a13 13 0 0 1 0 18M12 3a13 13 0 0 0 0 18"/></svg>;
    default: return null;
  }
};

window.Icon = Icon;
