import { useState, useMemo } from 'react';
import { useGameStore } from '../../store/gameStore';
import { getRecommendedClub } from '../../utils/shotCalculator';
import type { ClubName, ShotType, ShotShape, ShotRecommendation } from '../../types/game';
import { LieType } from '../../types/game';
import './ShotUI.css';

const CLUB_NAMES: Record<ClubName, string> = {
  driver: 'Driver',
  '3_wood': '3 Wood',
  '5_wood': '5 Wood',
  '3_iron': '3 Iron',
  '4_iron': '4 Iron',
  '5_iron': '5 Iron',
  '6_iron': '6 Iron',
  '7_iron': '7 Iron',
  '8_iron': '8 Iron',
  '9_iron': '9 Iron',
  pw: 'PW',
  gw: 'GW',
  sw: 'SW',
  lw: 'LW',
  putter: 'Putter',
};

const SHOT_TYPES: ShotType[] = ['drive', 'approach', 'chip', 'pitch', 'putt', 'punch', 'flop'];

export function ShotUI() {
  const phase = useGameStore((state) => state.phase);
  const holes = useGameStore((state) => state.holes);
  const currentHoleIndex = useGameStore((state) => state.currentHoleIndex);
  const currentConditions = useGameStore((state) => state.currentConditions);
  const currentLie = useGameStore((state) => state.currentLie);
  const ballPosition = useGameStore((state) => state.ballPosition);
  const executeShot = useGameStore((state) => state.executeShot);

  const [selectedClub, setSelectedClub] = useState<ClubName>('7_iron');
  const [shotType, setShotType] = useState<ShotType>('approach');
  const [shotShape, setShotShape] = useState<ShotShape>('straight');
  const [isAggressive, setIsAggressive] = useState(false);
  const [showClubMenu, setShowClubMenu] = useState(false);

  const currentHole = holes[currentHoleIndex];

  const distanceToPin = useMemo(() => {
    if (!currentHole) return 0;
    const dx = currentHole.greenPosition.x - ballPosition.x;
    const dz = currentHole.greenPosition.z - ballPosition.z;
    return Math.sqrt(dx * dx + dz * dz) * 1.094; // Convert to yards
  }, [currentHole, ballPosition]);

  const recommendedClub = useMemo(() => {
    if (!currentConditions) return '7_iron' as ClubName;
    return getRecommendedClub(distanceToPin, currentLie, currentConditions);
  }, [distanceToPin, currentLie, currentConditions]);

  if (phase !== 'playing' || !currentHole) return null;

  // Don't show shot UI on green (putting is automatic for now)
  if (currentLie === LieType.GREEN) {
    return (
      <div className="shot-ui putting">
        <div className="putting-message">
          <h3>On the Green</h3>
          <p>{Math.round(distanceToPin)} feet to the pin</p>
          <button
            className="putt-btn"
            onClick={() => {
              const recommendation: ShotRecommendation = {
                club: 'putter',
                shotType: 'putt',
                targetPosition: currentHole.greenPosition,
                confidence: 0.8,
                reasoning: 'Standard putt to the hole',
                shotShape: 'straight',
                isAggressive: false,
              };
              executeShot(recommendation);
            }}
          >
            Putt
          </button>
        </div>
      </div>
    );
  }

  const handleExecuteShot = () => {
    const recommendation: ShotRecommendation = {
      club: selectedClub,
      shotType,
      targetPosition: currentHole.greenPosition,
      confidence: 0.7,
      reasoning: `${CLUB_NAMES[selectedClub]} ${shotType} to the green`,
      shotShape,
      isAggressive,
    };
    executeShot(recommendation);
  };

  return (
    <div className="shot-ui">
      <div className="shot-panel">
        <div className="distance-display">
          <span className="distance-value">{Math.round(distanceToPin)}</span>
          <span className="distance-unit">yards</span>
        </div>

        <div className="club-selection">
          <div className="recommended-club">
            Recommended: {CLUB_NAMES[recommendedClub]}
          </div>

          <button className="club-btn" onClick={() => setShowClubMenu(!showClubMenu)}>
            {CLUB_NAMES[selectedClub]}
            <span className="dropdown-arrow">▼</span>
          </button>

          {showClubMenu && (
            <div className="club-menu">
              {(Object.keys(CLUB_NAMES) as ClubName[]).map((club) => (
                <button
                  key={club}
                  className={`club-option ${club === selectedClub ? 'selected' : ''}`}
                  onClick={() => {
                    setSelectedClub(club);
                    setShowClubMenu(false);
                  }}
                >
                  {CLUB_NAMES[club]}
                </button>
              ))}
            </div>
          )}
        </div>

        <div className="shot-type-selection">
          <label>Shot Type</label>
          <div className="shot-type-buttons">
            {SHOT_TYPES.filter((t) => t !== 'putt').map((type) => (
              <button
                key={type}
                className={`type-btn ${type === shotType ? 'selected' : ''}`}
                onClick={() => setShotType(type)}
              >
                {type.charAt(0).toUpperCase() + type.slice(1)}
              </button>
            ))}
          </div>
        </div>

        <div className="shot-shape-selection">
          <label>Shot Shape</label>
          <div className="shape-buttons">
            <button
              className={`shape-btn ${shotShape === 'draw' ? 'selected' : ''}`}
              onClick={() => setShotShape('draw')}
            >
              Draw
            </button>
            <button
              className={`shape-btn ${shotShape === 'straight' ? 'selected' : ''}`}
              onClick={() => setShotShape('straight')}
            >
              Straight
            </button>
            <button
              className={`shape-btn ${shotShape === 'fade' ? 'selected' : ''}`}
              onClick={() => setShotShape('fade')}
            >
              Fade
            </button>
          </div>
        </div>

        <div className="aggressive-toggle">
          <label>
            <input
              type="checkbox"
              checked={isAggressive}
              onChange={(e) => setIsAggressive(e.target.checked)}
            />
            Aggressive (higher risk/reward)
          </label>
        </div>

        <button className="execute-btn" onClick={handleExecuteShot}>
          Execute Shot
        </button>
      </div>
    </div>
  );
}
