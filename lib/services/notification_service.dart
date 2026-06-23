import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../screens/incident_detail_screen.dart';
import '../theme/tutela_colors.dart';
import 'incident_service.dart';

/// Menampilkan local notification berdasarkan perubahan Firestore.
///
/// Solusi ini gratis dan tidak memakai FCM atau Cloud Functions. Listener hanya
/// aktif selama proses aplikasi masih berjalan, sehingga notification tidak
/// dijamin muncul jika aplikasi sudah ditutup sepenuhnya oleh sistem.
class NotificationService {
  NotificationService._();

  static const channelKey = 'incident_activity';
  static final navigatorKey = GlobalKey<NavigatorState>();

  static StreamSubscription<fb.User?>? _authSubscription;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _incidentSubscription;
  static StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _commentSubscription;

  static final Map<String, Set<String>> _knownVerifiedBy = {};
  static final Set<String> _ownedIncidentIds = {};
  static bool _incidentSnapshotReady = false;
  static bool _commentSnapshotReady = false;
  static String? _pendingIncidentId;

  static Future<void> initialize() async {
    // Channel mengelompokkan notification Android dan menentukan suara,
    // vibration, warna, serta tingkat kepentingannya.
    await AwesomeNotifications().initialize(null, [
      NotificationChannel(
        channelKey: channelKey,
        channelName: 'Incident activity',
        channelDescription:
            'Notifications when your incident is verified or commented on.',
        defaultColor: TutelaColors.plum,
        ledColor: TutelaColors.rose,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
    ]);

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );

    // Jika app dibuka lewat notification lama, incidentId disimpan sementara
    // sampai Navigator pada MaterialApp sudah siap digunakan.
    final initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    final initialIncidentId = initialAction?.payload?['incidentId'];
    if (initialIncidentId != null && initialIncidentId.isNotEmpty) {
      _pendingIncidentId = initialIncidentId;
    }

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    _listenToSignedInUser();
  }

  static void _listenToSignedInUser() {
    // Listener Firestore hanya aktif untuk user yang sedang login. Saat akun
    // berubah/logout, listener lama dihentikan agar data akun tidak tercampur.
    _authSubscription?.cancel();
    _authSubscription = fb.FirebaseAuth.instance.authStateChanges().listen((
      user,
    ) {
      _stopFirestoreListeners();
      if (user != null) _startFirestoreListeners(user.uid);
    });
  }

  static void _startFirestoreListeners(String uid) {
    // READ incident milik user untuk mendeteksi verification baru.
    _incidentSubscription = FirebaseFirestore.instance
        .collection('incidents')
        .where('reporterId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final data = change.doc.data();
            if (data == null) continue;

            final incidentId = change.doc.id;
            final currentVerifiedBy =
                (data['verifiedBy'] as List<dynamic>? ?? [])
                    .cast<String>()
                    .toSet();
            final previousVerifiedBy = _knownVerifiedBy[incidentId] ?? {};

            // difference() menghasilkan UID yang baru masuk ke verifiedBy.
            // Snapshot pertama diabaikan agar verification lama tidak dianggap
            // sebagai notification baru ketika aplikasi baru dibuka.
            if (_incidentSnapshotReady &&
                change.type == DocumentChangeType.modified) {
              final newVerifierIds = currentVerifiedBy.difference(
                previousVerifiedBy,
              )..remove(uid);

              if (newVerifierIds.isNotEmpty) {
                _showNotification(
                  title: 'Incident verified',
                  body:
                      'Someone verified "${data['title'] ?? 'your incident report'}".',
                  incidentId: incidentId,
                );
              }
            }

            _knownVerifiedBy[incidentId] = currentVerifiedBy;
          }

          _ownedIncidentIds
            ..clear()
            ..addAll(snapshot.docs.map((doc) => doc.id));
          _incidentSnapshotReady = true;
        });

    // READ comment baru dan tampilkan notif jika incident adalah milik user.
    _commentSubscription = FirebaseFirestore.instance
        .collection('comments')
        .snapshots()
        .listen((snapshot) {
          if (_commentSnapshotReady) {
            for (final change in snapshot.docChanges) {
              if (change.type != DocumentChangeType.added) continue;

              final data = change.doc.data();
              if (data == null) continue;
              final incidentId = data['incidentId'] as String? ?? '';
              final authorId = data['authorId'] as String? ?? '';

              if (!_ownedIncidentIds.contains(incidentId) || authorId == uid) {
                // Hanya komentar orang lain pada incident milik user yang
                // menghasilkan notification.
                continue;
              }

              final authorName = data['authorName'] as String? ?? 'Someone';
              _showNotification(
                title: 'New incident comment',
                body: '$authorName commented on your incident.',
                incidentId: incidentId,
              );
            }
          }

          _commentSnapshotReady = true;
        });
  }

  static void _stopFirestoreListeners() {
    _incidentSubscription?.cancel();
    _commentSubscription?.cancel();
    _incidentSubscription = null;
    _commentSubscription = null;
    _knownVerifiedBy.clear();
    _ownedIncidentIds.clear();
    _incidentSnapshotReady = false;
    _commentSnapshotReady = false;
  }

  static Future<void> _showNotification({
    required String title,
    required String body,
    required String incidentId,
  }) async {
    // Awesome Notifications membuat local notification di perangkat. Payload
    // menyimpan incidentId agar notification dapat membuka detail yang benar.
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.abs() % 2147483647,
        channelKey: channelKey,
        title: title,
        body: body,
        category: NotificationCategory.Social,
        payload: {'incidentId': incidentId},
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(ReceivedAction action) async {
    final incidentId = action.payload?['incidentId'];
    if (incidentId == null || incidentId.isEmpty) return;
    await openIncident(incidentId);
  }

  static Future<void> openIncident(String incidentId) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingIncidentId = incidentId;
      return;
    }

    // Ambil data incident terbaru dari Firestore sebelum membuka detail.
    final incident = await IncidentService().getIncident(incidentId);
    if (incident == null) return;

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (context) => IncidentDetailScreen(incident: incident),
      ),
    );
  }

  static Future<void> openPendingIncidentIfNeeded() async {
    final incidentId = _pendingIncidentId;
    if (incidentId == null) return;
    _pendingIncidentId = null;
    await openIncident(incidentId);
  }
}
