    # Tutela Demo Notes

    Catatan ini fokus pada fitur yang saya kerjakan dan logic yang mungkin ditanya
    saat demo.

    ## 1. Forgot Password

    **Pakai:** Firebase Authentication (`firebase_auth`).

    **File penting:**

    - `lib/screens/forgot_password_screen.dart`
    - `lib/services/auth_service.dart`
    - `lib/screens/auth_screen.dart`

    **Alur:**

    1. Link `Forgot password?` pada login membuka `ForgotPasswordScreen`.
    2. Email di-trim dan diperiksa formatnya dengan RegExp.
    3. Screen memanggil `AuthService.sendPasswordReset(email)`.
    4. Service menjalankan `FirebaseAuth.sendPasswordResetEmail()`.
    5. Firebase membuat reset link dan mengirimkannya ke email pengguna.

    **Jawaban demo:**

    > Saya memakai Firebase Authentication. Aplikasi hanya mengirim alamat email ke
    > Firebase. Token dan reset link dibuat oleh Firebase, jadi aplikasi tidak perlu
    > membaca password lama pengguna.

    `_isSending` mencegah tombol ditekan berulang kali. `FirebaseAuthException.code`
    dipetakan menjadi pesan invalid email, terlalu banyak request, atau network error.

    ## 2. Emergency Contact CRUD

    **Pakai:** Cloud Firestore (`cloud_firestore`) dan Firebase Authentication.

    **File penting:**

    - `lib/models/emergency_contact_model.dart`
    - `lib/services/emergency_contact_service.dart`
    - `lib/screens/safety_circle_screen.dart`

    **Lokasi Firestore:**

    ```text
    users/{uid}/contacts/{contactId}
    ```

    UID membuat setiap pengguna memiliki subcollection kontak sendiri.

    **CRUD:**

    - Create: `addContact()` memakai Firestore `add()`.
    - Read real-time: `watchContacts()` memakai `snapshots()` dan `StreamBuilder`.
    - Update: `updateContact()` memakai document ID kontak.
    - Delete: `deleteContact()` setelah dialog konfirmasi.

    Model memiliki `fromMap()` untuk Firestore -> object Dart, `toMap()` untuk
    create, dan `toUpdateMap()` untuk update tanpa menimpa `createdAt` dan `userId`.

    **Priority:**

    `isPriorityTaken()` memastikan priority 1, 2, atau 3 tidak digunakan dua kontak.
    Saat edit, ID kontak sendiri dikecualikan sehingga priority lama tetap valid.

    **Jawaban demo:**

    > Saya memisahkan model, service, dan screen. Model menentukan struktur data,
    > service menangani query Firestore, dan screen hanya menangani input serta state.

    ## 3. SOS Call Workflow

    **Pakai:** `url_launcher`, Firebase Auth, dan EmergencyContactService.

    **File penting:**

    - `lib/screens/home_screen.dart` method `_triggerSos()`
    - `lib/screens/home_dashboard_screen.dart` method `_triggerSos()`
    - `lib/services/emergency_contact_service.dart` method `getContacts()`

    **Alur:**

    1. Ambil UID user yang login.
    2. Ambil emergency contacts yang diurutkan berdasarkan priority.
    3. Pilih kontak pertama.
    4. Jika kontak tidak tersedia, gunakan nomor polisi `110`.
    5. Bersihkan spasi dari nomor dan buat `Uri(scheme: 'tel', path: nomor)`.
    6. `launchUrl()` membuka aplikasi Phone bawaan.

    **Jawaban demo:**

    > Tutela tidak melakukan panggilan diam-diam. Aplikasi membuka dialer dan mengisi
    > nomor secara otomatis, lalu pengguna tetap mengonfirmasi dengan tombol Call.

    Ini lebih aman dan sesuai pembatasan sistem operasi mobile.

    ## 4. Local Notifications

    **Pakai:** Awesome Notifications + listener real-time Cloud Firestore.

    **File penting:**

    - `lib/services/notification_service.dart`
    - `lib/main.dart`
    - permission `POST_NOTIFICATIONS` pada AndroidManifest.

    **Trigger notification:**

    1. Incident milik user mendapatkan UID baru pada field `verifiedBy`.
    2. User lain menambahkan comment pada incident milik user.

    Snapshot pertama hanya menjadi data awal. Ini mencegah data lama memunculkan
    notification ketika aplikasi baru dibuka. Komentar sendiri dan verifikasi sendiri
    diabaikan.

    Awesome Notifications membuat local notification dengan payload `incidentId`.
    Saat ditekan, global `navigatorKey` mengambil incident terbaru dari Firestore dan
    membuka `IncidentDetailScreen`.

    **Jawaban demo:**

    > Saya menggunakan Firestore snapshot listener untuk mendeteksi perubahan dan
    > Awesome Notifications untuk menampilkan local notification. Solusi ini gratis
    > karena tidak memakai Cloud Functions atau server push.

    **Batasan yang harus dijelaskan jujur:**

    Notification bekerja ketika proses aplikasi masih aktif, termasuk beberapa kondisi
    background. Jika aplikasi sudah dihentikan sepenuhnya oleh sistem, listener tidak
    berjalan. Notification yang selalu berjalan saat app ditutup memerlukan FCM dan
    backend terpercaya seperti Cloud Functions.

    ## Pertanyaan Debugging Umum

    **Kenapa memakai `mounted` setelah `await`?**

    Karena operasi async mungkin selesai setelah screen ditutup. `mounted` memastikan
    widget masih ada sebelum `setState` atau memakai `BuildContext`.

    **Kenapa memakai try/catch?**

    Firebase, Firestore, internet, dan aplikasi eksternal dapat gagal. Error ditangkap
    agar aplikasi tidak crash dan pengguna mendapat pesan yang jelas.

    **Kenapa logic dipisah ke service?**

    Agar screen tidak penuh query backend, logic dapat digunakan ulang, dan debugging
    lebih mudah karena tanggung jawab setiap file jelas.
