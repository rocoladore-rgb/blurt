/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        background: '#000000',
        foreground: '#F5F5F7',
        primary: '#6E56CF',
        'primary-dark': '#5B45B0',
        card: '#111111',
        'card-elevated': '#161616',
        surface: '#0A0A0A',
        'muted-text': '#A1A1A6',
        'tertiary-text': '#6E6E73',
        border: 'rgba(255,255,255,0.08)',
        'accent-purple': '#8B5CF6',
        'accent-purple-light': '#A78BFA',
      },
      fontFamily: {
        sans: ['-apple-system', 'BlinkMacSystemFont', 'SF Pro Display', 'SF Pro Text', 'Helvetica Neue', 'sans-serif'],
      },
      borderRadius: {
        pill: '100px',
      },
      animation: {
        'wave-1': 'wave 1.4s ease-in-out infinite',
        'wave-2': 'wave 1.4s ease-in-out infinite 0.1s',
        'wave-3': 'wave 1.4s ease-in-out infinite 0.2s',
        'wave-4': 'wave 1.4s ease-in-out infinite 0.05s',
        'wave-5': 'wave 1.4s ease-in-out infinite 0.15s',
        'wave-6': 'wave 1.4s ease-in-out infinite 0.25s',
        'wave-7': 'wave 1.4s ease-in-out infinite 0.3s',
        'fade-up': 'fadeUp 0.6s ease-out forwards',
        'fade-in': 'fadeIn 0.5s ease-out forwards',
        'shimmer': 'shimmer 2.5s linear infinite',
        'float': 'float 4s ease-in-out infinite',
      },
      keyframes: {
        wave: {
          '0%, 100%': { transform: 'scaleY(0.3)' },
          '50%':       { transform: 'scaleY(1)' },
        },
        fadeUp: {
          from: { opacity: '0', transform: 'translateY(20px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
        fadeIn: {
          from: { opacity: '0' },
          to:   { opacity: '1' },
        },
        shimmer: {
          '0%':   { backgroundPosition: '-200% center' },
          '100%': { backgroundPosition: '200% center' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0px)' },
          '50%':      { transform: 'translateY(-8px)' },
        },
      },
    },
  },
  plugins: [],
}
