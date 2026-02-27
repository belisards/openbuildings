import { useState } from 'react';
import type { MapViewState } from '../types';

const DEFAULT_VIEW: MapViewState = {
  longitude: 36.82,
  latitude: -1.28,
  zoom: 12,
  pitch: 0,
  bearing: 0,
};

export function useMapState(initial?: Partial<MapViewState>) {
  const [viewState, setViewState] = useState<MapViewState>({
    ...DEFAULT_VIEW,
    ...initial,
  });

  return { viewState, setViewState };
}
