import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:gal/gal.dart';
import 'package:tutela/models/user_model.dart' as tutela_user;
import '../models/comment_model.dart';
import '../models/incident_model.dart';
import '../models/incident_enums.dart';
import '../models/attachment_model.dart';
import '../services/comment_service.dart';
import '../services/incident_service.dart';
import '../services/user_service.dart';
import '../theme/tutela_colors.dart';

class IncidentDetailScreen extends StatefulWidget {
  const IncidentDetailScreen({
    super.key,
    required this.incident,
  });

  final Incident incident;

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  late Incident incident;
  final CommentService _commentService = CommentService();
  final IncidentService _incidentService = IncidentService();
  final UserService _userService = UserService();
  final TextEditingController _commentController = TextEditingController();
  static const int _commentMaxLength = 300;

  bool _isPostingComment = false;
  bool _isVerifying = false;
  bool _isUpdatingStatus = false;
  String? _editingCommentId;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    incident = widget.incident;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<tutela_user.User?> _fetchUser(String uid) async {
    if (uid.isEmpty) return null;
    return _userService.getUser(uid);
  }

  Future<void> _toggleVerify() async {
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to verify.')),
      );
      return;
    }
    setState(() => _isVerifying = true);
    try {
      await _incidentService.toggleVerify(incident.id, user.uid);
      final alreadyVerified = incident.verifiedBy.contains(user.uid);
      setState(() {
        final newVerifiedBy = List<String>.from(incident.verifiedBy);
        if (alreadyVerified) {
          newVerifiedBy.remove(user.uid);
        } else {
          newVerifiedBy.add(user.uid);
        }
        incident = Incident(
          id: incident.id,
          reporterId: incident.reporterId,
          title: incident.title,
          description: incident.description,
          category: incident.category,
          severity: incident.severity,
          location: incident.location,
          geohash: incident.geohash,
          attachments: incident.attachments,
          occurredAt: incident.occurredAt,
          verifiedCount: alreadyVerified
              ? (incident.verifiedCount > 0 ? incident.verifiedCount - 1 : 0)
              : incident.verifiedCount + 1,
          verifiedBy: newVerifiedBy,
          status: incident.status,
          createdAt: incident.createdAt,
          updatedAt: incident.updatedAt,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update verification.')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _markAsResolved() async {
    setState(() => _isUpdatingStatus = true);
    try {
      await _incidentService.resolveIncident(incident.id);
      setState(() {
        incident = Incident(
          id: incident.id,
          reporterId: incident.reporterId,
          title: incident.title,
          description: incident.description,
          category: incident.category,
          severity: incident.severity,
          location: incident.location,
          geohash: incident.geohash,
          attachments: incident.attachments,
          occurredAt: incident.occurredAt,
          verifiedCount: incident.verifiedCount,
          verifiedBy: incident.verifiedBy,
          status: IncidentStatus.resolved,
          createdAt: incident.createdAt,
          updatedAt: incident.updatedAt,
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update status.')),
      );
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _postComment() async {
    final body = _commentController.text.trim();
    if (body.isEmpty) return;
    if (body.length > _commentMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comments are limited to $_commentMaxLength characters.')),);
      return;
    }
    final user = fb.FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to comment.')),);
      return;
    }

    setState(() => _isPostingComment = true);
    try {
      final profile = await _fetchUser(user.uid);
      final authorName = profile?.username.isNotEmpty == true
          ? profile!.username
          : (user.displayName ?? 'Anonymous');
      await _commentService.createComment(
        body: body,
        authorId: user.uid,
        authorName: authorName,
        authorAvatarUrl: profile?.avatar?.secureUrl,
        incidentId: incident.id,
      );
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post comment.')),);
    } finally {
      if (mounted) setState(() => _isPostingComment = false);
    }
  }

  void _startEditComment(Comment comment) {
    setState(() {
      _editingCommentId = comment.id;
      _editController.text = comment.body;
    });
  }

  void _cancelEditComment() {
    setState(() {
      _editingCommentId = null;
      _editController.clear();
    });
  }

  Future<void> _saveEditComment(String commentId) async {
    final newBody = _editController.text.trim();
    if (newBody.isEmpty) return;
    if (newBody.length > _commentMaxLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Comments are limited to $_commentMaxLength characters.')),
      );
      return;
    }
    try {
      await _commentService.updateComment(commentId: commentId, newBody: newBody);
      _cancelEditComment();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update comment.')),
      );
    }
  }

  Future<void> _deleteComment(String commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Delete comment?',
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
          ),
          content: Text(
            'This will permanently delete the comment.',
            style: GoogleFonts.dmSans(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        await _commentService.deleteComment(commentId);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 32).clamp(300.0, 430.0);

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Incident Detail Header Start
                Row(
                  children: [
                    _DetailIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incident detail',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Full report information',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.6),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Incident Detail Header End
                const SizedBox(height: 18),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Incident Summary Start
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: TutelaColors.plum,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: TutelaColors.plum.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: incident.category.color.withValues(
                                        alpha: 0.22,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      incident.category.icon,
                                      color: TutelaColors.canvas,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      incident.title,
                                      style: GoogleFonts.dmSans(
                                        color: TutelaColors.canvas,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        height: 1.15,
                                        letterSpacing: 0,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Reported near ${incident.location.address ?? "${incident.location.latitude}, ${incident.location.longitude}"}. This detail page is used to read the full report, review status, and continue update/delete actions.',
                                style: GoogleFonts.dmSans(
                                  color: TutelaColors.canvas.withValues(
                                    alpha: 0.86,
                                  ),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 1.35,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Incident Summary End
                        const SizedBox(height: 14),
                        // Detail Status Row Start
                        Row(
                          children: [
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Category',
                                value: incident.category.label,
                                icon: incident.category.icon,
                                iconColor: incident.category.color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Severity',
                                value: incident.severity.label,
                                icon: Icons.speed_rounded,
                                iconColor: incident.severity.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Status',
                                value: incident.status.label,
                                icon: incident.status.icon,
                                iconColor: incident.status.color,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Verified',
                                value: '${incident.verifiedCount}',
                                icon: Icons.verified_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _DetailActionButton(
                          label: _isVerifying
                              ? 'Updating...'
                              : (incident.verifiedBy.contains(
                              fb.FirebaseAuth.instance.currentUser?.uid)
                              ? 'Verified by you'
                              : 'Verify this report'),
                          icon: Icons.verified_rounded,
                          filled: incident.verifiedBy.contains(
                              fb.FirebaseAuth.instance.currentUser?.uid),
                          onTap: _isVerifying ? () {} : _toggleVerify,
                        ),
                        if (incident.reporterId ==
                            fb.FirebaseAuth.instance.currentUser?.uid) ...[
                          const SizedBox(height: 10),
                          _DetailActionButton(
                            label: _isUpdatingStatus
                                ? 'Updating...'
                                : (incident.status == IncidentStatus.resolved
                                ? 'Marked as resolved'
                                : 'Mark as resolved'),
                            icon: incident.status == IncidentStatus.resolved
                                ? Icons.check_circle_outline_rounded
                                : Icons.task_alt_rounded,
                            filled: incident.status == IncidentStatus.resolved,
                            onTap: _isUpdatingStatus
                                ? () {}
                                : (incident.status == IncidentStatus.resolved
                                ? () {}
                                : _markAsResolved),
                          ),
                        ],
                        // Detail Status Row End
                        const SizedBox(height: 14),
                        // Detail Description Start
                        _DetailPanel(
                          title: 'Description',
                          child: Text(
                            incident.description.isNotEmpty
                                ? incident.description
                                : 'No description provided.',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                        // Detail Description End
                        const SizedBox(height: 14),
                        // Detail Location Start
                        _DetailPanel(
                          title: 'Pinned location',
                          child: Column(
                            children: [
                              Container(
                                height: 116,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: TutelaColors.plum.withValues(
                                      alpha: 0.1,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: FlutterMap(
                                    options: MapOptions(
                                      initialCenter: LatLng(
                                        incident.location.latitude,
                                        incident.location.longitude,
                                      ),
                                      initialZoom: 15,
                                      interactionOptions: const InteractionOptions(
                                        flags: InteractiveFlag.all,
                                      ),
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName:
                                        'com.tutela.app',
                                      ),
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: LatLng(
                                              incident.location.latitude,
                                              incident.location.longitude,
                                            ),
                                            child: const Icon(
                                              Icons.location_on_rounded,
                                              color: TutelaColors.rose,
                                              size: 40,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              _DetailTextLine(
                                icon: Icons.place_outlined,
                                text: incident.location.address ?? "${incident.location.latitude}, ${incident.location.longitude}",
                              ),
                            ],
                          ),
                        ),
                        // Detail Location End
                        const SizedBox(height: 14),
                        // Detail Photos Start
                        if (incident.attachments.isNotEmpty)
                          _DetailPanel(
                            title: 'Attachments (${incident.attachments.length})',
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: incident.attachments
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Padding(
                                    padding: const EdgeInsets.only(
                                      right: 10,
                                    ),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _openAttachmentViewer(context, incident.attachments, entry.key),
                                      child: Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                          border: Border.all(
                                            color: TutelaColors.plum
                                                .withValues(alpha: 0.1),
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(18),
                                          child: entry.value.isImage
                                              ? Image.network(
                                            entry.value.secureUrl,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context,
                                                child,
                                                loadingProgress) {
                                              if (loadingProgress ==
                                                  null) {
                                                return child;
                                              }
                                              return Center(
                                                child:
                                                CircularProgressIndicator(
                                                  color: TutelaColors
                                                      .plum,
                                                  value: loadingProgress
                                                      .expectedTotalBytes !=
                                                      null
                                                      ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error,
                                                stackTrace) {
                                              return Container(
                                                color: TutelaColors
                                                    .peach
                                                    .withValues(
                                                    alpha: 0.22),
                                                child: const Icon(
                                                  Icons
                                                      .image_outlined,
                                                  color: TutelaColors
                                                      .plum,
                                                  size: 20,
                                                ),
                                              );
                                            },
                                          )
                                              : Container(
                                            color: TutelaColors.peach
                                                .withValues(
                                                alpha: 0.22),
                                            child: const Icon(
                                              Icons.description_outlined,
                                              color: TutelaColors
                                                  .plum,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    .toList(),
                              ),
                            ),
                          )
                        else
                          _DetailPanel(
                            title: 'Attachments',
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                                child: Text(
                                  'No attachments',
                                  style: GoogleFonts.dmSans(
                                    color: TutelaColors.plum
                                        .withValues(alpha: 0.5),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Detail Photos End
                        const SizedBox(height: 14),
                        // Detail Comments Start
                        _DetailPanel(
                          title: 'Comments',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              StreamBuilder<List<Comment>>(
                                stream: _commentService
                                    .watchCommentsByIncident(incident.id),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'Loading comments...',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum
                                              .withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final comments = snapshot.data ?? [];
                                  if (comments.isEmpty) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Text(
                                        'No comments yet.',
                                        style: GoogleFonts.dmSans(
                                          color: TutelaColors.plum
                                              .withValues(alpha: 0.6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }
                                  final currentUid = fb.FirebaseAuth.instance
                                      .currentUser?.uid;
                                  return Column(
                                    children: [
                                      for (var i = 0;
                                      i < comments.length;
                                      i++)
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: i == comments.length - 1
                                                ? 0
                                                : 12,
                                          ),
                                          child: _CommentItem(
                                            comment: comments[i],
                                            isOwner: comments[i].authorId ==
                                                currentUid,
                                            isEditing: _editingCommentId ==
                                                comments[i].id,
                                            editController: _editController,
                                            maxLength: _commentMaxLength,
                                            onEdit: () =>
                                                _startEditComment(comments[i]),
                                            onCancelEdit: _cancelEditComment,
                                            onSaveEdit: () =>
                                                _saveEditComment(
                                                    comments[i].id),
                                            onDelete: () => _deleteComment(
                                                comments[i].id),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _DetailTextField(
                                controller: _commentController,
                                hint: 'Add a comment (max $_commentMaxLength chars)',
                                maxLines: 3,
                                maxLength: _commentMaxLength,
                              ),
                              const SizedBox(height: 10),
                              _DetailActionButton(
                                label: _isPostingComment ? 'Posting...' : 'Post comment',
                                icon: Icons.send_rounded,
                                filled: true,
                                onTap: _isPostingComment ? () {} : _postComment,
                              ),
                            ],
                          ),
                        ),
                        // Detail Comments End
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAttachmentViewer(
      BuildContext context,
      List<Attachment> attachments,
      int initialIndex,
      ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (context) => _AttachmentViewer(
        attachments: attachments,
        initialIndex: initialIndex,
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailInfoCard extends StatelessWidget {
  const _DetailInfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? TutelaColors.plum, size: 20),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.58),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTextLine extends StatelessWidget {
  const _DetailTextLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TutelaColors.plum, size: 19),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.index});

  final String index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: TutelaColors.peach.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_outlined,
              color: TutelaColors.plum,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              'Photo $index',
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.65),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = filled ? TutelaColors.plum : TutelaColors.canvas;
    final foreground = filled ? TutelaColors.canvas : TutelaColors.rose;
    final border = filled ? TutelaColors.plum : TutelaColors.rose;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: foreground, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailIconButton extends StatelessWidget {
  const _DetailIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          shape: BoxShape.circle,
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: TutelaColors.plum, size: 21),
      ),
    );
  }
}

class _AttachmentViewer extends StatefulWidget {
  const _AttachmentViewer({
    required this.attachments,
    required this.initialIndex,
  });

  final List<Attachment> attachments;
  final int initialIndex;

  @override
  State<_AttachmentViewer> createState() => _AttachmentViewerState();
}

class _AttachmentViewerState extends State<_AttachmentViewer> {
  late int _currentIndex;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _downloadAttachment() async {
    final attachment = widget.attachments[_currentIndex];
    try {
      setState(() => _isDownloading = true);
      final response = await http.get(Uri.parse(attachment.secureUrl));
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${attachment.displayName}';
      final tempFile = File(tempPath);
      await tempFile.writeAsBytes(response.bodyBytes);

      if (attachment.isImage) {
        await Gal.putImage(tempPath);
        await tempFile.delete();
      } else if (attachment.isVideo) {
        await Gal.putVideo(tempPath);
        await tempFile.delete();
      } else {
        final downloadsPath = '/storage/emulated/0/Download/${attachment.displayName}';
        await tempFile.copy(downloadsPath);
        await tempFile.delete();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: ${attachment.displayName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attachment = widget.attachments[_currentIndex];

    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          Center(
            child: attachment.isImage
                ? InteractiveViewer(
              child: Image.network(
                attachment.secureUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(
                      color: TutelaColors.rose,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: TutelaColors.rose,
                    size: 64,
                  );
                },
              ),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    attachment.isVideo
                        ? Icons.video_file
                        : Icons.description,
                    color: TutelaColors.rose,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    attachment.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (widget.attachments.length > 1) ...[
                  GestureDetector(
                    onTap: _currentIndex > 0
                        ? () => setState(() => _currentIndex--)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color:
                        _currentIndex > 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1}/${widget.attachments.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  GestureDetector(
                    onTap: _currentIndex < widget.attachments.length - 1
                        ? () => setState(() => _currentIndex++)
                        : null,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: _currentIndex < widget.attachments.length - 1
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                ] else
                  const SizedBox.shrink(),
                GestureDetector(
                  onTap: _isDownloading ? null : _downloadAttachment,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: _isDownloading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Icon(
                      Icons.download,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _DetailTextField extends StatelessWidget {
  const _DetailTextField({
    required this.hint,
    this.controller,
    this.maxLines = 1,
    this.maxLength,
  });

  final TextEditingController? controller;
  final String hint;
  final int maxLines;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      cursorColor: TutelaColors.plum,
      style: GoogleFonts.dmSans(
        color: TutelaColors.plum,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.42),
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
        ),
        filled: true,
        fillColor: TutelaColors.ivory.withValues(alpha: 0.2),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: TutelaColors.plum.withValues(alpha: 0.14),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: const BorderSide(color: TutelaColors.plum, width: 1.4),
        ),
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({
    required this.comment,
    required this.isOwner,
    required this.isEditing,
    required this.editController,
    required this.maxLength,
    required this.onEdit,
    required this.onCancelEdit,
    required this.onSaveEdit,
    required this.onDelete,
  });

  final Comment comment;
  final bool isOwner;
  final bool isEditing;
  final TextEditingController editController;
  final int maxLength;
  final VoidCallback onEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSaveEdit;
  final VoidCallback onDelete;

  String _formatTime(Timestamp ts) {
    final date = ts.toDate();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: TutelaColors.plum.withValues(alpha: 0.12),
                backgroundImage: comment.authorAvatarUrl != null
                    ? NetworkImage(comment.authorAvatarUrl!)
                    : null,
                child: comment.authorAvatarUrl == null
                    ? Icon(
                  Icons.person_rounded,
                  color: TutelaColors.plum,
                  size: 18,
                )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName.isNotEmpty
                          ? comment.authorName
                          : 'Anonymous',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(comment.createdAt),
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum.withValues(alpha: 0.5),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              if (isOwner && !isEditing) ...[
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(
                    Icons.edit_outlined,
                    color: TutelaColors.plum.withValues(alpha: 0.6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: TutelaColors.rose,
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (isEditing) ...[
            _DetailTextField(
              controller: editController,
              hint: 'Edit your comment',
              maxLines: 3,
              maxLength: maxLength,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancelEdit,
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: onSaveEdit,
                  child: Text(
                    'Save',
                    style: GoogleFonts.dmSans(
                      color: TutelaColors.plum,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ] else
            Text(
              comment.body,
              style: GoogleFonts.dmSans(
                color: TutelaColors.plum.withValues(alpha: 0.85),
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.3,
                letterSpacing: 0,
              ),
            ),
        ],
      ),
    );
  }
}