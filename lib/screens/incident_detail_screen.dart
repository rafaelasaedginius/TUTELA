import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/incident_model.dart';
import '../models/attachment_model.dart';
import '../theme/tutela_colors.dart';

class IncidentDetailScreen extends StatelessWidget {
  const IncidentDetailScreen({
    super.key,
    required this.incident,
  });

  final Incident incident;

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
                                      color: TutelaColors.canvas.withValues(
                                        alpha: 0.16,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
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
                                label: 'Severity',
                                value: incident.severity.label,
                                icon: Icons.speed_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailInfoCard(
                                label: 'Status',
                                value: incident.status.name,
                                icon: Icons.task_alt_rounded,
                              ),
                            ),
                          ],
                        ),
                        // Detail Status Row End
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
                        // Detail Follow Up Start
                        _DetailPanel(
                          title: 'Follow-up history',
                          child: Column(
                            children: const [
                              _TimelineItem(
                                title: 'Report created',
                                detail: 'Initial report submitted by user.',
                              ),
                              SizedBox(height: 12),
                              _TimelineItem(
                                title: 'Moderator reviewed',
                                detail: 'Marked as visible on community map.',
                              ),
                            ],
                          ),
                        ),
                        // Detail Follow Up End
                        const SizedBox(height: 14),
                        // Detail Actions Start
                        Row(
                          children: [
                            Expanded(
                              child: _DetailActionButton(
                                label: 'Add follow-up',
                                icon: Icons.edit_note_rounded,
                                filled: true,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DetailActionButton(
                                label: 'Remove',
                                icon: Icons.delete_outline_rounded,
                                filled: false,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        // Detail Actions End
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
  });

  final String label;
  final String value;
  final IconData icon;

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
          Icon(icon, color: TutelaColors.plum, size: 20),
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

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: TutelaColors.rose,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: GoogleFonts.dmSans(
                  color: TutelaColors.plum.withValues(alpha: 0.62),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ],
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
      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/${attachment.displayName}';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded: ${attachment.displayName}')),
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


