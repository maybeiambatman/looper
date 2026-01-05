import type { GolferAttributes, Trinket } from '../types/game';

const FIRST_NAMES = [
  'James', 'Michael', 'Robert', 'David', 'William',
  'Thomas', 'Daniel', 'Matthew', 'Andrew', 'Ryan',
  'Jordan', 'Tyler', 'Brandon', 'Kevin', 'Jason',
  'Justin', 'Cameron', 'Kyle', 'Brian', 'Eric',
];

const LAST_NAMES = [
  'Woods', 'Nicklaus', 'Palmer', 'Player', 'Watson',
  'Mickelson', 'McIlroy', 'Koepka', 'Thomas', 'Spieth',
  'Johnson', 'Rahm', 'Scheffler', 'Morikawa', 'Cantlay',
  'Hovland', 'Burns', 'Finau', 'Schauffele', 'Homa',
];

const PERSONALITIES = [
  'The Grinder', 'The Artist', 'The Bomber', 'The Tactician',
  'The Streaky One', 'The Steady Eddie', 'The Comeback Kid',
  'The Pressure Player', 'The Young Gun', 'The Veteran',
];

function randomRange(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randomElement<T>(arr: T[]): T {
  return arr[Math.floor(Math.random() * arr.length)];
}

export function generatePlayer(difficulty: number, trinkets: Trinket[]): GolferAttributes {
  // Base stats scale with difficulty (harder = better player but more pressure)
  const baseMin = 55 + difficulty * 5;
  const baseMax = 75 + difficulty * 5;

  let power = randomRange(baseMin, baseMax);
  let accuracy = randomRange(baseMin, baseMax);
  let ironPlay = randomRange(baseMin, baseMax);
  let shortGame = randomRange(baseMin, baseMax);
  let putting = randomRange(baseMin, baseMax);
  let clutch = randomRange(baseMin - 10, baseMax - 5); // Clutch is harder to have high
  let consistency = randomRange(baseMin, baseMax);
  let recovery = randomRange(baseMin - 5, baseMax);

  // Apply trinket bonuses
  for (const trinket of trinkets) {
    if (trinket.effectType === 'stat_boost' && trinket.statAffected) {
      const boost = trinket.effectValue;
      switch (trinket.statAffected) {
        case 'power':
          power = Math.min(99, power + boost);
          break;
        case 'accuracy':
          accuracy = Math.min(99, accuracy + boost);
          break;
        case 'ironPlay':
          ironPlay = Math.min(99, ironPlay + boost);
          break;
        case 'shortGame':
          shortGame = Math.min(99, shortGame + boost);
          break;
        case 'putting':
          putting = Math.min(99, putting + boost);
          break;
        case 'clutch':
          clutch = Math.min(99, clutch + boost);
          break;
        case 'consistency':
          consistency = Math.min(99, consistency + boost);
          break;
        case 'recovery':
          recovery = Math.min(99, recovery + boost);
          break;
      }
    }
  }

  const missTendencies: Array<'left' | 'right' | 'straight'> = ['left', 'right', 'straight'];
  const pressureTendencies: Array<'choke' | 'neutral' | 'clutch'> = ['choke', 'neutral', 'clutch'];

  return {
    playerName: `${randomElement(FIRST_NAMES)} ${randomElement(LAST_NAMES)}`,
    personality: randomElement(PERSONALITIES),
    power,
    accuracy,
    ironPlay,
    shortGame,
    putting,
    clutch,
    consistency,
    recovery,
    missTendency: randomElement(missTendencies),
    pressureTendency: randomElement(pressureTendencies),
  };
}

export function generateLeader(difficulty: number): GolferAttributes {
  // Leaders are always strong players
  const baseMin = 70 + difficulty * 3;
  const baseMax = 85 + difficulty * 3;

  return {
    playerName: `${randomElement(FIRST_NAMES)} ${randomElement(LAST_NAMES)}`,
    personality: randomElement(PERSONALITIES),
    power: randomRange(baseMin, baseMax),
    accuracy: randomRange(baseMin, baseMax),
    ironPlay: randomRange(baseMin, baseMax),
    shortGame: randomRange(baseMin, baseMax),
    putting: randomRange(baseMin, baseMax),
    clutch: randomRange(baseMin, baseMax),
    consistency: randomRange(baseMin, baseMax),
    recovery: randomRange(baseMin - 5, baseMax),
    missTendency: randomElement(['left', 'right', 'straight'] as const),
    pressureTendency: 'clutch', // Leaders tend to be clutch
  };
}
