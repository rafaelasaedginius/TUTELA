import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Lapisan penghubung antara UI autentikasi dan Firebase Authentication.
///
/// Screen tidak memanggil Firebase secara langsung. Semua operasi login,
/// register, logout, dan password ditempatkan di service ini agar logic dapat
/// dipakai ulang dan UI tetap mudah dibaca.
class AuthService {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;

  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  fb.User? get currentUser => _auth.currentUser;

  Future<fb.User> register({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<fb.User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordReset(String email) async {
    // Firebase yang membuat token reset dan mengirim email. Aplikasi tidak
    // pernah mengetahui password lama atau membuat reset link sendiri.
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('No authenticated user.');
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount({required String currentPassword}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) throw Exception('No authenticated user.');
    final credential = fb.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.delete();
  }
}
