import { useRef, useState, useEffect } from 'react';
import { useFrame } from '@react-three/fiber';
import { Group } from 'three';
import { useGameStore } from '../../store/gameStore';

interface GolferProps {
  position: [number, number, number];
  rotation?: number;
}

// Animation phases
type SwingPhase = 'idle' | 'backswing' | 'downswing' | 'followthrough' | 'reset';

export function Golfer({ position, rotation = 0 }: GolferProps) {
  const groupRef = useRef<Group>(null);
  const clubRef = useRef<Group>(null);
  const armRef = useRef<Group>(null);

  const [swingPhase, setSwingPhase] = useState<SwingPhase>('idle');
  const [swingProgress, setSwingProgress] = useState(0);

  const lastOutcome = useGameStore((state) => state.lastOutcome);
  const strokesThisHole = useGameStore((state) => state.strokesThisHole);

  // Trigger swing animation when a shot is executed
  useEffect(() => {
    if (lastOutcome && strokesThisHole > 0) {
      setSwingPhase('backswing');
      setSwingProgress(0);
    }
  }, [lastOutcome, strokesThisHole]);

  useFrame((_, delta) => {
    if (!clubRef.current || !armRef.current) return;

    const swingSpeed = 3;

    switch (swingPhase) {
      case 'backswing':
        setSwingProgress((prev) => {
          const next = prev + delta * swingSpeed;
          if (next >= 1) {
            setSwingPhase('downswing');
            return 1;
          }
          return next;
        });
        // Rotate arms and club back
        armRef.current.rotation.x = -swingProgress * 1.5;
        clubRef.current.rotation.x = -swingProgress * 0.5;
        break;

      case 'downswing':
        setSwingProgress((prev) => {
          const next = prev - delta * swingSpeed * 2.5; // Faster downswing
          if (next <= -0.3) {
            setSwingPhase('followthrough');
            return -0.3;
          }
          return next;
        });
        armRef.current.rotation.x = -swingProgress * 1.5;
        clubRef.current.rotation.x = -swingProgress * 0.5;
        break;

      case 'followthrough':
        setSwingProgress((prev) => {
          const next = prev - delta * swingSpeed * 1.5;
          if (next <= -1.2) {
            setSwingPhase('reset');
            return -1.2;
          }
          return next;
        });
        armRef.current.rotation.x = -swingProgress * 1.2;
        clubRef.current.rotation.x = -swingProgress * 0.3;
        break;

      case 'reset':
        setSwingProgress((prev) => {
          const next = prev + delta * swingSpeed * 0.5;
          if (next >= 0) {
            setSwingPhase('idle');
            return 0;
          }
          return next;
        });
        armRef.current.rotation.x = -swingProgress * 1.2;
        clubRef.current.rotation.x = -swingProgress * 0.3;
        break;

      case 'idle':
      default:
        // Subtle breathing animation
        if (groupRef.current) {
          groupRef.current.position.y = position[1] + Math.sin(Date.now() * 0.002) * 0.01;
        }
        break;
    }
  });

  return (
    <group ref={groupRef} position={position} rotation={[0, rotation, 0]}>
      {/* Body */}
      <group>
        {/* Torso */}
        <mesh position={[0, 1.1, 0]} castShadow>
          <capsuleGeometry args={[0.2, 0.5, 8, 16]} />
          <meshStandardMaterial color="#1a365d" /> {/* Dark blue polo */}
        </mesh>

        {/* Head */}
        <mesh position={[0, 1.65, 0]} castShadow>
          <sphereGeometry args={[0.12, 16, 16]} />
          <meshStandardMaterial color="#d4a574" /> {/* Skin tone */}
        </mesh>

        {/* Cap */}
        <mesh position={[0, 1.75, 0.02]} castShadow>
          <cylinderGeometry args={[0.13, 0.14, 0.08, 16]} />
          <meshStandardMaterial color="#ffffff" />
        </mesh>
        <mesh position={[0, 1.73, 0.15]} rotation={[0.3, 0, 0]} castShadow>
          <boxGeometry args={[0.15, 0.02, 0.1]} />
          <meshStandardMaterial color="#ffffff" />
        </mesh>

        {/* Legs */}
        <mesh position={[-0.08, 0.45, 0]} castShadow>
          <capsuleGeometry args={[0.08, 0.5, 8, 16]} />
          <meshStandardMaterial color="#2d3748" /> {/* Dark pants */}
        </mesh>
        <mesh position={[0.08, 0.45, 0]} castShadow>
          <capsuleGeometry args={[0.08, 0.5, 8, 16]} />
          <meshStandardMaterial color="#2d3748" />
        </mesh>

        {/* Shoes */}
        <mesh position={[-0.08, 0.05, 0.03]} castShadow>
          <boxGeometry args={[0.1, 0.08, 0.2]} />
          <meshStandardMaterial color="#1a1a1a" />
        </mesh>
        <mesh position={[0.08, 0.05, 0.03]} castShadow>
          <boxGeometry args={[0.1, 0.08, 0.2]} />
          <meshStandardMaterial color="#1a1a1a" />
        </mesh>

        {/* Arms group - animated */}
        <group ref={armRef} position={[0, 1.2, 0]}>
          {/* Left arm */}
          <mesh position={[-0.25, -0.15, 0.1]} rotation={[0.3, 0, 0.3]} castShadow>
            <capsuleGeometry args={[0.05, 0.35, 8, 16]} />
            <meshStandardMaterial color="#1a365d" />
          </mesh>
          {/* Left hand */}
          <mesh position={[-0.3, -0.4, 0.25]} castShadow>
            <sphereGeometry args={[0.05, 8, 8]} />
            <meshStandardMaterial color="#d4a574" />
          </mesh>

          {/* Right arm */}
          <mesh position={[0.25, -0.15, 0.1]} rotation={[0.3, 0, -0.3]} castShadow>
            <capsuleGeometry args={[0.05, 0.35, 8, 16]} />
            <meshStandardMaterial color="#1a365d" />
          </mesh>
          {/* Right hand */}
          <mesh position={[0.3, -0.4, 0.25]} castShadow>
            <sphereGeometry args={[0.05, 8, 8]} />
            <meshStandardMaterial color="#d4a574" />
          </mesh>

          {/* Golf club group */}
          <group ref={clubRef} position={[0, -0.4, 0.25]}>
            {/* Grip */}
            <mesh position={[0, 0.15, 0]} castShadow>
              <cylinderGeometry args={[0.015, 0.018, 0.3, 8]} />
              <meshStandardMaterial color="#2d2d2d" />
            </mesh>

            {/* Shaft */}
            <mesh position={[0, -0.35, 0]} castShadow>
              <cylinderGeometry args={[0.008, 0.01, 0.8, 8]} />
              <meshStandardMaterial color="#c0c0c0" metalness={0.8} roughness={0.2} />
            </mesh>

            {/* Club head */}
            <mesh position={[0, -0.8, 0.04]} rotation={[0.2, 0, 0]} castShadow>
              <boxGeometry args={[0.08, 0.06, 0.1]} />
              <meshStandardMaterial color="#404040" metalness={0.9} roughness={0.1} />
            </mesh>
          </group>
        </group>
      </group>
    </group>
  );
}
