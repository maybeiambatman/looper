import { RigidBody } from '@react-three/rapier';
import { useRef } from 'react';
import { useFrame } from '@react-three/fiber';

interface HazardProps {
  type: 'water' | 'bunker' | 'trees' | 'rough';
  position: [number, number, number];
  size: [number, number, number];
}

export function Hazard({ type, position, size }: HazardProps) {
  switch (type) {
    case 'water':
      return <WaterHazard position={position} size={size} />;
    case 'bunker':
      return <Bunker position={position} size={size} />;
    case 'trees':
      return <Trees position={position} size={size} />;
    case 'rough':
      return <DeepRough position={position} size={size} />;
    default:
      return null;
  }
}

function WaterHazard({
  position,
  size,
}: {
  position: [number, number, number];
  size: [number, number, number];
}) {
  const waterRef = useRef<any>(null);

  useFrame(({ clock }) => {
    if (waterRef.current) {
      // Subtle water movement
      waterRef.current.position.y = position[1] - 0.1 + Math.sin(clock.elapsedTime * 0.5) * 0.02;
    }
  });

  return (
    <group position={position}>
      {/* Water surface */}
      <mesh ref={waterRef} receiveShadow rotation={[-Math.PI / 2, 0, 0]}>
        <planeGeometry args={[size[0], size[2]]} />
        <meshStandardMaterial
          color="#2d5a7b"
          roughness={0.1}
          metalness={0.3}
          transparent
          opacity={0.85}
        />
      </mesh>

      {/* Water edge/bank */}
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.15, 0]}>
        <ringGeometry args={[Math.min(size[0], size[2]) / 2, Math.min(size[0], size[2]) / 2 + 1, 32]} />
        <meshStandardMaterial color="#8b7355" roughness={0.9} />
      </mesh>
    </group>
  );
}

function Bunker({
  position,
  size,
}: {
  position: [number, number, number];
  size: [number, number, number];
}) {
  return (
    <RigidBody type="fixed" colliders="cuboid" position={position}>
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.1, 0]}>
        <planeGeometry args={[size[0], size[2]]} />
        <meshStandardMaterial color="#f4e4bc" roughness={1} />
      </mesh>

      {/* Bunker lip */}
      <mesh receiveShadow>
        <torusGeometry args={[Math.min(size[0], size[2]) / 2, 0.3, 8, 32]} />
        <meshStandardMaterial color="#5a7c33" roughness={0.8} />
      </mesh>
    </RigidBody>
  );
}

function Trees({
  position,
  size,
}: {
  position: [number, number, number];
  size: [number, number, number];
}) {
  // Generate a cluster of simple trees
  const treeCount = Math.floor((size[0] * size[2]) / 50);
  const trees = [];

  for (let i = 0; i < treeCount; i++) {
    const x = (Math.random() - 0.5) * size[0];
    const z = (Math.random() - 0.5) * size[2];
    const height = 8 + Math.random() * 7;
    const trunkHeight = height * 0.4;

    trees.push(
      <group key={i} position={[x, 0, z]}>
        {/* Trunk */}
        <mesh castShadow position={[0, trunkHeight / 2, 0]}>
          <cylinderGeometry args={[0.3, 0.4, trunkHeight, 8]} />
          <meshStandardMaterial color="#5d4037" roughness={0.9} />
        </mesh>

        {/* Foliage */}
        <mesh castShadow position={[0, trunkHeight + height * 0.3, 0]}>
          <coneGeometry args={[2.5, height * 0.6, 8]} />
          <meshStandardMaterial color="#2e7d32" roughness={0.8} />
        </mesh>
      </group>
    );
  }

  return <group position={position}>{trees}</group>;
}

function DeepRough({
  position,
  size,
}: {
  position: [number, number, number];
  size: [number, number, number];
}) {
  return (
    <mesh receiveShadow position={position} rotation={[-Math.PI / 2, 0, 0]}>
      <planeGeometry args={[size[0], size[2]]} />
      <meshStandardMaterial color="#2d5a1e" roughness={1} />
    </mesh>
  );
}
