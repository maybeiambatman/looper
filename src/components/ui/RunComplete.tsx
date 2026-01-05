import { useGameStore } from '../../store/gameStore';
import './RunComplete.css';

export function RunComplete() {
  const phase = useGameStore((state) => state.phase);
  const run = useGameStore((state) => state.run);
  const tournament = useGameStore((state) => state.tournament);
  const metaProgression = useGameStore((state) => state.metaProgression);
  const setPhase = useGameStore((state) => state.setPhase);

  if (phase !== 'run_complete') return null;
  if (!run || !tournament) return null;

  const won = run.won;

  const handleReturnToMenu = () => {
    setPhase('menu');
  };

  const handlePlayAgain = () => {
    setPhase('menu');
  };

  const scoreDisplay = (score: number) => {
    if (score === 0) return 'E';
    return score > 0 ? `+${score}` : `${score}`;
  };

  return (
    <div className="run-complete-overlay">
      <div className="run-complete">
        <h1 className={won ? 'victory' : 'defeat'}>
          {won ? 'Tournament Won!' : 'Tournament Lost'}
        </h1>

        <div className="final-scores">
          <div className="score-row player">
            <span className="label">Your Score:</span>
            <span className="score">{scoreDisplay(tournament.playerScore)}</span>
          </div>
          <div className="score-row leader">
            <span className="label">{tournament.leaderName}:</span>
            <span className="score">{scoreDisplay(tournament.leaderScore)}</span>
          </div>
        </div>

        <div className="run-stats">
          <h3>Run Statistics</h3>
          <div className="stat-grid">
            <div className="stat">
              <span className="stat-label">Shots Taken</span>
              <span className="stat-value">{run.shotsTaken}</span>
            </div>
            <div className="stat">
              <span className="stat-label">Good Decisions</span>
              <span className="stat-value good">{run.goodDecisions}</span>
            </div>
            <div className="stat">
              <span className="stat-label">Bad Decisions</span>
              <span className="stat-value bad">{run.badDecisions}</span>
            </div>
            <div className="stat">
              <span className="stat-label">Hole Scores</span>
              <span className="stat-value">
                {run.holeScores.map((s) => scoreDisplay(s)).join(', ')}
              </span>
            </div>
          </div>
        </div>

        <div className="progression-update">
          <h3>Caddie Progression</h3>
          <div className="level-display">
            <span>Level {metaProgression.caddieLevel}</span>
            <span className="xp">Total XP: {metaProgression.totalXp}</span>
          </div>
          <div className="record">
            Lifetime Record: {metaProgression.wins}W - {metaProgression.losses}L
          </div>
        </div>

        <div className="action-buttons">
          <button className="play-again-btn" onClick={handlePlayAgain}>
            Play Again
          </button>
          <button className="menu-btn" onClick={handleReturnToMenu}>
            Main Menu
          </button>
        </div>
      </div>
    </div>
  );
}
