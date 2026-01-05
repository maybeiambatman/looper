import { useEffect } from 'react';
import { GameScene } from './components/game';
import { MainMenu, HUD, ShotUI, YardageBook, TrinketSelect, RunComplete } from './components/ui';
import { useGameStore } from './store/gameStore';
import './App.css';

function App() {
  const loadMetaProgression = useGameStore((state) => state.loadMetaProgression);

  useEffect(() => {
    loadMetaProgression();
  }, [loadMetaProgression]);

  return (
    <div className="app">
      {/* Main menu */}
      <MainMenu />

      {/* 3D game scene */}
      <GameScene />

      {/* UI overlays */}
      <HUD />
      <ShotUI />
      <YardageBook />
      <TrinketSelect />
      <RunComplete />
    </div>
  );
}

export default App;
