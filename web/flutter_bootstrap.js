{{flutter_js}}
{{flutter_build_config}}

// Keep fallback glyph loading local in the packaged demo.
_flutter.loader.load({
  config: { fontFallbackBaseUrl: 'assets/font-fallback/' }
});
