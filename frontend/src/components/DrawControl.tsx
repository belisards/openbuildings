import { useState, useMemo } from 'react';
import { EditableGeoJsonLayer, DrawPolygonMode, DrawRectangleMode, ViewMode } from '@deck.gl-community/editable-layers';

type DrawMode = 'view' | 'polygon' | 'rectangle';

interface DrawControlProps {
  onDrawComplete: (features: GeoJSON.FeatureCollection) => void;
}

const MODES = {
  view: ViewMode,
  polygon: DrawPolygonMode,
  rectangle: DrawRectangleMode,
};

export function useDrawLayer({ onDrawComplete }: DrawControlProps) {
  const [mode, setMode] = useState<DrawMode>('view');
  const [drawData, setDrawData] = useState<GeoJSON.FeatureCollection>({
    type: 'FeatureCollection',
    features: [],
  });

  const layer = useMemo(() => new EditableGeoJsonLayer({
    id: 'draw-layer',
    data: drawData,
    mode: new MODES[mode](),
    selectedFeatureIndexes: [],
    onEdit: ({ updatedData, editType }: any) => {
      setDrawData(updatedData);
      if (editType === 'addFeature') {
        onDrawComplete(updatedData);
        setMode('view');
      }
    },
    getFillColor: [255, 165, 0, 40],
    getLineColor: [255, 165, 0, 255],
    getLineWidth: 2,
    lineWidthUnits: 'pixels' as const,
  }), [mode, drawData, onDrawComplete]);

  return { layer, mode, setMode, clearDraw: () => setDrawData({ type: 'FeatureCollection', features: [] }) };
}
