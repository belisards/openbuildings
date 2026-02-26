import { useState, useCallback } from 'react';
import { MapView } from './components/MapView';
import { useMapState } from './hooks/useMapState';
import type { PickingInfo } from '@deck.gl/core';

function App() {
  const { viewState, setViewState } = useMapState();
  const [opacity] = useState(0.6);
  const [hoverInfo, setHoverInfo] = useState<PickingInfo | null>(null);

  const onHover = useCallback((info: PickingInfo) => {
    setHoverInfo(info.object ? info : null);
  }, []);

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      <MapView
        buildingData={null}
        areaData={null}
        opacity={opacity}
        viewState={viewState}
        onViewStateChange={setViewState}
        onHover={onHover}
      />

      {hoverInfo?.object && (
        <div style={{
          position: 'absolute',
          left: (hoverInfo as any).x + 10,
          top: (hoverInfo as any).y + 10,
          background: 'rgba(0,0,0,0.85)',
          color: '#fff',
          padding: '8px 12px',
          borderRadius: 6,
          fontSize: 13,
          pointerEvents: 'none',
          zIndex: 10,
        }}>
          <strong>{(hoverInfo.object as any).properties?.primary_name || 'Building'}</strong>
          {(hoverInfo.object as any).properties?.height && (
            <div>Height: {(hoverInfo.object as any).properties.height}m</div>
          )}
          {(hoverInfo.object as any).properties?.class && (
            <div>Class: {(hoverInfo.object as any).properties.class}</div>
          )}
        </div>
      )}
    </div>
  );
}

export default App;
