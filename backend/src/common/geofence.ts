/**
  Haversine formula to compute distance in meters between two GPS coordinates
 */
export function calculateHaversineDistanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number
): number {
  const EARTH_RADIUS_METERS = 6371000;
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);

  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);

  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(EARTH_RADIUS_METERS * c * 100) / 100;
}

function toRadians(degrees: number): number {
  return (degrees * Math.PI) / 180;
}

export function isWithinGeofence(
  punchLat: number,
  punchLng: number,
  siteLat: number,
  siteLng: number,
  radiusMeters: number = 200
): { isValid: boolean; distanceMeters: number } {
  const distanceMeters = calculateHaversineDistanceMeters(
    punchLat,
    punchLng,
    siteLat,
    siteLng
  );
  return {
    isValid: distanceMeters <= radiusMeters,
    distanceMeters,
  };
}
