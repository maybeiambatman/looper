import type { HoleData, HoleType, Vector3 } from '../types/game';

interface HoleTemplate {
  type: HoleType;
  par: number;
  minYardage: number;
  maxYardage: number;
  hazardChance: number;
}

const HOLE_TEMPLATES: HoleTemplate[] = [
  { type: 'par3_island', par: 3, minYardage: 140, maxYardage: 200, hazardChance: 0.9 },
  { type: 'par3_long', par: 3, minYardage: 200, maxYardage: 250, hazardChance: 0.5 },
  { type: 'par4_risk_reward', par: 4, minYardage: 320, maxYardage: 420, hazardChance: 0.8 },
  { type: 'par4_positional', par: 4, minYardage: 400, maxYardage: 480, hazardChance: 0.6 },
  { type: 'par5_eagle', par: 5, minYardage: 500, maxYardage: 600, hazardChance: 0.7 },
];

function randomRange(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function yardsToMeters(yards: number): number {
  return yards * 0.9144;
}

function generateHazards(
  template: HoleTemplate,
  yardage: number,
  difficulty: number
): Array<{ type: 'water' | 'bunker' | 'trees' | 'rough'; position: Vector3; size: Vector3 }> {
  const hazards: Array<{ type: 'water' | 'bunker' | 'trees' | 'rough'; position: Vector3; size: Vector3 }> = [];
  const hazardCount = Math.floor(Math.random() * (2 + difficulty)) + 1;

  const hazardTypes: Array<'water' | 'bunker' | 'trees' | 'rough'> = ['water', 'bunker', 'trees', 'rough'];

  for (let i = 0; i < hazardCount; i++) {
    if (Math.random() > template.hazardChance) continue;

    const type = hazardTypes[Math.floor(Math.random() * hazardTypes.length)];
    const distanceFromTee = yardsToMeters(yardage * (0.3 + Math.random() * 0.5));
    const lateralOffset = (Math.random() - 0.5) * 40;

    hazards.push({
      type,
      position: { x: lateralOffset, y: 0, z: distanceFromTee },
      size: {
        x: 10 + Math.random() * 20,
        y: type === 'trees' ? 15 : 1,
        z: 10 + Math.random() * 20,
      },
    });
  }

  // Par 3 island green always has water around the green
  if (template.type === 'par3_island') {
    const greenZ = yardsToMeters(yardage);
    hazards.push({
      type: 'water',
      position: { x: 0, y: -0.5, z: greenZ },
      size: { x: 60, y: 1, z: 60 },
    });
  }

  return hazards;
}

function generatePinPosition(template: HoleTemplate): 'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center' {
  const positions: Array<'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center'> = [
    'front_left',
    'front_right',
    'back_left',
    'back_right',
    'center',
  ];

  // Island greens often have center pins
  if (template.type === 'par3_island' && Math.random() < 0.4) {
    return 'center';
  }

  return positions[Math.floor(Math.random() * positions.length)];
}

function generateGreenContour(): 'flat' | 'front_to_back' | 'back_to_front' | 'left_to_right' | 'right_to_left' | 'tiered' {
  const contours: Array<'flat' | 'front_to_back' | 'back_to_front' | 'left_to_right' | 'right_to_left' | 'tiered'> = [
    'flat',
    'front_to_back',
    'back_to_front',
    'left_to_right',
    'right_to_left',
    'tiered',
  ];
  return contours[Math.floor(Math.random() * contours.length)];
}

export function generateHoles(difficulty: number): HoleData[] {
  const holes: HoleData[] = [];

  // Final 5 holes (14-18) - ensure variety
  const usedTypes = new Set<HoleType>();
  const holeNumbers = [14, 15, 16, 17, 18];

  for (let i = 0; i < 5; i++) {
    // Pick a template we haven't used yet, or any if all used
    let template: HoleTemplate;
    const availableTemplates = HOLE_TEMPLATES.filter((t) => !usedTypes.has(t.type));

    if (availableTemplates.length > 0) {
      template = availableTemplates[Math.floor(Math.random() * availableTemplates.length)];
    } else {
      template = HOLE_TEMPLATES[Math.floor(Math.random() * HOLE_TEMPLATES.length)];
    }

    usedTypes.add(template.type);

    const yardage = randomRange(template.minYardage, template.maxYardage);
    const yardageMeters = yardsToMeters(yardage);

    const hole: HoleData = {
      holeNumber: holeNumbers[i],
      par: template.par,
      yardage,
      holeType: template.type,
      teePosition: { x: 0, y: 0, z: 0 },
      greenPosition: { x: 0, y: 0, z: yardageMeters },
      pinPosition: generatePinPosition(template),
      hazards: generateHazards(template, yardage, difficulty),
      fairwayWidth: template.par === 3 ? 0 : 25 + Math.random() * 15,
      greenSize: 15 + Math.random() * 10,
      greenContour: generateGreenContour(),
      elevation: (Math.random() - 0.5) * 20, // -10 to +10 meters
    };

    holes.push(hole);
  }

  return holes;
}
