import { Suspense, useMemo } from 'react';
import { Canvas } from '@react-three/fiber';
import { Sky, Environment } from '@react-three/drei';
import { Physics } from '@react-three/rapier';
import { CaddieController } from './CaddieController';
import { GolfBall, BallMarker } from './GolfBall';
import { Golfer } from './Golfer';
import { GolfCourse } from '../course';
import { useGameStore } from '../../store/gameStore';

function LoadingScreen() {
  return (
    <mesh>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="gray" />
    </mesh>
  );
}

function GameWorld() {
  const phase = useGameStore((state) => state.phase);
  const isOnGreen = useGameStore((state) => state.isOnGreen);
  const completeHole = useGameStore((state) => state.completeHole);
  const ballPosition = useGameStore((state) => state.ballPosition);
  const holes = useGameStore((state) => state.holes);
  const currentHoleIndex = useGameStore((state) => state.currentHoleIndex);

  const handleBallStop = () => {
    if (isOnGreen) {
      // Ball stopped on green after putt - complete the hole
      completeHole();
    }
  };

  // Calculate golfer rotation to face the green
  const golferRotation = useMemo(() => {
    const currentHole = holes[currentHoleIndex];
    if (!currentHole) return 0;

    const dx = currentHole.greenPosition.x - ballPosition.x;
    const dz = currentHole.greenPosition.z - ballPosition.z;
    return Math.atan2(dx, dz);
  }, [holes, currentHoleIndex, ballPosition]);

  if (phase !== 'playing') return null;

  return (
    <>
      {/* Lighting */}
      <ambientLight intensity={0.4} />
      <directionalLight
        position={[50, 100, 50]}
        intensity={1}
        castShadow
        shadow-mapSize-width={2048}
        shadow-mapSize-height={2048}
        shadow-camera-far={500}
        shadow-camera-left={-200}
        shadow-camera-right={200}
        shadow-camera-top={200}
        shadow-camera-bottom={-200}
      />

      {/* Sky */}
      <Sky
        distance={450000}
        sunPosition={[100, 50, 100]}
        inclination={0.6}
        azimuth={0.25}
      />

      {/* Environment for reflections */}
      <Environment preset="park" />

      {/* Physics world */}
      <Physics gravity={[0, -9.81, 0]}>
        {/* Golf course */}
        <GolfCourse />

        {/* Player (Caddie) */}
        <CaddieController startPosition={[0, 2, -5]} />

        {/* Golf ball */}
        <GolfBall onBallStop={handleBallStop} />
      </Physics>

      {/* Ball position marker */}
      <BallMarker />

      {/* Golfer character */}
      <Golfer
        position={[ballPosition.x, 0, ballPosition.z]}
        rotation={golferRotation}
      />
    </>
  );
}

export function GameScene() {
  const phase = useGameStore((state) => state.phase);

  if (phase === 'menu') return null;

  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <Canvas
        shadows
        camera={{
          fov: 75,
          near: 0.1,
          far: 1000,
          position: [0, 2, -5],
        }}
        onPointerDown={(e) => {
          // Request pointer lock on click
          (e.target as HTMLElement).requestPointerLock?.();
        }}
      >
        <Suspense fallback={<LoadingScreen />}>
          <GameWorld />
        </Suspense>
      </Canvas>
    </div>
  );
}
