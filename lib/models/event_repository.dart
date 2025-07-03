import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tunetrail/models/event.dart';

class EventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Event>> fetchAllEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('name', ascending: true) 
          .limit(10);
      return (response as List).map((e) => Event.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar eventos: $e');
    }
  }
}