import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class B2Service {
  // NOTE: For production, do NOT store keys here. Use a Supabase Edge Function to sign upload URLs.
  // This is a direct implementation for demonstration/migration purposes.
  final String keyId;
  final String applicationKey;
  final String bucketId;

  String? _authorizationToken;
  String? _apiUrl;
  String? _downloadUrl;

  B2Service({
    required this.keyId,
    required this.applicationKey,
    required this.bucketId,
  });

  Future<void> authorize() async {
    final authString = base64Encode(utf8.encode('$keyId:$applicationKey'));
    final response = await http.get(
      Uri.parse('https://api.backblazeb2.com/b2api/v2/b2_authorize_account'),
      headers: {'Authorization': 'Basic $authString'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authorizationToken = data['authorizationToken'];
      _apiUrl = data['apiUrl'];
      _downloadUrl = data['downloadUrl'];
    } else {
      throw Exception('Failed to authorize B2: ${response.body}');
    }
  }

  Future<String> uploadFile(Uint8List fileData, String fileName) async {
    if (_authorizationToken == null) await authorize();

    // 1. Get Upload URL
    final uploadUrlResponse = await http.post(
      Uri.parse('$_apiUrl/b2api/v2/b2_get_upload_url'),
      headers: {'Authorization': _authorizationToken!},
      body: jsonEncode({'bucketId': bucketId}),
    );

    if (uploadUrlResponse.statusCode != 200) {
      throw Exception('Failed to get upload URL: ${uploadUrlResponse.body}');
    }

    final uploadData = jsonDecode(uploadUrlResponse.body);
    final uploadUrl = uploadData['uploadUrl'];
    final uploadAuthToken = uploadData['authorizationToken'];

    // 2. Upload File
    final sha1Checksum = sha1.convert(fileData).toString();
    
    final uploadResponse = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': uploadAuthToken,
        'X-Bz-File-Name': Uri.encodeComponent(fileName),
        'Content-Type': 'b2/x-auto',
        'X-Bz-Content-Sha1': sha1Checksum,
      },
      body: fileData,
    );

    if (uploadResponse.statusCode == 200) {
      final fileInfo = jsonDecode(uploadResponse.body);
      // Return the friendly URL
      return '$_downloadUrl/file/${fileInfo['bucketId']}/$fileName'; 
      // Note: check actual download URL format construction based on B2 docs (usually bucket name or file path)
    } else {
      throw Exception('Failed to upload file: ${uploadResponse.body}');
    }
  }
}
