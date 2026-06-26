class ApiConstants {
  // Android emulator: http://10.0.2.2:5000 (10.0.2.2 = your laptop's localhost).
  // Physical phone: replace with your laptop's IP address.
  static const serverUrl = 'http://10.0.2.2:5000';
  static const baseUrl = '$serverUrl/api';

  /// Resolves an image path coming from the backend so it loads on the device.
  /// - Rewrites localhost/127.0.0.1 (older uploads) to the device-reachable host.
  /// - Prefixes relative paths like "/uploads/x.jpg" with the server host.
  /// - Leaves real external URLs (e.g. https://images.unsplash.com/...) untouched.
  static String imageUrl(String path) {
    if (path.isEmpty) return '';
    var p = path
        .replaceFirst('http://localhost:5000', serverUrl)
        .replaceFirst('http://127.0.0.1:5000', serverUrl);
    if (p.startsWith('http')) return p;
    return '$serverUrl$p';
  }
}
