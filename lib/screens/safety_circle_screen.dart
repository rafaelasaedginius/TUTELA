import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/emergency_contact_model.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../services/emergency_contact_service.dart';
import '../theme/tutela_colors.dart';
import '../widgets/tutela_bottom_nav.dart';

/// Halaman Emergency Contacts.
///
/// Alur utama halaman ini:
/// 1. Mengambil UID pengguna yang sedang login dari Firebase Authentication.
/// 2. Mendengarkan daftar kontak milik UID tersebut secara real-time.
/// 3. Menyediakan form untuk CREATE dan UPDATE kontak.
/// 4. Menyediakan tombol Call, Edit, dan Delete untuk setiap kontak.
/// 5. Tombol Call hanya membuka aplikasi Phone dengan nomor yang sudah terisi.
class SafetyCircleScreen extends StatefulWidget {
  const SafetyCircleScreen({super.key});

  @override
  State<SafetyCircleScreen> createState() => _SafetyCircleScreenState();
}

class _SafetyCircleScreenState extends State<SafetyCircleScreen> {
  // Service menjadi penghubung antara UI dan koleksi Firestore.
  final EmergencyContactService _contactService = EmergencyContactService();

  // Controller menyimpan teks yang sedang diketik pada form.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();

  // State form. Priority boleh sama antara beberapa kontak.
  int _priority = 1;
  bool _notifyOnSos = true;

  // Null berarti form sedang membuat kontak baru.
  // Berisi EmergencyContact berarti form sedang mengedit kontak lama.
  EmergencyContact? _editingContact;

  // Mencegah tombol Save ditekan berkali-kali ketika request belum selesai.
  bool _saving = false;

  // UID menentukan lokasi data: users/{uid}/contacts/{contactId}.
  // Jika null, pengguna belum login dan CRUD tidak boleh dijalankan.
  String? get _uid => fb.FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final contentWidth = (size.width - 32).clamp(300.0, 430.0);
    final uid = _uid;

    return Scaffold(
      backgroundColor: TutelaColors.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentWidth),
            child: Column(
              children: [
                const SizedBox(height: 14),
                // Safety Circle Header Start
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: _goBack,
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F7EE),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.groups_2_outlined,
                        color: Color(0xFF3C8B68),
                        size: 29,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency contacts',
                            style: GoogleFonts.fraunces(
                              color: TutelaColors.plum,
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            'Personal safety layer',
                            style: GoogleFonts.dmSans(
                              color: TutelaColors.plum.withValues(alpha: 0.58),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: Icons.local_police_outlined,
                      // Nomor 110 dikirim ke Phone app, bukan langsung ditelepon
                      // oleh Tutela. Pengguna tetap mengonfirmasi panggilan.
                      onTap: () => _openDialer('110'),
                      filled: true,
                    ),
                  ],
                ),
                // Safety Circle Header End
                const SizedBox(height: 18),
                Expanded(
                  child: uid == null
                      ? const _SignedOutState()
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              // Contact List Section Start
                              _CirclePanel(
                                title: 'Emergency contact list',
                                subtitle: 'People to contact in an emergency.',
                                // READ: StreamBuilder otomatis membangun ulang
                                // daftar saat data Firestore berubah.
                                child: StreamBuilder<List<EmergencyContact>>(
                                  stream: _contactService.watchContacts(uid),
                                  builder: (context, snapshot) {
                                    // Tampilkan loading hanya saat data pertama
                                    // belum selesai diambil.
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting &&
                                        !snapshot.hasData) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(14),
                                          child: CircularProgressIndicator(
                                            color: TutelaColors.plum,
                                          ),
                                        ),
                                      );
                                    }

                                    final contacts = snapshot.data ?? [];
                                    // Snapshot tanpa dokumen ditampilkan sebagai
                                    // empty state, bukan sebagai error.
                                    if (contacts.isEmpty) {
                                      return const _EmptyContactState();
                                    }

