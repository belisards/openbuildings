import { useState, useCallback, useEffect } from 'react';
import { MapView } from './components/MapView';
import { AreaSelector } from './components/AreaSelector';
import { DataSummary } from './components/DataSummary';
import { MiniGlobe } from './components/MiniGlobe';
import { useMapState } from './hooks/useMapState';
import type { BuildingMetadata } from './types';
import type { PickingInfo } from '@deck.gl/core';

function App() {
  const { viewState, setViewState } = useMapState();
  const [opacity, setOpacity] = useState(0.6);
  const [hoverInfo, setHoverInfo] = useState<PickingInfo | null>(null);
  const [areaData, setAreaData] = useState<GeoJSON.FeatureCollection | null>(null);
  const [buildingData, setBuildingData] = useState<GeoJSON.FeatureCollection | null>(null);
  const [metadata, setMetadata] = useState<BuildingMetadata | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [dataReady, setDataReady] = useState(false);

  useEffect(() => {
    const check = async () => {
      try {
        const res = await fetch('/api/health');
        const data = await res.json();
        if (data.data_ready) {
          setDataReady(true);
          return;
        }
      } catch {}
      setTimeout(check, 5000);
    };
    check();
  }, []);

  const onHover = useCallback((info: PickingInfo) => {
    setHoverInfo(info.object ? info : null);
  }, []);

  const handleExport = useCallback(async () => {
    if (!areaData?.features.length) return;
    const response = await fetch('/api/export', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ geometry: areaData.features[0].geometry, limit: 50000 }),
    });
    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'overture_buildings.geojson';
    a.click();
    URL.revokeObjectURL(url);
  }, [areaData]);

  const handleFetchBuildings = useCallback(async () => {
    if (!areaData?.features.length) return;
    setIsLoading(true);
    try {
      const response = await fetch('/api/buildings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ geometry: areaData.features[0].geometry, limit: 50000 }),
      });
      const data = await response.json();
      setBuildingData(data);
      setMetadata(data.metadata);
    } catch (err) {
      console.error('Failed to fetch buildings:', err);
    } finally {
      setIsLoading(false);
    }
  }, [areaData]);

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative' }}>
      <MapView
        buildingData={buildingData}
        areaData={areaData}
        opacity={opacity}
        viewState={viewState}
        onViewStateChange={setViewState}
        onHover={onHover}
      />

      <AreaSelector
        onAreaSelected={setAreaData}
        onFetchBuildings={handleFetchBuildings}
        isLoading={isLoading}
      />

      <DataSummary
        metadata={metadata}
        onExport={handleExport}
        opacity={opacity}
        onOpacityChange={setOpacity}
      />

      <MiniGlobe longitude={viewState.longitude} latitude={viewState.latitude} />

      {!dataReady && (
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/80 text-white px-4 py-2 rounded-lg text-sm z-20">
          Data index not found. Run: uv run python -m backend.scripts.build_index
        </div>
      )}

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
