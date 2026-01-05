import { useState } from 'react';
import { useGameStore } from '../../store/gameStore';
import type { Trinket, TrinketRarity } from '../../types/game';
import './TrinketSelect.css';

const TRINKET_POOL: Omit<Trinket, 'id'>[] = [
  {
    name: 'Lucky Ball Marker',
    description: '+5 to putting on clutch putts',
    rarity: 'common',
    effectType: 'stat_boost',
    effectValue: 5,
    statAffected: 'putting',
  },
  {
    name: 'Vintage Divot Tool',
    description: '+8 to iron play',
    rarity: 'common',
    effectType: 'stat_boost',
    effectValue: 8,
    statAffected: 'ironPlay',
  },
  {
    name: 'Power Tee',
    description: '+10 to power on drives',
    rarity: 'common',
    effectType: 'stat_boost',
    effectValue: 10,
    statAffected: 'power',
  },
  {
    name: 'Steady Gloves',
    description: '+7 to consistency',
    rarity: 'common',
    effectType: 'stat_boost',
    effectValue: 7,
    statAffected: 'consistency',
  },
  {
    name: 'Bunker Rake',
    description: '+10% success from bunkers',
    rarity: 'uncommon',
    effectType: 'lie_improvement',
    effectValue: 10,
    lieAffected: 'bunker',
  },
  {
    name: "Tiger's Tooth",
    description: '+12 to clutch stat',
    rarity: 'uncommon',
    effectType: 'stat_boost',
    effectValue: 12,
    statAffected: 'clutch',
  },
  {
    name: 'Magic Mulligan',
    description: 'Get one free mulligan per run',
    rarity: 'rare',
    effectType: 'mulligan',
    effectValue: 1,
  },
  {
    name: 'Wind Whistle',
    description: '+15% accuracy in windy conditions',
    rarity: 'rare',
    effectType: 'success_boost',
    effectValue: 15,
    conditionAffected: 'wind',
  },
  {
    name: 'Golden Driver',
    description: '+15 to power, +5 to accuracy',
    rarity: 'legendary',
    effectType: 'stat_boost',
    effectValue: 15,
    statAffected: 'power',
  },
  {
    name: "Champion's Spirit",
    description: '+20 to clutch, pressure never affects you',
    rarity: 'legendary',
    effectType: 'pressure_immunity',
    effectValue: 20,
    statAffected: 'clutch',
  },
];

function generateTrinketOptions(count: number): Trinket[] {
  const shuffled = [...TRINKET_POOL].sort(() => Math.random() - 0.5);
  return shuffled.slice(0, count).map((trinket, index) => ({
    ...trinket,
    id: `trinket_${Date.now()}_${index}`,
  }));
}

export function TrinketSelect() {
  const phase = useGameStore((state) => state.phase);
  const addTrinket = useGameStore((state) => state.addTrinket);
  const setPhase = useGameStore((state) => state.setPhase);
  const [trinketOptions] = useState(() => generateTrinketOptions(3));

  if (phase !== 'trinket_select') return null;

  const handleSelectTrinket = (trinket: Trinket) => {
    addTrinket(trinket);
    setPhase('run_complete');
  };

  const handleSkip = () => {
    setPhase('run_complete');
  };

  const getRarityColor = (rarity: TrinketRarity) => {
    switch (rarity) {
      case 'common':
        return '#9e9e9e';
      case 'uncommon':
        return '#4caf50';
      case 'rare':
        return '#2196f3';
      case 'legendary':
        return '#ff9800';
    }
  };

  return (
    <div className="trinket-select-overlay">
      <div className="trinket-select">
        <h1>Victory!</h1>
        <p className="victory-message">You've won the tournament!</p>

        <h2>Choose a Trinket</h2>
        <p className="trinket-instruction">
          Select a trinket to add to your collection for future runs
        </p>

        <div className="trinket-options">
          {trinketOptions.map((trinket) => (
            <button
              key={trinket.id}
              className={`trinket-card ${trinket.rarity}`}
              onClick={() => handleSelectTrinket(trinket)}
              style={{ borderColor: getRarityColor(trinket.rarity) }}
            >
              <div
                className="trinket-rarity"
                style={{ color: getRarityColor(trinket.rarity) }}
              >
                {trinket.rarity.toUpperCase()}
              </div>
              <div className="trinket-name">{trinket.name}</div>
              <div className="trinket-description">{trinket.description}</div>
            </button>
          ))}
        </div>

        <button className="skip-btn" onClick={handleSkip}>
          Skip Trinket
        </button>
      </div>
    </div>
  );
}
