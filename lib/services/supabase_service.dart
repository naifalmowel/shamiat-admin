import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as p;

class SupabaseService {
  static const String supabaseUrl = 'https://gosqrnkrebpdqvhazugw.supabase.co';
  static const String supabaseKey = 'sb_publishable_N0iUuNR5DD-yKtgCqcXglg_K2ySU9pj';
  static const String bucketName = 'menu-images';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseKey,
      debug: false,
    );
  }

  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> uploadImage(File file, String folder) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(file.path)}';
      final String path = '$folder/$fileName';

      await _client.storage.from(bucketName).upload(path, file);

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
