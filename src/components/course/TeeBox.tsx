import { RigidBody } from '@react-three/rapier';

interface TeeBoxProps {
  position: [number, number, number];
}

export function TeeBox({ position }: TeeBoxProps) {
  return (
    <group position={position}>
      {/* Tee box surface */}
      <RigidBody type="fixed" colliders="cuboid">
        <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.05, 0]}>
          <boxGeometry args={[8, 4, 0.1]} />
          <meshStandardMaterial color="#7bc043" roughness={0.5} />
        </mesh>
      </RigidBody>

      {/* Tee markers */}
      <mesh castShadow position={[-3, 0.15, 0]}>
        <cylinderGeometry args={[0.1, 0.1, 0.3, 8]} />
        <meshStandardMaterial color="#1a237e" roughness={0.3} />
      </mesh>
      <mesh castShadow position={[3, 0.15, 0]}>
        <cylinderGeometry args={[0.1, 0.1, 0.3, 8]} />
        <meshStandardMaterial color="#1a237e" roughness={0.3} />
      </mesh>

      {/* Tee sign */}
      <group position={[-5, 0, 0]}>
        <mesh castShadow position={[0, 0.6, 0]}>
          <cylinderGeometry args={[0.05, 0.05, 1.2, 8]} />
          <meshStandardMaterial color="#5d4037" roughness={0.8} />
        </mesh>
        <mesh castShadow position={[0, 1.3, 0]}>
          <boxGeometry args={[0.8, 0.5, 0.05]} />
          <meshStandardMaterial color="#f5f5f5" roughness={0.5} />
        </mesh>
      </group>
    </group>
  );
}
