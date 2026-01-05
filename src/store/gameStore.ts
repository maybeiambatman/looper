import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';
import type {
  GamePhase,
  GolferAttributes,
  TournamentState,
  HoleData,
  HoleConditions,
  ShotRecommendation,
  ShotOutcome,
  Trinket,
  MetaProgression,
  RunData,
  Vector3,
  ClubName,
} from '../types/game';
import { LieType, PressureLevel } from '../types/game';
import { generatePlayer, generateLeader } from '../utils/golferGenerator';
import { generateHoles } from '../utils/holeGenerator';
import { generateConditions } from '../utils/conditionsGenerator';
import { calculateShot } from '../utils/shotCalculator';

interface GameState {
  // Game phase
  phase: GamePhase;

  // Current run data
  run: RunData | null;
  player: GolferAttributes | null;
  tournament: TournamentState | null;
  holes: HoleData[];
  currentHoleIndex: number;
  currentConditions: HoleConditions | null;

  // Ball state
  ballPosition: Vector3;
  currentLie: LieType;
  strokesThisHole: number;
  isOnGreen: boolean;

  // Active trinkets
  activeTrinkets: Trinket[];

  // Meta progression
  metaProgression: MetaProgression;

  // Shot state
  currentRecommendation: ShotRecommendation | null;
  lastOutcome: ShotOutcome | null;
  selectedClub: ClubName;
  mulliganAvailable: boolean;

  // Actions
  startNewRun: (difficulty: number) => void;
  startHole: (holeIndex: number) => void;
  executeShot: (recommendation: ShotRecommendation) => ShotOutcome;
  completeHole: () => void;
  completeRun: () => void;
  setPhase: (phase: GamePhase) => void;
  setSelectedClub: (club: ClubName) => void;
  useMulligan: () => boolean;
  addTrinket: (trinket: Trinket) => void;
  loadMetaProgression: () => void;
  saveMetaProgression: () => void;
}

const initialMetaProgression: MetaProgression = {
  caddieLevel: 1,
  totalXp: 0,
  totalRuns: 0,
  wins: 0,
  losses: 0,
  highestRun: 0,
  unlockedTrinkets: [],
  permanentUpgrades: [],
  statistics: {},
};

