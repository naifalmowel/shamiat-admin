import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://gosqrnkrebpdqvhazugw.supabase.co';
  static const String supabaseKey = 'sb_publishable_N0iUuNR5DD-yKtgCqcXglg_K2ySU9pj';
  static const String bucketName = 'projects';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
      debug: false,
    );
  }

  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadImageBytes(Uint8List bytes, String fileName, String folder) async {
    try {
      final String path = '$folder/$fileName';

      await _client.storage.from(bucketName).uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      final String publicUrl = _client.storage.from(bucketName).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading to Supabase: $e');
      return null;
    }
  }

  Future<void> deleteImage(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      final List<String> segments = uri.pathSegments;
      // path typically looks like: /storage/v1/object/public/menu-images/folder/file.jpg
      // We need everything after 'menu-images/'
      final int bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final String path = segments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      print('Error deleting from Supabase: $e');
    }
  }
}
