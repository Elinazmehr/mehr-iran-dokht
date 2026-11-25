import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'ca.elnazmoghadam.mehrirandokht',
  appName: 'مهر ایران دخت',
  webDir: 'www',
  backgroundColor: '#0a152c',
  ios: {
    // Keep all navigation inside the app: external links (Google Maps,
    // mailto, .ics downloads) are opened by the small JS bridge in the web
    // app via @capacitor/browser / @capacitor/share, never inside the WebView.
    // This is what Apple wants: the app must not behave like a generic browser.
    limitsNavigationsToAppBoundDomains: true,
    contentInset: 'always',
  },
  server: {
    // Version 1.1+: the app loads its content LIVE from the website, so
    // every site update appears in the app with no new build and no
    // Apple review. The bundled www/ is only a minimal offline fallback
    // page. HTTPS only — no cleartext.
    url: 'https://www.mehrirandokht.com',
    iosScheme: 'capacitor',
  },
  // Note: no SplashScreen plugin is installed — the launch screen is the
  // native LaunchScreen.storyboard (royal blue + centred app icon).
};

export default config;
