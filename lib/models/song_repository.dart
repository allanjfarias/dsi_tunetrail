import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/song.dart';

class SongRepository {
  final SupabaseClient supabase;

  SongRepository({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<List<Song>> searchSongs(String query) async {
    try{
      final String trimmedQuery = query.trim();
      if (query.trim().isEmpty) {
        return <Song>[];
      }
      final String filter = 'track_name.ilike.%$trimmedQuery%,artists.ilike.%$trimmedQuery%';
      final List<Map<String, dynamic>> response = await supabase
        .from('songs')
        .select('*, covers(image_url)')
        .or(filter)
        .limit(20);
      return response.map(Song.fromJson).toList();
    } catch (e) {
      debugPrint('Erro em searchSongs: $e');
      rethrow;
    }
  }

  Future<List<Song>> fetchPopularSongs() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
          .from('songs')
          .select('*, covers(image_url)')
          .order('popularity', ascending: false)
          .limit(10);
      return response.map(Song.fromJson).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> fetchTrendingArtists() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
        .from('songs')
        .select('artists')
        .order('popularity', ascending: false)
        .limit(50);
      final Set<String> uniqueArtists = <String>{};
      for (final Map<String, dynamic> song in response) {
        final String artistsString = song['artists'] as String;
        final List<String> artistsList = artistsString.split(';');
        for (final String artist in artistsList) {
          if (artist.trim().isNotEmpty) {
            uniqueArtists.add(artist.trim());
          }
        }
      }
      return uniqueArtists.toList();
    } catch (e) {
      debugPrint('Erro em fetchTrendingArtists: $e');
      rethrow;
    }
  }
}