import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

final userProvider = StreamProvider.autoDispose<User?>((ref) async* {
  final authStream = FirebaseAuth.instance.authStateChanges();
  final idTokenStream = FirebaseAuth.instance.idTokenChanges();
  final userStream = FirebaseAuth.instance.userChanges();

  await for (final user in Rx.merge([authStream, idTokenStream, userStream])) {
    yield user;
  }
});
