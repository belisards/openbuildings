import { useMemo } from 'react';
import { Map, useControl } from 'react-map-gl/maplibre';
import { MapboxOverlay } from '@deck.gl/mapbox';
import { GeoJsonLayer } from '@deck.gl/layers';
import type { DeckProps, PickingInfo } from '@deck.gl/core';
import 'maplibre-gl/dist/maplibre-gl.css';

interface MapViewProps {
  buildingData: GeoJSON.FeatureCollection | null;
  areaData: GeoJSON.FeatureCollection | null;
  opacity: number;
  viewState: { longitude: number; latitude: number; zoom: number; pitch: number; bearing: number };
  onViewStateChange: (vs: any) => void;
  onHover?: (info: PickingInfo) => void;
}

function DeckGLOverlay(props: DeckProps) {
  const overlay = useControl<MapboxOverlay>(() => new MapboxOverlay(props));
  overlay.setProps(props);
  return null;
}

const SATELLITE_STYLE = {
  version: 8 as const,
  sources: {
    'arcgis-imagery': {
      type: 'raster' as const,
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
      tileSize: 256,
    },
  },
  layers: [{
    id: 'arcgis-imagery',
    type: 'raster' as const,
    source: 'arcgis-imagery',
  }],
};

export function MapView({ buildingData, areaData, opacity, viewState, onViewStateChange, onHover }: MapViewProps) {
  const layers = useMemo(() => {
    const result = [];

    if (areaData) {
      result.push(new GeoJsonLayer({
        id: 'area-selection',
        data: areaData,
        filled: true,
        stroked: true,
        getFillColor: [51, 136, 255, 50],
        getLineColor: [51, 136, 255, 200],
        getLineWidth: 2,
        lineWidthUnits: 'pixels' as const,
      }));
    }

    if (buildingData) {
      result.push(new GeoJsonLayer({
        id: 'buildings',
        data: buildingData,
        filled: true,
        stroked: true,
        getFillColor: [255, 120, 0, Math.round(opacity * 100)],
        getLineColor: [255, 120, 0, Math.round(opacity * 255)],
        getLineWidth: 1,
        lineWidthUnits: 'pixels' as const,
        pickable: true,
        autoHighlight: true,
        highlightColor: [255, 200, 0, 180],
        onHover,
      }));
    }

    return result;
  }, [buildingData, areaData, opacity, onHover]);

  return (
    <Map
      {...viewState}
      onMove={evt => onViewStateChange(evt.viewState)}
      mapStyle={SATELLITE_STYLE}
      style={{ width: '100%', height: '100%' }}
    >
      <DeckGLOverlay layers={layers} />
    </Map>
  );
}
