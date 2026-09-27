import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';

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

  /// Uploads an image using its MD5 hash as a filename to prevent duplicates.
  Future<String?> uploadImageWithHash(Uint8List bytes, String extension, String folder) async {
    try {
      // 1. Generate MD5 Hash of image content
      final hash = md5.convert(bytes).toString();
      final fileName = '$hash.$extension';
      final String path = '$folder/$fileName';

      // 2. Upload to Supabase (upsert: true will overwrite if exists, which is fine for identical content)
      await _client.storage.from(bucketName).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // 3. Return the public URL
      return _client.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      print('Error uploading with hash to Supabase: $e');
      return null;
    }
  }

  /// Deletes an image from storage using its public URL.
  Future<void> deleteImageByUrl(String url) async {
    try {
      if (url.isEmpty || !url.contains(bucketName)) return;

      final Uri uri = Uri.parse(url);
      final List<String> segments = uri.pathSegments;
      
      // Extract path after bucket name
      final int bucketIndex = segments.indexOf(bucketName);
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        final String path = segments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(bucketName).remove([path]);
      }
    } catch (e) {
      print('Error deleting from Supabase: $e');
    }
  }

  /// Lists all files in a specific storage folder.
  Future<List<String>> listImages(String folder) async {
    try {
      final List<FileObject> files = await _client.storage.from(bucketName).list(path: folder);
      
      return files
          .where((f) => f.name != '.emptyFolderPlaceholder')
          .map((f) => _client.storage.from(bucketName).getPublicUrl('$folder/${f.name}'))
          .toList();
    } catch (e) {
      print('Error listing images from Supabase: $e');
      return [];
    }
  }

  /// Deletes all files in a specific folder. Use with caution.
  Future<void> deleteAllFilesInFolder(String folder) async {
    try {
      final List<FileObject> files = await _client.storage.from(bucketName).list(path: folder);
      if (files.isNotEmpty) {
        final List<String> paths = files
            .where((f) => f.name != '.emptyFolderPlaceholder')
            .map((f) => '$folder/${f.name}')
            .toList();
        if (paths.isNotEmpty) {
          await _client.storage.from(bucketName).remove(paths);
        }
      }
    } catch (e) {
      print('Error deleting files in folder $folder: $e');
    }
  }

  /// Deletes all files in specific folders.
  Future<void> deleteAllStorageFiles() async {
    await deleteAllFilesInFolder('products');
    await deleteAllFilesInFolder('offers');
    await deleteAllFilesInFolder('categories');
  }
}
