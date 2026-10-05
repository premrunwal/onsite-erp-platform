export interface WatermarkData {
  projectCode: string;
  siteName: string;
  latitude: number;
  longitude: number;
  timestampUtc: string;
  verificationTag: string;
}

export function generateWatermarkStampText(data: WatermarkData): string {
  const latStr = `${Math.abs(data.latitude).toFixed(4)}° ${data.latitude >= 0 ? 'N' : 'S'}`;
  const lngStr = `${Math.abs(data.longitude).toFixed(4)}° ${data.longitude >= 0 ? 'E' : 'W'}`;
  return `[${data.projectCode}] - ${data.siteName} | LAT: ${latStr}, LON: ${lngStr} | ${data.timestampUtc} | ${data.verificationTag}`;
}
