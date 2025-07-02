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

  Future<List<String>> fetchUniqueGenres() async {
    try {
      final List<Map<String, dynamic>> response = await supabase
        .from('songs')
        .select('track_genre');
      final Set<String> uniqueGenres = <String>{};
      for (final Map<String, dynamic> song in response) {
        final String genre = song['track_genre'] as String;
        if (genre.isNotEmpty) {
          uniqueGenres.add(genre);
        }
      }
      final List<String> sortedGenres = uniqueGenres.toList()..sort();
      return sortedGenres;
    } catch (e) {
      debugPrint('Erro em fetchUniqueGenres: $e');
      rethrow;
    }
  }

  Future<List<Song>> fetchSongsByGenre(String genre) async {
    try {
      final List<Map<String, dynamic>> response = await supabase
        .from('songs')
        .select('*, covers(image_url)')
        .eq('track_genre', genre)
        .order('popularity', ascending: false)
        .limit(100);
      return response.map(Song.fromJson).toList();
    } catch (e) {
      debugPrint('Erro em fetchSongsByGenre: $e');
      rethrow;
    }
  }
}