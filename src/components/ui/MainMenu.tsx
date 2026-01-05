import { useGameStore } from '../../store/gameStore';
import './MainMenu.css';

export function MainMenu() {
  const phase = useGameStore((state) => state.phase);
  const metaProgression = useGameStore((state) => state.metaProgression);
  const startNewRun = useGameStore((state) => state.startNewRun);
  const loadMetaProgression = useGameStore((state) => state.loadMetaProgression);

  if (phase !== 'menu') return null;

  const handleNewRun = (difficulty: number) => {
    loadMetaProgression();
    startNewRun(difficulty);
  };

  return (
    <div className="main-menu">
      <div className="menu-content">
        <h1 className="game-title">FINAL FIVE</h1>
        <p className="game-subtitle">A Roguelite Caddie Simulator</p>

        <div className="menu-stats">
          <span>Caddie Level: {metaProgression.caddieLevel}</span>
          <span>Total XP: {metaProgression.totalXp}</span>
          <span>
            Record: {metaProgression.wins}W - {metaProgression.losses}L
          </span>
        </div>

        <div className="difficulty-select">
          <h2>Select Difficulty</h2>
          <button className="menu-btn difficulty-easy" onClick={() => handleNewRun(1)}>
            <span className="difficulty-name">Club Pro</span>
            <span className="difficulty-desc">Forgiving conditions, steady player</span>
          </button>
          <button className="menu-btn difficulty-medium" onClick={() => handleNewRun(2)}>
            <span className="difficulty-name">Tour Pro</span>
            <span className="difficulty-desc">Standard challenge</span>
          </button>
          <button className="menu-btn difficulty-hard" onClick={() => handleNewRun(3)}>
            <span className="difficulty-name">Major Championship</span>
            <span className="difficulty-desc">Tough conditions, high stakes</span>
          </button>
        </div>

        <div className="menu-info">
          <p>Guide your golfer through the final 5 holes to victory.</p>
          <p>Every decision matters. Every shot counts.</p>
        </div>

        <div className="controls-info">
          <h3>Controls</h3>
          <ul>
            <li>WASD - Move around the course</li>
            <li>Mouse - Look around</li>
            <li>Click - Lock cursor / Interact</li>
            <li>ESC - Pause / Menu</li>
            <li>TAB - Yardage Book</li>
            <li>SPACE - Confirm shot</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
