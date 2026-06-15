import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/config/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/lib/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  darkMode: ["class"],
  theme: {
    extend: {
      backgroundImage: {
        "radial-glow": "radial-gradient(circle at top, rgba(56,189,248,0.20), transparent 45%)",
      },
      boxShadow: {
        neon: "0 0 20px rgba(56,189,248,0.35), 0 0 50px rgba(168,85,247,0.18)",
      },
      colors: {
        neon: {
          cyan: "#22D3EE",
          pink: "#F472B6",
          violet: "#A855F7",
          blue: "#38BDF8",
          lime: "#A3E635",
        },
      },
      keyframes: {
        shimmer: {
          "0%": { backgroundPosition: "-200% 0" },
          "100%": { backgroundPosition: "200% 0" },
        },
      },
      animation: {
        shimmer: "shimmer 2.4s linear infinite",
      },
    },
  },
  plugins: [],
};

export default config;
