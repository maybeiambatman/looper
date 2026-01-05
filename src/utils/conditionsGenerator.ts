import type { HoleConditions } from '../types/game';

function randomRange(min: number, max: number): number {
  return min + Math.random() * (max - min);
}

export function generateConditions(difficulty: number): HoleConditions {
  // Wind gets stronger at higher difficulties
  const baseWindSpeed = 5 + difficulty * 3;
  const windVariance = 5 + difficulty * 2;

  const windSpeed = Math.max(0, randomRange(baseWindSpeed - windVariance, baseWindSpeed + windVariance));
  const windDirection = Math.random() * 360; // 0-360 degrees

  // Green speed (stimpmeter) - faster at higher difficulty
  const baseGreenSpeed = 10 + difficulty * 0.5;
  const greenSpeed = randomRange(baseGreenSpeed - 1, baseGreenSpeed + 2);

  // Firmness affects how much the ball releases
  const firmnessOptions: Array<'soft' | 'medium' | 'firm'> = ['soft', 'medium', 'firm'];
  const firmness = firmnessOptions[Math.floor(Math.random() * firmnessOptions.length)];

  // Lie quality in fairway (higher difficulty = more varied lies)
  const lieQuality = Math.max(0.5, 1.0 - difficulty * 0.1 - Math.random() * 0.2);

  // Pressure modifier (tournament situation)
  const pressureModifier = 1.0 + difficulty * 0.1;

  // Conditions description
  const conditions: string[] = [];
  if (windSpeed > 15) conditions.push('Gusty');
  else if (windSpeed > 8) conditions.push('Breezy');
  else conditions.push('Calm');

  if (greenSpeed > 13) conditions.push('Lightning fast greens');
  else if (greenSpeed > 11) conditions.push('Fast greens');
  else conditions.push('Medium greens');

  if (firmness === 'firm') conditions.push('Firm conditions');
  else if (firmness === 'soft') conditions.push('Soft conditions');

  return {
    windSpeed,
    windDirection,
    greenSpeed,
    firmness,
    lieQuality,
    pressureModifier,
    description: conditions.join(', '),
  };
}

export function getWindDescription(speed: number, direction: number): string {
  const speedDesc =
    speed < 5 ? 'Light' : speed < 10 ? 'Moderate' : speed < 15 ? 'Strong' : 'Very strong';

  // Convert degrees to compass direction
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  const index = Math.round(direction / 45) % 8;
  const dirDesc = directions[index];

  return `${speedDesc} wind from ${dirDesc} (${Math.round(speed)} mph)`;
}

export function getGreenSpeedDescription(speed: number): string {
  if (speed >= 14) return 'Tournament fast (14+)';
  if (speed >= 12) return 'Fast (12-14)';
  if (speed >= 10) return 'Medium-fast (10-12)';
  return 'Medium (< 10)';
}
