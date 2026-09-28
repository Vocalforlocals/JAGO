/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        mota: {
          50: '#f0fdf4',
          100: '#dcfce7',
          500: '#16a34a',
          600: '#15803d',
          700: '#166534',
          800: '#14532d',
          900: '#052e16',
        },
        tribal: {
          saffron: '#FF671F',
          navy: '#06038D',
          green: '#046A38',
          earth: '#8B4513'
        }
      }
    },
  },
  plugins: [],
}
