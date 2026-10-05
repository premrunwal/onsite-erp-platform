export const CONFIG = {
  PORT: process.env.PORT || 4000,
  JWT_SECRET: process.env.JWT_SECRET || 'onsite_erp_super_secret_jwt_key_2026',
  JWT_EXPIRES_IN_SEC: 30 * 24 * 60 * 60, // 30 days in seconds
  GEOFENCE_DEFAULT_RADIUS_METERS: 200,

  // SUPABASE POSTGRES DB
  DATABASE_URL: process.env.DATABASE_URL || 'postgresql://postgres:[YOUR-PASSWORD]@db.nzaonateglqqgwyrwxln.supabase.co:5432/postgres',

  // CLOUDINARY MEDIA STORAGE
  CLOUDINARY: {
    CLOUD_NAME: process.env.CLOUDINARY_CLOUD_NAME || 'qn6ddgzo',
    API_KEY: process.env.CLOUDINARY_API_KEY || '797582845523724',
    API_SECRET: process.env.CLOUDINARY_API_SECRET || '6yRZNNXi_pG8oknm0FeuoBZB6A8',
  },

  SUPPORTED_COUNTRIES: [
    { code: 'IN', prefix: '+91', name: 'India', currency: 'INR', symbol: '₹' },
    { code: 'AE', prefix: '+971', name: 'United Arab Emirates', currency: 'AED', symbol: 'AED' },
    { code: 'SA', prefix: '+966', name: 'Saudi Arabia', currency: 'SAR', symbol: 'SAR' },
    { code: 'NP', prefix: '+977', name: 'Nepal', currency: 'NPR', symbol: 'NRs' },
  ],
};
