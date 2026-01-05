import { useMemo } from 'react';
import { Shape } from 'three';

interface FairwayProps {
  teePosition: [number, number, number];
  greenPosition: [number, number, number];
  width: number;
}

export function Fairway({ teePosition, greenPosition, width }: FairwayProps) {
  const geometry = useMemo(() => {
    const shape = new Shape();
    const halfWidth = width / 2;

    // Create fairway shape from tee to green
    const length = greenPosition[2] - teePosition[2];

    // Start narrow at tee, widen in landing zone, narrow again near green
    shape.moveTo(-halfWidth * 0.3, 0);
    shape.lineTo(-halfWidth * 0.3, length * 0.1); // Narrow start
    shape.bezierCurveTo(
      -halfWidth * 0.8,
      length * 0.2,
      -halfWidth,
      length * 0.3,
      -halfWidth,
      length * 0.4
    ); // Widen to landing zone
    shape.lineTo(-halfWidth, length * 0.7); // Wide through middle
    shape.bezierCurveTo(
      -halfWidth * 0.8,
      length * 0.85,
      -halfWidth * 0.5,
      length * 0.95,
      -halfWidth * 0.4,
      length
    ); // Narrow to green
    shape.lineTo(halfWidth * 0.4, length); // Connect to other side
    shape.bezierCurveTo(
      halfWidth * 0.5,
      length * 0.95,
      halfWidth * 0.8,
      length * 0.85,
      halfWidth,
      length * 0.7
    );
    shape.lineTo(halfWidth, length * 0.4);
    shape.bezierCurveTo(
      halfWidth,
      length * 0.3,
      halfWidth * 0.8,
      length * 0.2,
      halfWidth * 0.3,
      length * 0.1
    );
    shape.lineTo(halfWidth * 0.3, 0);
    shape.closePath();

    return shape;
  }, [greenPosition, teePosition, width]);

  return (
    <mesh
      receiveShadow
      rotation={[-Math.PI / 2, 0, 0]}
      position={[teePosition[0], 0.02, teePosition[2]]}
    >
      <shapeGeometry args={[geometry]} />
      <meshStandardMaterial color="#5a9c33" roughness={0.7} />
    </mesh>
  );
}
