import twTypography from "@tailwindcss/typography";
import daisyui from "daisyui";

/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{vue,svelte,js,ts,jsx,tsx,elm}"],
  theme: {
    extend: {},
  },
  plugins: [daisyui, twTypography],
  daisyui: {
    themes: ["dracula", "dark", "light"],
  },
};

