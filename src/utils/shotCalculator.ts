import type {
  ShotRecommendation,
  ShotOutcome,
  GolferAttributes,
  HoleConditions,
  ShotResult,
  Trinket,
  TournamentState,
  Vector3,
  ClubName,
} from '../types/game';
import { LieType, PressureLevel } from '../types/game';

// Club distances in yards
const CLUB_DISTANCES: Record<ClubName, number> = {
  driver: 280,
  '3_wood': 240,
  '5_wood': 220,
  '3_iron': 200,
  '4_iron': 190,
  '5_iron': 180,
  '6_iron': 170,
  '7_iron': 160,
  '8_iron': 150,
  '9_iron': 140,
  pw: 130,
  gw: 115,
  sw: 100,
  lw: 80,
  putter: 0,
};

function yardsToMeters(yards: number): number {
  return yards * 0.9144;
}

function normalRandom(): number {
  // Box-Muller transform for normal distribution
  const u1 = Math.random();
  const u2 = Math.random();
  return Math.sqrt(-2 * Math.log(u1)) * Math.cos(2 * Math.PI * u2);
}

function getLieModifier(lie: LieType): { distance: number; accuracy: number; difficulty: number } {
  switch (lie) {
    case LieType.TEE:
      return { distance: 1.0, accuracy: 1.0, difficulty: 0 };
    case LieType.FAIRWAY:
      return { distance: 1.0, accuracy: 0.95, difficulty: 0.05 };
    case LieType.ROUGH:
      return { distance: 0.85, accuracy: 0.75, difficulty: 0.2 };
    case LieType.DEEP_ROUGH:
      return { distance: 0.7, accuracy: 0.5, difficulty: 0.4 };
    case LieType.BUNKER:
      return { distance: 0.8, accuracy: 0.7, difficulty: 0.3 };
    case LieType.FAIRWAY_BUNKER:
      return { distance: 0.75, accuracy: 0.6, difficulty: 0.35 };
    case LieType.GREEN:
      return { distance: 1.0, accuracy: 1.0, difficulty: 0 };
    case LieType.FRINGE:
      return { distance: 0.95, accuracy: 0.9, difficulty: 0.1 };
    default:
      return { distance: 1.0, accuracy: 1.0, difficulty: 0 };
  }
}

function getPressureModifier(
  player: GolferAttributes,
  tournament: TournamentState
): number {
  const basePressure = tournament.currentPressure === PressureLevel.WIN_OR_LOSE
    ? 0.25
    : tournament.currentPressure === PressureLevel.MUST_PERFORM
      ? 0.15
      : tournament.currentPressure === PressureLevel.CLOSE
        ? 0.08
        : 0;

  // Clutch stat reduces pressure impact
  const clutchReduction = (player.clutch / 100) * 0.7;

  // Pressure tendency modifies further
  let tendencyMod = 0;
  if (player.pressureTendency === 'choke') tendencyMod = 0.1;
  else if (player.pressureTendency === 'clutch') tendencyMod = -0.1;

  return Math.max(0, basePressure * (1 - clutchReduction) + tendencyMod);
}

function applyTrinketEffects(
  baseProbability: number,
  trinkets: Trinket[],
  shotType: string,
  lie: LieType
): number {
  let probability = baseProbability;

  for (const trinket of trinkets) {
    if (trinket.effectType === 'success_boost') {
      if (trinket.shotTypeAffected === shotType || trinket.shotTypeAffected === 'all') {
        probability += trinket.effectValue / 100;
      }
    }
    if (trinket.effectType === 'lie_improvement' && trinket.lieAffected === lie) {
      probability += 0.1;
    }
  }

  return Math.min(0.95, Math.max(0.05, probability));
}

