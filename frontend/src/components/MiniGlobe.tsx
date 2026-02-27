import { Map, Marker } from 'react-map-gl/maplibre';

interface MiniGlobeProps {
  longitude: number;
  latitude: number;
}

const GLOBE_STYLE = {
  version: 8 as const,
  sources: {
    'osm-raster': {
      type: 'raster' as const,
      tiles: ['https://tile.openstreetmap.org/{z}/{x}/{y}.png'],
      tileSize: 256,
      attribution: '&copy; OpenStreetMap',
    },
  },
  layers: [{
    id: 'osm-raster',
    type: 'raster' as const,
    source: 'osm-raster',
  }],
};

export function MiniGlobe({ longitude, latitude }: MiniGlobeProps) {
  return (
    <div className="absolute bottom-4 right-4 w-36 h-36 rounded-full overflow-hidden shadow-lg border-2 border-white/50 z-10">
      <Map
        longitude={longitude}
        latitude={latitude}
        zoom={1}
        interactive={false}
        mapStyle={GLOBE_STYLE}
        style={{ width: '100%', height: '100%' }}
        attributionControl={false}
      >
        <Marker longitude={longitude} latitude={latitude}>
          <div style={{
            width: 8,
            height: 8,
            background: '#ff4444',
            borderRadius: '50%',
            border: '2px solid white',
            boxShadow: '0 0 6px rgba(255,68,68,0.8)',
          }} />
        </Marker>
      </Map>
    </div>
  );
}
