import 'package:supabase_flutter/supabase_flutter.dart';

class CrudRepository<T> {
  final String table;
  final String primaryKey;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final SupabaseClient supabase;

  CrudRepository({
    required this.table,
    required this.fromJson,
    required this.toJson,
    this.primaryKey = 'id',
    SupabaseClient? supabaseClient,
  }) : supabase = supabaseClient ?? Supabase.instance.client;

  Future<T> create(T item) async {
    try {
      final Map<String, dynamic> result =
          await supabase.from(table).insert(toJson(item)).select().single();
      return fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<T>> readAll() async {
    try {
      final List<Map<String, dynamic>> result =
          await supabase.from(table).select();
      return (result as List<dynamic>)
          .map((dynamic e) => fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<T?> readOne(String id) async {
    try {
      final Map<String, dynamic> result =
          await supabase.from(table).select().eq(primaryKey, id).single();
      return fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<T> update(String id, T item) async {
    try {
      final Map<String, dynamic> result =
          await supabase
              .from(table)
              .update(toJson(item))
              .eq(primaryKey, id)
              .select()
              .single();
      return fromJson(result);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String id) async {
    try {
      await supabase.from(table).delete().eq(primaryKey, id);
    } catch (e) {
      rethrow;
    }
  }
}
