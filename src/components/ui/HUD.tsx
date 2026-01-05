import { useGameStore } from '../../store/gameStore';
import { getWindDescription } from '../../utils/conditionsGenerator';
import './HUD.css';

export function HUD() {
  const phase = useGameStore((state) => state.phase);
  const player = useGameStore((state) => state.player);
  const tournament = useGameStore((state) => state.tournament);
  const holes = useGameStore((state) => state.holes);
  const currentHoleIndex = useGameStore((state) => state.currentHoleIndex);
  const currentConditions = useGameStore((state) => state.currentConditions);
  const strokesThisHole = useGameStore((state) => state.strokesThisHole);
  const currentLie = useGameStore((state) => state.currentLie);
  const lastOutcome = useGameStore((state) => state.lastOutcome);

  if (phase !== 'playing') return null;

  const currentHole = holes[currentHoleIndex];
  if (!currentHole || !tournament || !currentConditions) return null;

  const scoreDisplay = (score: number) => {
    if (score === 0) return 'E';
    return score > 0 ? `+${score}` : `${score}`;
  };

  return (
    <div className="hud">
      {/* Leaderboard */}
      <div className="hud-panel leaderboard">
        <h3>Leaderboard</h3>
        <div className="leaderboard-entries">
          <div
            className={`entry ${tournament.playerScore <= tournament.leaderScore ? 'leading' : ''}`}
          >
            <span className="name">{player?.playerName || 'You'}</span>
            <span className="score">{scoreDisplay(tournament.playerScore)}</span>
          </div>
          <div
            className={`entry ${tournament.leaderScore < tournament.playerScore ? 'leading' : ''}`}
          >
            <span className="name">{tournament.leaderName}</span>
            <span className="score">{scoreDisplay(tournament.leaderScore)}</span>
          </div>
        </div>
        <div className="holes-remaining">
          {tournament.holesRemaining} holes remaining
        </div>
      </div>

      {/* Hole Info */}
      <div className="hud-panel hole-info">
        <h3>
          Hole {currentHole.holeNumber} - Par {currentHole.par}
        </h3>
        <div className="yardage">{currentHole.yardage} yards</div>
        <div className="stroke-count">Stroke: {strokesThisHole + 1}</div>
        <div className="lie-info">Lie: {String(currentLie).replace('_', ' ')}</div>
      </div>

      {/* Conditions */}
      <div className="hud-panel conditions">
        <h3>Conditions</h3>
        <div className="wind">
          {getWindDescription(currentConditions.windSpeed, currentConditions.windDirection)}
        </div>
        <div className="greens">Green Speed: {currentConditions.greenSpeed.toFixed(1)}</div>
        <div className="firmness">
          {currentConditions.firmness.charAt(0).toUpperCase() + currentConditions.firmness.slice(1)}{' '}
          conditions
        </div>
      </div>

      {/* Last Shot Result */}
      {lastOutcome && (
        <div className={`hud-panel shot-result ${lastOutcome.result}`}>
          <div className="result-text">{lastOutcome.description}</div>
          <div className="distance-to-pin">
            {Math.round(lastOutcome.distanceToPin * 1.094)} yards to pin
          </div>
        </div>
      )}

      {/* Pressure Indicator */}
      <div className={`pressure-indicator ${tournament.currentPressure}`}>
        <span className="pressure-label">Pressure:</span>
        <span className="pressure-level">
          {String(tournament.currentPressure).replace('_', ' ').toUpperCase()}
        </span>
      </div>
    </div>
  );
}