                                    return Column(
                                      children: [
                                        for (final contact in contacts) ...[
                                          _ContactListItem(
                                            contact: contact,
                                            // Membuka dialer dengan nomor kontak.
                                            onCall: () => _openDialer(
                                              contact.phoneNumber,
                                            ),
                                            // Memindahkan data kontak ke form.
                                            onEdit: () =>
                                                _startEditing(contact),
                                            // Meminta konfirmasi sebelum DELETE.
                                            onDelete: () => _confirmDelete(
                                              uid: uid,
                                              contact: contact,
                                            ),
                                          ),
                                          if (contact != contacts.last)
                                            const SizedBox(height: 10),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                              // Contact List Section End
                              const SizedBox(height: 14),
                              // Create Update Contact Form Start
                              _CirclePanel(
                                title: _editingContact == null
                                    ? 'Add contact'
                                    : 'Edit contact',
                                subtitle:
                                    'Name, phone, relationship, priority, and SOS notification.',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _CircleTextField(
                                            controller: _nameController,
                                            hint: 'Display name',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _CircleTextField(
                                            controller: _phoneController,
                                            hint: 'Phone number',
                                            keyboardType: TextInputType.phone,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    _CircleTextField(
                                      controller: _relationshipController,
                                      hint: 'Relationship',
                                    ),
                                    const SizedBox(height: 14),
                                    _SectionLabel('Priority'),
                                    const SizedBox(height: 9),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _PriorityButton(
                                            label: '1',
                                            selected: _priority == 1,
                                            onTap: () {
                                              setState(() => _priority = 1);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _PriorityButton(
                                            label: '2',
                                            selected: _priority == 2,
                                            onTap: () {
                                              setState(() => _priority = 2);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _PriorityButton(
                                            label: '3',
                                            selected: _priority == 3,
                                            onTap: () {
                                              setState(() => _priority = 3);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _NotifySwitch(
                                      value: _notifyOnSos,
                                      onChanged: (value) {
                                        setState(() => _notifyOnSos = value);
                                      },
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        if (_editingContact != null) ...[
                                          Expanded(
                                            child: _SecondaryCircleButton(
                                              icon: Icons.close_rounded,
                                              label: 'Cancel',
                                              onTap: _clearForm,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: _PrimaryCircleButton(
                                            label: _saving
                                                ? 'Saving...'
                                                : (_editingContact == null
                                                      ? 'Save contact'
                                                      : 'Update contact'),
                                            onTap: _saving
                                                ? () {}
                                                : () => _saveContact(uid),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Create Update Contact Form End
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                ),
                const SizedBox(height: 14),
                // Bottom Navigation Start
                const TutelaBottomNav(selected: TutelaNavTab.circle),
                // Bottom Navigation End
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveContact(String uid) async {
    // trim() menghapus spasi kosong di awal dan akhir input.
    final displayName = _nameController.text.trim();
    final phoneNumber = _phoneController.text.trim();
    final relationship = _relationshipController.text.trim();

    // Validasi sederhana sebelum data dikirim ke Firebase.
    if (displayName.isEmpty || phoneNumber.isEmpty || relationship.isEmpty) {
      _showMessage('Please fill in all contact fields.');
      return;
    }

    setState(() => _saving = true);
    try {
      final editingContact = _editingContact;

      // Satu nomor priority hanya boleh dimiliki oleh satu kontak.
      // Saat UPDATE, ID kontak yang sedang diedit dikecualikan supaya pengguna
      // tetap boleh menyimpan tanpa mengubah priority miliknya sendiri.
      final priorityTaken = await _contactService.isPriorityTaken(
        uid: uid,
        priority: _priority,
        excludedContactId: editingContact?.id,
      );
      if (priorityTaken) {
        _showMessage(
          'Priority $_priority is already used. Please choose another priority.',
        );
        return;
      }

      if (editingContact == null) {
        // CREATE: tidak ada kontak yang sedang diedit, jadi buat dokumen baru.
        await _contactService.addContact(
          uid: uid,
          displayName: displayName,
          phoneNumber: phoneNumber,
          relationship: relationship,
          priority: _priority,
          notifyOnSos: _notifyOnSos,
        );
      } else {
        // UPDATE: gunakan ID dokumen lama agar tidak membuat duplikat.
        // createdAt tetap memakai nilai lama, sedangkan updatedAt diperbarui
        // oleh EmergencyContactService.
        await _contactService.updateContact(
          uid: uid,
          contact: EmergencyContact(
            id: editingContact.id,
            userId: editingContact.userId,
            displayName: displayName,
            phoneNumber: phoneNumber,
            relationship: relationship,
            priority: _priority,
            notifyOnSos: _notifyOnSos,
            createdAt: editingContact.createdAt,
            updatedAt: editingContact.updatedAt,
          ),
        );
      }
      _clearForm();
      _showMessage('Emergency contact saved.');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      _showMessage('Failed to save contact.');
    } finally {
      // mounted dicek karena request async mungkin selesai setelah screen tutup.
      if (mounted) setState(() => _saving = false);
    }
  }

  void _goBack() {
    // Selalu kembali ke Home dan mengganti route saat ini.
    // Jangan memakai pop() di halaman utama navbar karena route di bawahnya
    // bisa berupa Splash/Auth, sehingga terlihat seperti pengguna ter-logout.
    Navigator.of(context).pushReplacementNamed(TutelaRoutes.home);
  }

  void _startEditing(EmergencyContact contact) {
    // UPDATE preparation: isi form dengan nilai kontak yang dipilih.
    setState(() {
      _editingContact = contact;
      _nameController.text = contact.displayName;
      _phoneController.text = contact.phoneNumber;
      _relationshipController.text = contact.relationship;
      _priority = contact.priority;
      _notifyOnSos = contact.notifyOnSos;
    });
  }

  void _clearForm() {
    // Mengembalikan form ke mode CREATE dan nilai awal.
    setState(() {
      _editingContact = null;
      _nameController.clear();
      _phoneController.clear();
      _relationshipController.clear();
      _priority = 1;
      _notifyOnSos = true;
    });
  }

  Future<void> _confirmDelete({
    required String uid,
    required EmergencyContact contact,
  }) async {
    // Dialog mengembalikan true jika Delete ditekan dan false/null jika batal.
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: TutelaColors.canvas,
          title: Text(
            'Remove contact?',
            style: GoogleFonts.fraunces(
              color: TutelaColors.plum,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Delete ${contact.displayName} from your emergency contacts?',
            style: GoogleFonts.dmSans(color: TutelaColors.plum),
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

    if (shouldDelete != true) return;

    try {
      // DELETE: hapus dokumen berdasarkan UID pemilik dan ID kontak.
      await _contactService.deleteContact(uid: uid, contactId: contact.id);
      // Bersihkan form jika kontak yang dihapus sedang diedit.
      if (_editingContact?.id == contact.id) _clearForm();
      _showMessage('Emergency contact deleted.');
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: false);
      _showMessage('Failed to delete contact.');
    }
  }

  Future<void> _openDialer(String phoneNumber) async {
    // Hilangkan spasi agar URI telepon valid, misalnya "0812 3456" menjadi
    // "08123456". Nomor tidak diubah atau ditelepon otomatis.
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    if (cleanedNumber.isEmpty) {
      _showMessage('Phone number is empty.');
      return;
    }

    // URI tel: meminta sistem operasi membuka aplikasi Phone/dialer.
    final uri = Uri(scheme: 'tel', path: cleanedNumber);
    if (await canLaunchUrl(uri)) {
      // externalApplication memastikan dialer dibuka di luar aplikasi Tutela.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _showMessage('Cannot open phone app.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _CirclePanel extends StatelessWidget {
  const _CirclePanel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.canvas,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: TutelaColors.plum.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Safety Circle Panel Header Start
          Text(
            title,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.15,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: GoogleFonts.dmSans(
              color: TutelaColors.plum.withValues(alpha: 0.62),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.25,
              letterSpacing: 0,
            ),
          ),
          // Safety Circle Panel Header End
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ContactListItem extends StatelessWidget {
  const _ContactListItem({
    required this.contact,
    required this.onCall,
    required this.onEdit,
    required this.onDelete,
  });

  final EmergencyContact contact;
  final VoidCallback onCall;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F7EE),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  contact.priority.toString(),
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF3C8B68),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.displayName,
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${contact.relationship} - ${contact.phoneNumber}',
                      style: GoogleFonts.dmSans(
                        color: TutelaColors.plum.withValues(alpha: 0.58),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        height: 1.15,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: contact.notifyOnSos
                      ? const Color(0xFFE2F7EE)
                      : TutelaColors.ivory.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  contact.notifyOnSos ? 'SOS on' : 'SOS off',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF3C8B68),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SecondaryCircleButton(
                  icon: Icons.phone_in_talk_outlined,
                  label: 'Call',
                  onTap: onCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SecondaryCircleButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DangerCircleButton(label: 'Delete', onTap: onDelete),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyContactState extends StatelessWidget {
  const _EmptyContactState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'No emergency contacts yet. Add a contact below so you can call them quickly during an emergency.',
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.68),
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Please sign in to manage emergency contacts.',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum.withValues(alpha: 0.68),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.3,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CircleTextField extends StatelessWidget {
  const _CircleTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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

class _PriorityButton extends StatelessWidget {
  const _PriorityButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? TutelaColors.plum : TutelaColors.canvas,
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: TutelaColors.plum, width: 1.2),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: selected ? TutelaColors.canvas : TutelaColors.plum,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _NotifySwitch extends StatelessWidget {
  const _NotifySwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TutelaColors.ivory.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active_outlined,
            color: TutelaColors.plum,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify on SOS',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Include this contact in emergency alerts.',
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum.withValues(alpha: 0.58),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.15,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: TutelaColors.plum,
            activeTrackColor: TutelaColors.rose.withValues(alpha: 0.28),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PrimaryCircleButton extends StatelessWidget {
  const _PrimaryCircleButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.plum,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: 0.18),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.canvas,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SecondaryCircleButton extends StatelessWidget {
  const _SecondaryCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.canvas,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.plum, width: 1.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TutelaColors.plum, size: 18),
            const SizedBox(width: 7),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    color: TutelaColors.plum,
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

class _DangerCircleButton extends StatelessWidget {
  const _DangerCircleButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TutelaColors.rose.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: TutelaColors.rose, width: 1.3),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            color: TutelaColors.rose,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          color: TutelaColors.plum,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final background = filled ? TutelaColors.plum : TutelaColors.canvas;
    final iconColor = filled ? TutelaColors.canvas : TutelaColors.plum;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: TutelaColors.plum.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: TutelaColors.plum.withValues(alpha: filled ? 0.18 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: iconColor, size: 21),
      ),
    );
  }
}