export const useGameStore = create<GameState>()(
  immer((set, get) => ({
    // Initial state
    phase: 'menu',
    run: null,
    player: null,
    tournament: null,
    holes: [],
    currentHoleIndex: 0,
    currentConditions: null,
    ballPosition: { x: 0, y: 0, z: 0 },
    currentLie: LieType.TEE,
    strokesThisHole: 0,
    isOnGreen: false,
    activeTrinkets: [],
    metaProgression: initialMetaProgression,
    currentRecommendation: null,
    lastOutcome: null,
    selectedClub: '7_iron',
    mulliganAvailable: false,

    startNewRun: (difficulty: number) => {
      const state = get();
      const player = generatePlayer(difficulty, state.activeTrinkets);
      const leader = generateLeader(difficulty);
      const holes = generateHoles(difficulty);

      set((draft) => {
        draft.run = {
          runNumber: draft.metaProgression.totalRuns + 1,
          difficulty,
          currentHole: 0,
          holeScores: [],
          shotsTaken: 0,
          goodDecisions: 0,
          badDecisions: 0,
          won: false,
          activeTrinkets: draft.activeTrinkets,
        };

        draft.player = player;

        draft.tournament = {
          leaderScore: -10 - difficulty,
          playerScore: -10 - difficulty + difficulty,
          holesRemaining: 5,
          leaderName: leader.playerName,
          leaderHoleScores: [],
          playerHoleScores: [],
          currentPressure: PressureLevel.CLOSE,
        };

        draft.holes = holes;
        draft.currentHoleIndex = 0;
        draft.phase = 'playing';

        // Check for mulligan trinket
        draft.mulliganAvailable = draft.activeTrinkets.some(
          (t) => t.effectType === 'mulligan'
        );
      });

      // Start first hole
      get().startHole(0);
    },

    startHole: (holeIndex: number) => {
      const state = get();
      const hole = state.holes[holeIndex];
      if (!hole) return;

      const conditions = generateConditions(state.run?.difficulty ?? 1);

      set((draft) => {
        draft.currentHoleIndex = holeIndex;
        draft.currentConditions = conditions;
        draft.strokesThisHole = 0;
        draft.ballPosition = { ...hole.teePosition };
        draft.currentLie = LieType.TEE;
        draft.isOnGreen = false;
        draft.phase = 'playing';
      });
    },

    executeShot: (recommendation: ShotRecommendation) => {
      const state = get();
      if (!state.player || !state.currentConditions || !state.tournament) {
        throw new Error('Game state not initialized');
      }

      const outcome = calculateShot(
        recommendation,
        state.player,
        state.currentConditions,
        state.currentLie,
        state.activeTrinkets,
        state.tournament
      );

      set((draft) => {
        draft.strokesThisHole += 1;
        if (draft.run) {
          draft.run.shotsTaken += 1;

          if (outcome.result === 'perfect' || outcome.result === 'good') {
            draft.run.goodDecisions += 1;
          } else if (outcome.result === 'disaster') {
            draft.run.badDecisions += 1;
          }
        }

        draft.ballPosition = outcome.finalPosition;
        draft.currentLie = outcome.resultingLie;
        draft.isOnGreen = outcome.resultingLie === LieType.GREEN;
        draft.lastOutcome = outcome;
        draft.currentRecommendation = recommendation;
      });

      return outcome;
    },

    completeHole: () => {
      const state = get();
      const hole = state.holes[state.currentHoleIndex];
      if (!hole || !state.tournament || !state.run) return;

      const score = state.strokesThisHole - hole.par;

      // Simulate leader's score for this hole
      const leaderScore = Math.floor(Math.random() * 4) - 1; // -1 to +2

      set((draft) => {
        if (!draft.tournament || !draft.run) return;

        draft.run.holeScores.push(score);
        draft.tournament.playerScore += score;
        draft.tournament.playerHoleScores.push(score);

        draft.tournament.leaderScore += leaderScore;
        draft.tournament.leaderHoleScores.push(leaderScore);
        draft.tournament.holesRemaining -= 1;

        // Update pressure
        const deficit = draft.tournament.playerScore - draft.tournament.leaderScore;
        if (draft.tournament.holesRemaining <= 1) {
          if (deficit >= 2) {
            draft.tournament.currentPressure = PressureLevel.WIN_OR_LOSE;
          } else if (deficit >= 1) {
            draft.tournament.currentPressure = PressureLevel.MUST_PERFORM;
          } else {
            draft.tournament.currentPressure = PressureLevel.CLOSE;
          }
        } else {
          if (deficit >= 3) {
            draft.tournament.currentPressure = PressureLevel.MUST_PERFORM;
          } else if (deficit >= 1) {
            draft.tournament.currentPressure = PressureLevel.CLOSE;
          } else {
            draft.tournament.currentPressure = PressureLevel.COMFORTABLE;
          }
        }

        draft.phase = 'hole_complete';
      });
    },

    completeRun: () => {
      const state = get();
      if (!state.tournament || !state.run) return;

      const won = state.tournament.playerScore <= state.tournament.leaderScore;

      set((draft) => {
        if (!draft.run) return;
        draft.run.won = won;

        // Calculate XP
        let xp = draft.run.shotsTaken * 5;
        xp += draft.run.goodDecisions * 20;
        xp -= draft.run.badDecisions * 5;
        if (won) {
          xp += 200 + draft.run.difficulty * 50;
        }
        xp = Math.max(0, xp);

        // Update meta progression
        draft.metaProgression.totalXp += xp;
        draft.metaProgression.totalRuns += 1;
        if (won) {
          draft.metaProgression.wins += 1;
          if (draft.run.runNumber > draft.metaProgression.highestRun) {
            draft.metaProgression.highestRun = draft.run.runNumber;
          }
        } else {
          draft.metaProgression.losses += 1;
        }

        // Level up check
        const xpThresholds = [0, 100, 250, 500, 800, 1200, 1700, 2300, 3000];
        while (
          draft.metaProgression.caddieLevel < xpThresholds.length &&
          draft.metaProgression.totalXp >= xpThresholds[draft.metaProgression.caddieLevel]
        ) {
          draft.metaProgression.caddieLevel += 1;
        }

        draft.phase = won ? 'trinket_select' : 'run_complete';
      });

      get().saveMetaProgression();
    },

    setPhase: (phase: GamePhase) => {
      set((draft) => {
        draft.phase = phase;
      });
    },

    setSelectedClub: (club: ClubName) => {
      set((draft) => {
        draft.selectedClub = club;
      });
    },

    useMulligan: () => {
      const state = get();
      if (!state.mulliganAvailable) return false;

      set((draft) => {
        draft.mulliganAvailable = false;
        draft.strokesThisHole -= 1;
        if (draft.run) {
          draft.run.shotsTaken -= 1;
        }
      });

      return true;
    },

    addTrinket: (trinket: Trinket) => {
      set((draft) => {
        draft.activeTrinkets.push(trinket);
        if (!draft.metaProgression.unlockedTrinkets.includes(trinket.id)) {
          draft.metaProgression.unlockedTrinkets.push(trinket.id);
        }
      });
      get().saveMetaProgression();
    },

    loadMetaProgression: () => {
      try {
        const saved = localStorage.getItem('finalFive_meta');
        if (saved) {
          const data = JSON.parse(saved) as MetaProgression;
          set((draft) => {
            draft.metaProgression = data;
          });
        }
      } catch (e) {
        console.error('Failed to load meta progression:', e);
      }
    },

    saveMetaProgression: () => {
      const state = get();
      try {
        localStorage.setItem('finalFive_meta', JSON.stringify(state.metaProgression));
      } catch (e) {
        console.error('Failed to save meta progression:', e);
      }
    },
  }))
);
