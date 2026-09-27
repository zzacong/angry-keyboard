// @ts-check
import stylex from "@stylexjs/unplugin";
import { defineConfig } from "astro/config";

// https://astro.build/config
export default defineConfig({
  // Canonical and social URLs are built from this, so it must match production.
  site: "https://angry-keyboard.zzacong.com",
  vite: {
    plugins: [
      // StyleX compiles to atomic CSS at build time. `runtimeInjection` stays
      // off so no style-injecting runtime reaches the browser.
      stylex.vite({
        dev: process.env.NODE_ENV === "development",
        useCSSLayers: true,
        runtimeInjection: false,
      }),
    ],
  },
});
