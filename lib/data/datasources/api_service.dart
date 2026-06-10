import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class ApiService {
  Map<String, String> _authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Treks ──────────────────────────────────────────────────────────────────

  Future<List<dynamic>> getTreks({
    String? region,
    String? duration,
    String? difficulty,
  }) async {
    final query = {
      if (region != null && region != 'All Treks') 'region': region,
      if (duration != null && duration != 'Duration') 'duration': duration,
      if (difficulty != null && difficulty != 'Difficulty')
        'difficulty': difficulty,
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}/treks')
        .replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load treks');
  }

  Future<Map<String, dynamic>> getTrekById(String id) async {
    final response =
        await http.get(Uri.parse('${ApiConstants.baseUrl}/treks/$id'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load trek details');
  }

  // ── Comments ───────────────────────────────────────────────────────────────

  Future<List<dynamic>> getComments(String trekId) async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/treks/$trekId/comments'));
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load comments');
  }

  Future<void> addComment(
    String trekId,
    String userName,
    String message, {
    String? imagePath,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/treks/$trekId/comments');

    // Multipart so we can optionally attach a photo.
    final request = http.MultipartRequest('POST', uri)
      ..fields['userName'] = userName
      ..fields['message'] = message;

    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final streamed = await request.send();
    if (streamed.statusCode != 201) {
      throw Exception('Failed to add comment');
    }
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> signup(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final body = jsonDecode(response.body);
    if (response.statusCode == 201) return body;
    throw Exception(body['message'] ?? 'Signup failed');
  }

  // ── Saved Routes (protected) ───────────────────────────────────────────────

  Future<List<dynamic>> getSavedRoutes(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/saved'),
      headers: _authHeaders(token),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load saved routes');
  }

  Future<void> saveRoute(String trekId, String token) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/saved/$trekId'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save route');
    }
  }

  Future<void> removeSavedRoute(String trekId, String token) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/saved/$trekId'),
      headers: _authHeaders(token),
    );
    if (response.statusCode != 200) throw Exception('Failed to remove route');
  }
}
