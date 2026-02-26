import type { BuildingMetadata } from '../types';

interface DataSummaryProps {
  metadata: BuildingMetadata | null;
  onExport: () => void;
  opacity: number;
  onOpacityChange: (v: number) => void;
}

export function DataSummary({ metadata, onExport, opacity, onOpacityChange }: DataSummaryProps) {
  if (!metadata) return null;

  return (
    <div className="absolute top-4 right-4 bg-white/95 backdrop-blur rounded-lg shadow-lg p-4 w-72 z-10">
      <h3 className="font-semibold text-gray-800 mb-2">
        {metadata.total_buildings.toLocaleString()} Buildings
      </h3>

      {metadata.truncated && (
        <div className="text-amber-600 text-xs mb-2">Display limit reached</div>
      )}

      <div className="text-sm text-gray-600 space-y-1 mb-3">
        {metadata.avg_height !== null && (
          <div>Height: {metadata.avg_height}m avg ({metadata.height_coverage_pct}% coverage)</div>
        )}
        <div>Floors: {metadata.floor_coverage_pct}% coverage</div>
        <div>Classes: {metadata.class_coverage_pct}% coverage</div>

        {Object.keys(metadata.source_breakdown).length > 0 && (
          <div className="mt-2">
            <div className="font-medium text-gray-700">Sources</div>
            {Object.entries(metadata.source_breakdown)
              .sort(([, a], [, b]) => b - a)
              .map(([source, count]) => (
                <div key={source} className="ml-2">
                  {source}: {Math.round(count / metadata.total_buildings * 100)}%
                </div>
              ))}
          </div>
        )}
      </div>

      <div className="mb-3">
        <label className="text-xs text-gray-500">Opacity</label>
        <input
          type="range"
          min="0"
          max="1"
          step="0.1"
          value={opacity}
          onChange={e => onOpacityChange(parseFloat(e.target.value))}
          className="w-full"
        />
      </div>

      <button
        onClick={onExport}
        className="w-full px-3 py-2 bg-green-600 hover:bg-green-700 text-white rounded text-sm font-medium transition"
      >
        Download GeoJSON
      </button>

      <div className="mt-2 text-xs text-gray-400">
        Overture {metadata.overture_release}
      </div>
    </div>
  );
}
