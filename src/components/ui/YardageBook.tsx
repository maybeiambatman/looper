import { useState, useEffect } from 'react';
import { useGameStore } from '../../store/gameStore';
import { getWindDescription, getGreenSpeedDescription } from '../../utils/conditionsGenerator';
import './YardageBook.css';

export function YardageBook() {
  const [isOpen, setIsOpen] = useState(false);

  const phase = useGameStore((state) => state.phase);
  const holes = useGameStore((state) => state.holes);
  const currentHoleIndex = useGameStore((state) => state.currentHoleIndex);
  const currentConditions = useGameStore((state) => state.currentConditions);
  const player = useGameStore((state) => state.player);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.code === 'Tab' && phase === 'playing') {
        e.preventDefault();
        setIsOpen((prev) => !prev);
      }
      if (e.code === 'Escape' && isOpen) {
        setIsOpen(false);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [phase, isOpen]);

  if (phase !== 'playing' || !isOpen) return null;

  const currentHole = holes[currentHoleIndex];
  if (!currentHole || !currentConditions || !player) return null;

  return (
    <div className="yardage-book-overlay" onClick={() => setIsOpen(false)}>
      <div className="yardage-book" onClick={(e) => e.stopPropagation()}>
        <button className="close-btn" onClick={() => setIsOpen(false)}>
          ×
        </button>

        <div className="book-header">
          <h2>Yardage Book</h2>
          <div className="hole-title">
            Hole {currentHole.holeNumber} - Par {currentHole.par}
          </div>
        </div>

        <div className="book-content">
          <div className="book-section hole-details">
            <h3>Hole Details</h3>
            <div className="detail-row">
              <span>Distance:</span>
              <span>{currentHole.yardage} yards</span>
            </div>
            <div className="detail-row">
              <span>Type:</span>
              <span>{currentHole.holeType.replace(/_/g, ' ')}</span>
            </div>
            <div className="detail-row">
              <span>Pin Position:</span>
              <span>{currentHole.pinPosition.replace(/_/g, ' ')}</span>
            </div>
            <div className="detail-row">
              <span>Green Contour:</span>
              <span>{currentHole.greenContour.replace(/_/g, ' ')}</span>
            </div>
            <div className="detail-row">
              <span>Elevation:</span>
              <span>
                {currentHole.elevation > 0 ? '+' : ''}
                {Math.round(currentHole.elevation)}m
              </span>
            </div>
          </div>

          <div className="book-section conditions-section">
            <h3>Conditions</h3>
            <div className="detail-row">
              <span>Wind:</span>
              <span>
                {getWindDescription(
                  currentConditions.windSpeed,
                  currentConditions.windDirection
                )}
              </span>
            </div>
            <div className="detail-row">
              <span>Green Speed:</span>
              <span>{getGreenSpeedDescription(currentConditions.greenSpeed)}</span>
            </div>
            <div className="detail-row">
              <span>Firmness:</span>
              <span>
                {currentConditions.firmness.charAt(0).toUpperCase() +
                  currentConditions.firmness.slice(1)}
              </span>
            </div>
          </div>

          <div className="book-section hazards-section">
            <h3>Hazards</h3>
            {currentHole.hazards.length === 0 ? (
              <p className="no-hazards">No significant hazards</p>
            ) : (
              <ul className="hazard-list">
                {currentHole.hazards.map((hazard, index) => (
                  <li key={index} className={`hazard-item ${hazard.type}`}>
                    <span className="hazard-type">{hazard.type}</span>
                    <span className="hazard-dist">
                      {Math.round(hazard.position.z * 1.094)} yards
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </div>

          <div className="book-section player-section">
            <h3>Player: {player.playerName}</h3>
            <div className="player-stats">
              <div className="stat">
                <span className="stat-name">Power</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.power}%` }}></div>
                </div>
                <span className="stat-value">{player.power}</span>
              </div>
              <div className="stat">
                <span className="stat-name">Accuracy</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.accuracy}%` }}></div>
                </div>
                <span className="stat-value">{player.accuracy}</span>
              </div>
              <div className="stat">
                <span className="stat-name">Iron Play</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.ironPlay}%` }}></div>
                </div>
                <span className="stat-value">{player.ironPlay}</span>
              </div>
              <div className="stat">
                <span className="stat-name">Short Game</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.shortGame}%` }}></div>
                </div>
                <span className="stat-value">{player.shortGame}</span>
              </div>
              <div className="stat">
                <span className="stat-name">Putting</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.putting}%` }}></div>
                </div>
                <span className="stat-value">{player.putting}</span>
              </div>
              <div className="stat">
                <span className="stat-name">Clutch</span>
                <div className="stat-bar">
                  <div className="stat-fill" style={{ width: `${player.clutch}%` }}></div>
                </div>
                <span className="stat-value">{player.clutch}</span>
              </div>
            </div>
            <div className="player-traits">
              <span>Personality: {player.personality}</span>
              <span>Miss tendency: {player.missTendency}</span>
              <span>Under pressure: {player.pressureTendency}</span>
            </div>
          </div>
        </div>

        <div className="book-footer">
          <span>Press TAB to close</span>
        </div>
      </div>
    </div>
  );
}