export function calculateShotProbability(
  recommendation: ShotRecommendation,
  player: GolferAttributes,
  conditions: HoleConditions,
  lie: LieType,
  trinkets: Trinket[],
  tournament: TournamentState
): number {
  // Base probability from player skill
  let relevantStat: number;

  switch (recommendation.shotType) {
    case 'drive':
      relevantStat = (player.power + player.accuracy) / 2;
      break;
    case 'approach':
      relevantStat = player.ironPlay;
      break;
    case 'chip':
    case 'pitch':
      relevantStat = player.shortGame;
      break;
    case 'putt':
      relevantStat = player.putting;
      break;
    case 'punch':
    case 'flop':
      relevantStat = (player.recovery + player.shortGame) / 2;
      break;
    default:
      relevantStat = player.accuracy;
  }

  // Base probability from skill (60-90%)
  let probability = 0.5 + (relevantStat / 100) * 0.4;

  // Lie modifier
  const lieMod = getLieModifier(lie);
  probability -= lieMod.difficulty;

  // Consistency modifier (reduces variance, slightly increases average)
  const consistencyBonus = (player.consistency / 100) * 0.05;
  probability += consistencyBonus;

  // Wind effect
  const windEffect = (conditions.windSpeed / 30) * 0.1;
  probability -= windEffect;

  // Pressure effect
  const pressureMod = getPressureModifier(player, tournament);
  probability -= pressureMod;

  // Aggressive shots are harder
  if (recommendation.isAggressive) {
    probability -= 0.15;
  }

  // Apply trinket bonuses
  probability = applyTrinketEffects(probability, trinkets, recommendation.shotType, lie);

  return Math.min(0.95, Math.max(0.1, probability));
}

export function calculateShot(
  recommendation: ShotRecommendation,
  player: GolferAttributes,
  conditions: HoleConditions,
  lie: LieType,
  trinkets: Trinket[],
  tournament: TournamentState
): ShotOutcome {
  const probability = calculateShotProbability(
    recommendation,
    player,
    conditions,
    lie,
    trinkets,
    tournament
  );

  // Roll for outcome
  const roll = Math.random();
  let result: ShotResult;
  let distanceModifier = 1.0;
  let accuracyDeviation = 0;

  if (roll < probability * 0.3) {
    // Perfect shot
    result = 'perfect';
    distanceModifier = 1.0;
    accuracyDeviation = normalRandom() * 2; // Very tight dispersion
  } else if (roll < probability) {
    // Good shot
    result = 'good';
    distanceModifier = 0.95 + Math.random() * 0.1;
    accuracyDeviation = normalRandom() * 5;
  } else if (roll < probability + (1 - probability) * 0.5) {
    // Okay shot
    result = 'okay';
    distanceModifier = 0.85 + Math.random() * 0.15;
    accuracyDeviation = normalRandom() * 12;
  } else if (roll < probability + (1 - probability) * 0.8) {
    // Poor shot
    result = 'poor';
    distanceModifier = 0.7 + Math.random() * 0.2;
    accuracyDeviation = normalRandom() * 20;

    // Apply miss tendency
    if (player.missTendency === 'left') accuracyDeviation -= 5;
    else if (player.missTendency === 'right') accuracyDeviation += 5;
  } else {
    // Disaster
    result = 'disaster';
    distanceModifier = 0.4 + Math.random() * 0.4;
    accuracyDeviation = normalRandom() * 35;

    if (player.missTendency === 'left') accuracyDeviation -= 15;
    else if (player.missTendency === 'right') accuracyDeviation += 15;
  }

  // Apply lie modifiers
  const lieMod = getLieModifier(lie);
  distanceModifier *= lieMod.distance;
  accuracyDeviation /= lieMod.accuracy;

  // Calculate actual distance
  const clubDistance = CLUB_DISTANCES[recommendation.club];
  const powerMod = 0.8 + (player.power / 100) * 0.4; // 80-120% based on power
  const actualDistance = clubDistance * distanceModifier * powerMod;

  // Apply wind
  const windAngleRad = (conditions.windDirection * Math.PI) / 180;
  const windX = Math.sin(windAngleRad) * conditions.windSpeed * 0.3;
  const windZ = -Math.cos(windAngleRad) * conditions.windSpeed * 0.2;

  // Calculate final position
  const distanceMeters = yardsToMeters(actualDistance);
  const targetX = recommendation.targetPosition.x;
  const targetZ = recommendation.targetPosition.z;

  // Direction from current position (assume 0,0 for relative calculation)
  const dirX = targetX;
  const dirZ = targetZ;
  const targetDist = Math.sqrt(dirX * dirX + dirZ * dirZ);

  let finalX: number;
  let finalZ: number;

  if (targetDist > 0) {
    const normX = dirX / targetDist;
    const normZ = dirZ / targetDist;

    // Apply distance along target line
    finalX = normX * distanceMeters + accuracyDeviation + windX;
    finalZ = normZ * distanceMeters + windZ;
  } else {
    finalX = accuracyDeviation + windX;
    finalZ = distanceMeters + windZ;
  }

  // Determine resulting lie based on position
  let resultingLie: LieType = LieType.FAIRWAY;

  // Simple lie determination (would be more complex with actual course data)
  const distanceFromTarget = Math.sqrt(
    Math.pow(finalX - targetX, 2) + Math.pow(finalZ - targetZ, 2)
  );

  if (recommendation.shotType === 'putt') {
    resultingLie = LieType.GREEN;
  } else if (distanceFromTarget < 5) {
    resultingLie = recommendation.shotType === 'approach' ? LieType.GREEN : LieType.FAIRWAY;
  } else if (distanceFromTarget < 15) {
    resultingLie = Math.random() < 0.7 ? LieType.FAIRWAY : LieType.ROUGH;
  } else if (distanceFromTarget < 25) {
    resultingLie = Math.random() < 0.4 ? LieType.ROUGH : LieType.DEEP_ROUGH;
  } else {
    // Very off target - could be in hazard
    const hazardRoll = Math.random();
    if (hazardRoll < 0.2) resultingLie = LieType.BUNKER;
    else if (hazardRoll < 0.3) resultingLie = LieType.WATER; // This would be a penalty
    else resultingLie = LieType.DEEP_ROUGH;
  }

  // Calculate distance to pin (simplified)
  const distanceToPin = Math.sqrt(
    Math.pow(finalX - recommendation.targetPosition.x, 2) +
    Math.pow(finalZ - recommendation.targetPosition.z, 2)
  );

  const finalPosition: Vector3 = {
    x: finalX,
    y: 0, // Simplified - would use terrain height
    z: finalZ,
  };

  return {
    result,
    finalPosition,
    distanceToPin,
    resultingLie,
    description: generateShotDescription(result, recommendation, actualDistance, resultingLie),
  };
}

