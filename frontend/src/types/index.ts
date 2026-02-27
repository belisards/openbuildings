export interface BuildingProperties {
  id: string;
  height?: number;
  num_floors?: number;
  class?: string;
  subtype?: string;
  primary_name?: string;
  sources?: Array<{ dataset: string; record_id?: string }>;
}

export interface BuildingMetadata {
  total_buildings: number;
  truncated: boolean;
  overture_release: string;
  height_coverage_pct: number;
  floor_coverage_pct: number;
  class_coverage_pct: number;
  avg_height: number | null;
  source_breakdown: Record<string, number>;
}

export interface MapViewState {
  longitude: number;
  latitude: number;
  zoom: number;
  pitch: number;
  bearing: number;
}
