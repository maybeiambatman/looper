import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';
import { getPinOffset } from './Green';

interface FlagStickProps {
  greenPosition: [number, number, number];
  pinPosition: 'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center';
  greenSize: number;
}

export function FlagStick({ greenPosition, pinPosition, greenSize }: FlagStickProps) {
  const flagRef = useRef<any>(null);
  const [offsetX, offsetZ] = getPinOffset(pinPosition, greenSize);

  useFrame(({ clock }) => {
    if (flagRef.current) {
      // Subtle flag wave animation
      flagRef.current.rotation.y = Math.sin(clock.elapsedTime * 2) * 0.1;
      flagRef.current.scale.x = 1 + Math.sin(clock.elapsedTime * 3) * 0.05;
    }
  });

  return (
    <group position={[greenPosition[0] + offsetX, 0, greenPosition[2] + offsetZ]}>
      {/* Hole cup */}
      <mesh position={[0, 0.01, 0]} rotation={[-Math.PI / 2, 0, 0]}>
        <ringGeometry args={[0.05, 0.054, 16]} />
        <meshStandardMaterial color="#333333" />
      </mesh>

      {/* Flag pole */}
      <mesh castShadow position={[0, 1.1, 0]}>
        <cylinderGeometry args={[0.015, 0.02, 2.2, 8]} />
        <meshStandardMaterial color="#f5f5f5" metalness={0.3} roughness={0.4} />
      </mesh>

      {/* Flag */}
      <mesh ref={flagRef} castShadow position={[0.2, 2, 0]}>
        <planeGeometry args={[0.4, 0.25]} />
        <meshStandardMaterial color="#ff0000" side={2} roughness={0.6} />
      </mesh>

      {/* Flag number (simplified) */}
      <mesh position={[0.2, 2, 0.01]}>
        <planeGeometry args={[0.15, 0.15]} />
        <meshStandardMaterial color="#ffffff" />
      </mesh>
    </group>
  );
}
