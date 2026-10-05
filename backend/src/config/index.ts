export const CONFIG = {
  PORT: process.env.PORT || 4000,
  JWT_SECRET: process.env.JWT_SECRET || 'onsite_erp_super_secret_jwt_key_2026',
  JWT_EXPIRES_IN_SEC: 30 * 24 * 60 * 60, // 30 days in seconds
  GEOFENCE_DEFAULT_RADIUS_METERS: 200,
  SUPPORTED_COUNTRIES: [
    { code: 'IN', prefix: '+91', name: 'India', currency: 'INR', symbol: '₹' },
    { code: 'AE', prefix: '+971', name: 'United Arab Emirates', currency: 'AED', symbol: 'AED' },
    { code: 'SA', prefix: '+966', name: 'Saudi Arabia', currency: 'SAR', symbol: 'SAR' },
    { code: 'NP', prefix: '+977', name: 'Nepal', currency: 'NPR', symbol: 'NRs' },
  ],
};
