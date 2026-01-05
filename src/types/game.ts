// Core game types for Final Five

// Shot types - using simple strings for easier comparison
export type ShotType = 'drive' | 'approach' | 'chip' | 'pitch' | 'putt' | 'punch' | 'flop' | 'bunker' | 'recovery';

export type ShotShape = 'straight' | 'fade' | 'draw' | 'punch' | 'high' | 'flop' | 'bump_and_run';

// Lie types as const object (instead of enum for erasableSyntaxOnly compatibility)
export const LieType = {
  TEE: 'tee',
  FAIRWAY: 'fairway',
  ROUGH: 'rough',
  DEEP_ROUGH: 'deep_rough',
  BUNKER: 'bunker',
  FAIRWAY_BUNKER: 'fairway_bunker',
  GREEN: 'green',
  FRINGE: 'fringe',
  WATER: 'water',
} as const;
export type LieType = typeof LieType[keyof typeof LieType];

export type ShotResult = 'perfect' | 'good' | 'okay' | 'poor' | 'disaster';

// Pressure levels as const object
export const PressureLevel = {
  COMFORTABLE: 'comfortable',
  CLOSE: 'close',
  MUST_PERFORM: 'must_perform',
  WIN_OR_LOSE: 'win_or_lose',
} as const;
export type PressureLevel = typeof PressureLevel[keyof typeof PressureLevel];

export type HoleType =
  | 'par3_island'
  | 'par3_long'
  | 'par4_risk_reward'
  | 'par4_positional'
  | 'par5_eagle';

export type TrinketRarity = 'common' | 'uncommon' | 'rare' | 'legendary';

export type TrinketEffectType =
  | 'stat_boost'
  | 'lie_improvement'
  | 'success_boost'
  | 'mulligan'
  | 'pressure_immunity';

export interface Vector3 {
  x: number;
  y: number;
  z: number;
}

export interface GolferAttributes {
  playerName: string;
  personality: string;
  power: number;
  accuracy: number;
  ironPlay: number;
  shortGame: number;
  putting: number;
  clutch: number;
  consistency: number;
  recovery: number;
  missTendency: 'left' | 'right' | 'straight';
  pressureTendency: 'choke' | 'neutral' | 'clutch';
}

export interface ClubDistances {
  driver: number;
  '3_wood': number;
  '5_wood': number;
  '3_iron': number;
  '4_iron': number;
  '5_iron': number;
  '6_iron': number;
  '7_iron': number;
  '8_iron': number;
  '9_iron': number;
  pw: number;
  gw: number;
  sw: number;
  lw: number;
  putter: number;
}

export type ClubName = keyof ClubDistances;

export interface ShotRecommendation {
  club: ClubName;
  shotType: ShotType;
  targetPosition: Vector3;
  confidence: number;
  reasoning: string;
  shotShape: ShotShape;
  isAggressive: boolean;
}

export interface ShotOutcome {
  result: ShotResult;
  finalPosition: Vector3;
  distanceToPin: number;
  resultingLie: LieType;
  description: string;
}

export interface HoleConditions {
  windDirection: number; // degrees (0-360)
  windSpeed: number;
  greenSpeed: number; // stimpmeter
  firmness: 'soft' | 'medium' | 'firm';
  lieQuality: number;
  pressureModifier: number;
  description: string;
}

export interface Hazard {
  type: 'water' | 'bunker' | 'trees' | 'rough';
  position: Vector3;
  size: Vector3;
}

export interface HoleData {
  holeNumber: number;
  par: number;
  yardage: number;
  holeType: HoleType;
  teePosition: Vector3;
  greenPosition: Vector3;
  pinPosition: 'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center';
  hazards: Hazard[];
  fairwayWidth: number;
  greenSize: number;
  greenContour: 'flat' | 'front_to_back' | 'back_to_front' | 'left_to_right' | 'right_to_left' | 'tiered';
  elevation: number;
}

export interface TournamentState {
  leaderScore: number;
  playerScore: number;
  holesRemaining: number;
  leaderName: string;
  leaderHoleScores: number[];
  playerHoleScores: number[];
  currentPressure: PressureLevel;
}

export interface Trinket {
  id: string;
  name: string;
  description: string;
  rarity: TrinketRarity;
  effectType: TrinketEffectType;
  effectValue: number;
  statAffected?: string;
  shotTypeAffected?: string;
  lieAffected?: string;
  conditionAffected?: string;
}

export interface MetaProgression {
  caddieLevel: number;
  totalXp: number;
  totalRuns: number;
  wins: number;
  losses: number;
  highestRun: number;
  unlockedTrinkets: string[];
  permanentUpgrades: string[];
  statistics: Record<string, number>;
}

export interface RunData {
  runNumber: number;
  difficulty: number;
  currentHole: number;
  holeScores: number[];
  shotsTaken: number;
  goodDecisions: number;
  badDecisions: number;
  won: boolean;
  activeTrinkets: Trinket[];
}

export type GamePhase =
  | 'menu'
  | 'playing'
  | 'shot_setup'
  | 'shot_executing'
  | 'hole_complete'
  | 'run_complete'
  | 'trinket_select';