function generateShotDescription(
  result: ShotResult,
  recommendation: ShotRecommendation,
  distance: number,
  lie: LieType
): string {
  const clubName = recommendation.club.replace('_', ' ');

  switch (result) {
    case 'perfect':
      return `Perfect ${clubName}! ${Math.round(distance)} yards, right on target.`;
    case 'good':
      return `Solid ${clubName}. ${Math.round(distance)} yards, good position.`;
    case 'okay':
      return `Decent ${clubName}. ${Math.round(distance)} yards, playable lie in the ${lie.replace('_', ' ')}.`;
    case 'poor':
      return `Mishit ${clubName}. Only ${Math.round(distance)} yards, in the ${lie.replace('_', ' ')}.`;
    case 'disaster':
      if (lie === LieType.WATER) {
        return `Disaster! ${clubName} finds the water.`;
      }
      return `Big miss with the ${clubName}! ${Math.round(distance)} yards, trouble in the ${lie.replace('_', ' ')}.`;
    default:
      return `${clubName}: ${Math.round(distance)} yards.`;
  }
}

export function getRecommendedClub(
  targetDistance: number,
  lie: LieType,
  conditions: HoleConditions
): ClubName {
  const lieMod = getLieModifier(lie);

  // Account for wind
  const headwindFactor = 1 + conditions.windSpeed * 0.01;

  // Find the club that best matches the target distance
  let bestClub: ClubName = '7_iron';
  let bestDiff = Infinity;

  for (const [club, distance] of Object.entries(CLUB_DISTANCES)) {
    if (club === 'putter') continue; // Handle putter separately

    const effectiveDistance = distance * lieMod.distance / headwindFactor;
    const diff = Math.abs(effectiveDistance - targetDistance);

    if (diff < bestDiff) {
      bestDiff = diff;
      bestClub = club as ClubName;
    }
  }

  return bestClub;
}
