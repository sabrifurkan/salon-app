/// Stub implementation for non-web platforms.
/// On mobile, you could use share_plus or path_provider here.
void downloadCsv(String csvContent, String fileName) {
  // No-op for non-web. Extend for mobile if needed.
  throw UnsupportedError('CSV download is only supported on web for now.');
}
