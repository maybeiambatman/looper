import { useRef, useEffect } from 'react';
import { useFrame, useThree } from '@react-three/fiber';
import { PointerLockControls } from '@react-three/drei';
import { Vector3 as ThreeVector3 } from 'three';
import { RigidBody, CapsuleCollider } from '@react-three/rapier';
import type { RapierRigidBody } from '@react-three/rapier';

const MOVE_SPEED = 8;
const SPRINT_MULTIPLIER = 1.8;

interface CaddieControllerProps {
  startPosition?: [number, number, number];
  onPositionChange?: (position: ThreeVector3) => void;
}

export function CaddieController({
  startPosition = [0, 2, 0],
  onPositionChange,
}: CaddieControllerProps) {
  const rigidBodyRef = useRef<RapierRigidBody>(null);
  const controlsRef = useRef<any>(null);
  const { camera } = useThree();

  const moveState = useRef({
    forward: false,
    backward: false,
    left: false,
    right: false,
    sprint: false,
  });

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.code) {
        case 'KeyW':
        case 'ArrowUp':
          moveState.current.forward = true;
          break;
        case 'KeyS':
        case 'ArrowDown':
          moveState.current.backward = true;
          break;
        case 'KeyA':
        case 'ArrowLeft':
          moveState.current.left = true;
          break;
        case 'KeyD':
        case 'ArrowRight':
          moveState.current.right = true;
          break;
        case 'ShiftLeft':
        case 'ShiftRight':
          moveState.current.sprint = true;
          break;
      }
    };

    const handleKeyUp = (e: KeyboardEvent) => {
      switch (e.code) {
        case 'KeyW':
        case 'ArrowUp':
          moveState.current.forward = false;
          break;
        case 'KeyS':
        case 'ArrowDown':
          moveState.current.backward = false;
          break;
        case 'KeyA':
        case 'ArrowLeft':
          moveState.current.left = false;
          break;
        case 'KeyD':
        case 'ArrowRight':
          moveState.current.right = false;
          break;
        case 'ShiftLeft':
        case 'ShiftRight':
          moveState.current.sprint = false;
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    window.addEventListener('keyup', handleKeyUp);

    return () => {
      window.removeEventListener('keydown', handleKeyDown);
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, []);

  useFrame(() => {
    if (!rigidBodyRef.current || !controlsRef.current?.isLocked) return;

    const { forward, backward, left, right, sprint } = moveState.current;

    // Get camera direction
    const direction = new ThreeVector3();
    camera.getWorldDirection(direction);
    direction.y = 0;
    direction.normalize();

    // Calculate right vector
    const rightVec = new ThreeVector3();
    rightVec.crossVectors(direction, new ThreeVector3(0, 1, 0));

    // Calculate movement
    const velocity = new ThreeVector3(0, 0, 0);

    if (forward) velocity.add(direction);
    if (backward) velocity.sub(direction);
    if (left) velocity.sub(rightVec);
    if (right) velocity.add(rightVec);

    if (velocity.length() > 0) {
      velocity.normalize();
      const speed = sprint ? MOVE_SPEED * SPRINT_MULTIPLIER : MOVE_SPEED;
      velocity.multiplyScalar(speed);
    }

    // Get current vertical velocity to preserve gravity
    const currentVel = rigidBodyRef.current.linvel();

    rigidBodyRef.current.setLinvel(
      { x: velocity.x, y: currentVel.y, z: velocity.z },
      true
    );

    // Update camera position to follow rigid body
    const pos = rigidBodyRef.current.translation();
    camera.position.set(pos.x, pos.y + 1.6, pos.z); // Eye height offset

    if (onPositionChange) {
      onPositionChange(new ThreeVector3(pos.x, pos.y, pos.z));
    }
  });

  return (
    <>
      <PointerLockControls ref={controlsRef} />
      <RigidBody
        ref={rigidBodyRef}
        position={startPosition}
        enabledRotations={[false, false, false]}
        linearDamping={0.5}
        mass={1}
        type="dynamic"
        colliders={false}
      >
        <CapsuleCollider args={[0.5, 0.5]} />
      </RigidBody>
    </>
  );
}
