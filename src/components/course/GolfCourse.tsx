import { useMemo } from 'react';
import { useGameStore } from '../../store/gameStore';
import { Ground } from './Ground';
import { Fairway } from './Fairway';
import { Green } from './Green';
import { Hazard } from './Hazard';
import { TeeBox } from './TeeBox';
import { FlagStick } from './FlagStick';

export function GolfCourse() {
  const holes = useGameStore((state) => state.holes);
  const currentHoleIndex = useGameStore((state) => state.currentHoleIndex);

  const currentHole = useMemo(() => {
    return holes[currentHoleIndex];
  }, [holes, currentHoleIndex]);

  if (!currentHole) {
    return <Ground />;
  }

  return (
    <group>
      {/* Base terrain */}
      <Ground />

      {/* Tee box */}
      <TeeBox position={[currentHole.teePosition.x, 0, currentHole.teePosition.z]} />

      {/* Fairway (for par 4s and par 5s) */}
      {currentHole.par > 3 && (
        <Fairway
          teePosition={[currentHole.teePosition.x, 0, currentHole.teePosition.z]}
          greenPosition={[currentHole.greenPosition.x, 0, currentHole.greenPosition.z]}
          width={currentHole.fairwayWidth}
        />
      )}

      {/* Green */}
      <Green
        position={[currentHole.greenPosition.x, 0, currentHole.greenPosition.z]}
        size={currentHole.greenSize}
        pinPosition={currentHole.pinPosition}
      />

      {/* Flag */}
      <FlagStick
        greenPosition={[currentHole.greenPosition.x, 0, currentHole.greenPosition.z]}
        pinPosition={currentHole.pinPosition}
        greenSize={currentHole.greenSize}
      />

      {/* Hazards */}
      {currentHole.hazards.map((hazard, index) => (
        <Hazard
          key={index}
          type={hazard.type}
          position={[hazard.position.x, hazard.position.y, hazard.position.z]}
          size={[hazard.size.x, hazard.size.y, hazard.size.z]}
        />
      ))}
    </group>
  );
}
