import { useCallback, useRef, useState } from 'react';

interface AreaSelectorProps {
  onAreaSelected: (geojson: GeoJSON.FeatureCollection) => void;
  onFetchBuildings: () => void;
  isLoading: boolean;
}

export function AreaSelector({ onAreaSelected, onFetchBuildings, isLoading }: AreaSelectorProps) {
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [features, setFeatures] = useState<GeoJSON.Feature[]>([]);
  const [selectedNames, setSelectedNames] = useState<string[]>([]);

  const handleFileUpload = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      try {
        const geojson = JSON.parse(event.target?.result as string);
        const feats = geojson.features || [];
        setFeatures(feats);
        const names = feats.map((f: GeoJSON.Feature, i: number) =>
          f.properties?.name || `Feature ${i + 1}`
        );
        setSelectedNames(names);
        onAreaSelected({ type: 'FeatureCollection', features: feats });
      } catch {
        alert('Invalid GeoJSON file');
      }
    };
    reader.readAsText(file);
  }, [onAreaSelected]);

  const handleSelectionChange = useCallback((name: string) => {
    setSelectedNames(prev => {
      const next = prev.includes(name) ? prev.filter(n => n !== name) : [...prev, name];
      const selected = features.filter((f, i) =>
        next.includes(f.properties?.name || `Feature ${i + 1}`)
      );
      onAreaSelected({ type: 'FeatureCollection', features: selected });
      return next;
    });
  }, [features, onAreaSelected]);

  const featureNames = features.map((f, i) => f.properties?.name || `Feature ${i + 1}`);

  return (
    <div className="absolute top-4 left-4 bg-white/95 backdrop-blur rounded-lg shadow-lg p-4 w-72 z-10">
      <h3 className="font-semibold text-gray-800 mb-3">Area Selection</h3>

      <input
        ref={fileInputRef}
        type="file"
        accept=".geojson,.json"
        onChange={handleFileUpload}
        className="hidden"
      />
      <button
        onClick={() => fileInputRef.current?.click()}
        className="w-full px-3 py-2 bg-gray-100 hover:bg-gray-200 rounded text-sm text-gray-700 mb-3 transition"
      >
        Upload GeoJSON
      </button>

      {featureNames.length > 0 && (
        <div className="mb-3 max-h-40 overflow-y-auto">
          {featureNames.map(name => (
            <label key={name} className="flex items-center gap-2 py-1 text-sm text-gray-700 cursor-pointer">
              <input
                type="checkbox"
                checked={selectedNames.includes(name)}
                onChange={() => handleSelectionChange(name)}
              />
              {name}
            </label>
          ))}
        </div>
      )}

      {features.length > 0 && (
        <button
          onClick={onFetchBuildings}
          disabled={isLoading || selectedNames.length === 0}
          className="w-full px-3 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 text-white rounded text-sm font-medium transition"
        >
          {isLoading ? 'Fetching...' : 'Fetch Buildings'}
        </button>
      )}
    </div>
  );
}
