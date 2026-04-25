import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../main.dart';

final noticesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await supabase
      .from('notices')
      .select('*')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(response);
});

final noticeActionProvider = Provider((ref) => NoticeService(ref));

class NoticeService {
  final ProviderRef ref;
  NoticeService(this.ref);

  Future<void> addNotice({
    required String title,
    required String content,
    String priority = 'normal',
  }) async {
    await supabase.from('notices').insert({
      'title': title,
      'content': content,
      'priority': priority,
      'created_by': supabase.auth.currentUser?.id,
    });
    ref.invalidate(noticesProvider);
  }

  Future<void> deleteNotice(String id) async {
    await supabase.from('notices').delete().eq('id', id);
    ref.invalidate(noticesProvider);
  }
}
