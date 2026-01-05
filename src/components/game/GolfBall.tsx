import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { Sphere } from '@react-three/drei';
import { RigidBody } from '@react-three/rapier';
import type { RapierRigidBody } from '@react-three/rapier';
import { useGameStore } from '../../store/gameStore';

interface GolfBallProps {
  onBallStop?: () => void;
}

export function GolfBall({ onBallStop }: GolfBallProps) {
  const ballRef = useRef<RapierRigidBody>(null);
  const lastVelocity = useRef(0);
  const stoppedFrames = useRef(0);

  const ballPosition = useGameStore((state) => state.ballPosition);

  useFrame(() => {
    if (!ballRef.current) return;

    const vel = ballRef.current.linvel();
    const speed = Math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z);

    // Check if ball has stopped
    if (speed < 0.1 && lastVelocity.current < 0.1) {
      stoppedFrames.current++;
      if (stoppedFrames.current > 30 && onBallStop) {
        onBallStop();
        stoppedFrames.current = 0;
      }
    } else {
      stoppedFrames.current = 0;
    }

    lastVelocity.current = speed;
  });

  return (
    <RigidBody
      ref={ballRef}
      position={[ballPosition.x, ballPosition.y + 0.02, ballPosition.z]}
      colliders="ball"
      restitution={0.6}
      friction={0.8}
      linearDamping={0.5}
      angularDamping={0.5}
      mass={0.045} // Golf ball weight in kg
    >
      <Sphere args={[0.0213, 16, 16]} castShadow>
        <meshStandardMaterial color="white" roughness={0.3} />
      </Sphere>
    </RigidBody>
  );
}

export function BallMarker() {
  const ballPosition = useGameStore((state) => state.ballPosition);
  const markerRef = useRef<any>(null);

  useFrame(({ clock }) => {
    if (markerRef.current) {
      markerRef.current.position.y = 0.5 + Math.sin(clock.elapsedTime * 3) * 0.1;
    }
  });

  return (
    <group position={[ballPosition.x, 0, ballPosition.z]}>
      {/* Ring around ball position */}
      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.01, 0]}>
        <ringGeometry args={[0.3, 0.4, 32]} />
        <meshBasicMaterial color="#ffcc00" transparent opacity={0.7} />
      </mesh>

      {/* Floating arrow */}
      <mesh ref={markerRef} position={[0, 0.5, 0]}>
        <coneGeometry args={[0.1, 0.2, 8]} />
        <meshBasicMaterial color="#ffcc00" />
      </mesh>
    </group>
  );
}
