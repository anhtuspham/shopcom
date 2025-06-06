import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dialogFlowtterProvider = FutureProvider<DialogFlowtter>((ref) async {
  return await DialogFlowtter.fromFile(
    path: 'assets/shopcom-chatbot-63b55d619964.json',
    sessionId: 'shopcom-session-${DateTime.now().millisecondsSinceEpoch}',
  );
});