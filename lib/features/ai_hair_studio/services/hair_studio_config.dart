/// Address of an approved HTTPS proxy for Perfect Corp AI Hairstyle try-on.
///
/// The Flutter app never contains a provider key, template ID, or customer
/// photo log. Set only the proxy address:
/// `flutter run --dart-define=HAIR_STUDIO_ENDPOINT=https://host/v1/hair`
///
/// The address must be HTTPS, without a username, password, or query string.
/// This app does not call Perfect Corp, deploy the proxy, or purchase credits.
///
/// Perfect Corp AI Hairstyle Generator, as documented at
/// https://docs.perfectcorp.com/reference/ai_hairstyle/section/overview/integration-guide
///
/// The proxy, not this app, must:
/// - Keep the Bearer API key from the YouCam API console.
/// - Accept `POST` `multipart/form-data` from this app.
/// - File `photo`: the customer JPEG, long side at most 1024 px, under 10 MB.
/// - File `reference`: the bundled example JPEG for `styleId`, named
///   `{styleId}.jpg`. Upload it as the custom `ref_file`. Do not invent a
///   `template_id`. A real template list may be used only after it is fetched
///   with the server key.
/// - Fields `provider` (`perfect-corp-hair-transfer`), `styleId`, `styleName`,
///   `colorId`, and `colorName`. Colour is a customer preference. The hair
///   transfer API does not document a colour or text-prompt field, so the
///   proxy must not invent one.
/// - Upload both files with `POST /s2s/v2.0/file`, then `PUT` the returned
///   URL, then `POST /s2s/v2.1/task/hair-transfer`, then poll
///   `GET /s2s/v2.1/task/hair-transfer/{task_id}`.
/// - On `task_status` success, download `results.url` and return those image
///   bytes. If they match the customer photo or the example photo, do not
///   return them as success.
/// - Forward provider codes such as `error_no_shoulder`,
///   `error_large_face_angle`, `error_face_pose`,
///   `error_insufficient_landmarks`, and `error_hair_too_short`.
/// - V2.1 uses 2 units for a preset task and 2 units for a custom task.
/// - Avoid logging image bytes, the API key, or the result URL.
///
/// This app waits about two minutes, then shows a retry. The guide does not
/// publish a maximum task duration. Success for this app is HTTP 200 with
/// JPEG, PNG, or WebP bytes that are not the submitted photo or the example.
class HairStudioConfig {
  const HairStudioConfig._();

  static const endpoint = String.fromEnvironment('HAIR_STUDIO_ENDPOINT');

  static bool isAcceptableEndpoint(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      return false;
    }
    if (uri.userInfo.isNotEmpty || uri.query.isNotEmpty) {
      return false;
    }
    return true;
  }
}
