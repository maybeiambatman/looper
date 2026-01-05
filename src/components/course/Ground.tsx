import { RigidBody } from '@react-three/rapier';

export function Ground() {
  // Simple grass ground without textures for now
  return (
    <RigidBody type="fixed" colliders="cuboid">
      <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 200]}>
        <boxGeometry args={[500, 600, 1]} />
        <meshStandardMaterial color="#4a7c23" roughness={0.9} />
      </mesh>
    </RigidBody>
  );
}

export function RoughGround() {
  return (
    <mesh receiveShadow rotation={[-Math.PI / 2, 0, 0]} position={[0, 0.01, 200]}>
      <planeGeometry args={[500, 600]} />
      <meshStandardMaterial color="#3d6b1e" roughness={1} />
    </mesh>
  );
}
