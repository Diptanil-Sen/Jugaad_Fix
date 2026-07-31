import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF110806) : const Color(0xFFFFF8F0);
    final textColor = isDark ? Colors.white : const Color(0xFF2C1810);
    const primary = Color(0xFFFF6B00);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '🛡️ Admin Panel',
          style: GoogleFonts.balooBhai2(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primary,
          unselectedLabelColor: textColor.withOpacity(0.4),
          indicatorColor: primary,
          tabs: const [
            Tab(text: '⏳ Pending'),
            Tab(text: '✅ Approved'),
            Tab(text: '❌ Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _JugaadList(status: 'pending', bgColor: bgColor, textColor: textColor),
          _JugaadList(status: 'approved', bgColor: bgColor, textColor: textColor),
          _JugaadList(status: 'rejected', bgColor: bgColor, textColor: textColor),
        ],
      ),
    );
  }
}

class _JugaadList extends StatelessWidget {
  final String status;
  final Color bgColor;
  final Color textColor;

  const _JugaadList({
    required this.status,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF6B00);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C110D) : Colors.white;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('jugaads')
          .where('status', isEqualTo: status)
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF6B00)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Kuch gadbad ho gayi 😅\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor.withOpacity(0.6)),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  status == 'pending'
                      ? '🎉'
                      : status == 'approved'
                          ? '✅'
                          : '🗑️',
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'pending'
                      ? 'Koi pending jugaad nahi!'
                      : status == 'approved'
                          ? 'Abhi koi approved nahi'
                          : 'Koi rejected nahi',
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final jugaadId = docs[index].id;
            return _AdminCard(
              jugaadId: jugaadId,
              data: data,
              status: status,
              cardColor: cardColor,
              textColor: textColor,
              primary: primary,
            );
          },
        );
      },
    );
  }
}

class _AdminCard extends StatelessWidget {
  final String jugaadId;
  final Map<String, dynamic> data;
  final String status;
  final Color cardColor;
  final Color textColor;
  final Color primary;

  const _AdminCard({
    required this.jugaadId,
    required this.data,
    required this.status,
    required this.cardColor,
    required this.textColor,
    required this.primary,
  });

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final action = newStatus == 'approved' ? 'Approve' : 'Reject';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$action karna hai?'),
        content: Text('"${data['title']}" ko $action karoge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'approved' ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection('jugaads')
        .doc(jugaadId)
        .update({'status': newStatus});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'approved'
                ? '✅ Jugaad approved kar diya!'
                : '❌ Jugaad reject kar diya.',
          ),
          backgroundColor:
              newStatus == 'approved' ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteJugaad(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Permanently Delete?'),
        content: Text(
            '"${data['title']}" ko hamesha ke liye delete karoge?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await FirebaseFirestore.instance
        .collection('jugaads')
        .doc(jugaadId)
        .delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ Jugaad delete ho gaya'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = data['title'] as String? ?? 'Untitled';
    final description = data['description'] as String? ?? '';
    final categoryEmoji = data['categoryEmoji'] as String? ?? '🔧';
    final categoryLabel = data['categoryLabel'] as String? ?? '';
    final authorName = data['authorName'] as String? ?? 'Anonymous';
    final upvotes = data['upvotes'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: status == 'pending'
              ? primary.withOpacity(0.3)
              : status == 'approved'
                  ? Colors.green.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            children: [
              Text(categoryEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    Text(
                      categoryLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.thumb_up_alt_rounded,
                        size: 11, color: primary),
                    const SizedBox(width: 3),
                    Text(
                      '$upvotes',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Description ──
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.75),
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 10),

          // ── Author ──
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  size: 13, color: textColor.withOpacity(0.4)),
              const SizedBox(width: 4),
              Text(
                authorName,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Action Buttons ──
          if (status == 'pending') ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(context, 'rejected'),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(context, 'approved'),
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                if (status == 'approved')
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _updateStatus(context, 'rejected'),
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: const Text('Move to Rejected'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (status == 'rejected')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, 'approved'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Approve Instead'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => _deleteJugaad(context),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}