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
    // Local web content is served from the app bundle; no remote server.
    // Google Fonts still load from the CDN when online and fall back
    // gracefully to system fonts when offline.
    iosScheme: 'capacitor',
  },
  // Note: no SplashScreen plugin is installed — the launch screen is the
  // native LaunchScreen.storyboard (royal blue + centred app icon).
};

export default config;
