import { RigidBody } from '@react-three/rapier';

interface GreenProps {
  position: [number, number, number];
  size: number;
  pinPosition: 'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center';
}

export function Green({ position, size, pinPosition: _pinPosition }: GreenProps) {
  // Create slightly irregular green shape using multiple overlapping circles
  return (
    <group position={position}>
      {/* Main green surface */}
      <RigidBody type="fixed" colliders="cuboid">
        <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.03, 0]}>
          <circleGeometry args={[size, 32]} />
          <meshStandardMaterial color="#7bc043" roughness={0.4} />
        </mesh>
      </RigidBody>

      {/* Fringe around green */}
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.025, 0]}>
        <ringGeometry args={[size, size + 2, 32]} />
        <meshStandardMaterial color="#68a83a" roughness={0.6} />
      </mesh>

      {/* Collar/apron */}
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.02, 0]}>
        <ringGeometry args={[size + 2, size + 4, 32]} />
        <meshStandardMaterial color="#5a9c33" roughness={0.7} />
      </mesh>
    </group>
  );
}

export function getPinOffset(
  pinPosition: 'front_left' | 'front_right' | 'back_left' | 'back_right' | 'center',
  greenSize: number
): [number, number] {
  const offset = greenSize * 0.4;

  switch (pinPosition) {
    case 'front_left':
      return [-offset * 0.7, -offset];
    case 'front_right':
      return [offset * 0.7, -offset];
    case 'back_left':
      return [-offset * 0.7, offset];
    case 'back_right':
      return [offset * 0.7, offset];
    case 'center':
    default:
      return [0, 0];
  }
}
