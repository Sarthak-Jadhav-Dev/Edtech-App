import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:kte/services/firestore_service.dart';

class LinkParentScreen extends StatefulWidget {
  const LinkParentScreen({super.key});

  @override
  State<LinkParentScreen> createState() => _LinkParentScreenState();
}

class _LinkParentScreenState extends State<LinkParentScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _firestoreService = FirestoreService();

  DocumentSnapshot? _foundParent;
  bool _isSearching = false;
  bool _isLinking = false;
  bool _isLoadingParents = true;
  String _message = "";

  List<Map<String, dynamic>> _linkedParents = [];
  final int _maxParents = 2;

  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadLinkedParents();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _loadLinkedParents() async {
    setState(() => _isLoadingParents = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoadingParents = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final ids = List<dynamic>.from(data['linkedParentIds'] ?? []);
        final parents = await _firestoreService.getLinkedParents(ids);
        setState(() => _linkedParents = parents);
      }
    } catch (_) {}
    setState(() => _isLoadingParents = false);
  }

  Future<void> _search() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isSearching = true;
      _message = "";
      _foundParent = null;
    });

    final doc = await _firestoreService.searchUserByEmail(email);
    if (doc != null) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['userType'] == 'Parent') {
        // Check if already linked
        if (_linkedParents.any((p) => p['uid'] == doc.id)) {
          _message = "This parent is already linked to your account.";
        } else {
          _foundParent = doc;
        }
      } else {
        _message = "The account found is not a Parent.";
      }
    } else {
      _message = "No parent found with that email.";
    }

    setState(() => _isSearching = false);
  }

  Future<void> _link() async {
    if (_foundParent == null) return;
    if (_linkedParents.length >= _maxParents) {
      _showSnack("You can only link up to $_maxParents parent accounts.", isError: true);
      return;
    }

    setState(() => _isLinking = true);
    final studentId = FirebaseAuth.instance.currentUser?.uid;
    if (studentId != null) {
      final success = await _firestoreService.linkParentToStudent(studentId, _foundParent!.id);
      if (mounted) {
        if (success) {
          _showSnack("Parent linked successfully! 🎉");
          _emailController.clear();
          setState(() => _foundParent = null);
          await _loadLinkedParents();
        } else {
          _showSnack("Could not link. Max limit reached or already linked.", isError: true);
        }
      }
    }
    setState(() => _isLinking = false);
  }

  Future<void> _removeParent(String parentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1040),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Remove Parent?", style: TextStyle(color: Colors.white, fontFamily: "Poppins")),
        content: const Text("Are you sure you want to unlink this parent?",
            style: TextStyle(color: Colors.white70, fontFamily: "Sans")),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.purple)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Remove", style: TextStyle(color: Colors.red.shade300)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final studentId = FirebaseAuth.instance.currentUser?.uid;
    if (studentId == null) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      batch.update(FirebaseFirestore.instance.collection('users').doc(studentId), {
        'linkedParentIds': FieldValue.arrayRemove([parentId])
      });
      batch.update(FirebaseFirestore.instance.collection('users').doc(parentId), {
        'linkedChildIds': FieldValue.arrayRemove([studentId])
      });
      await batch.commit();
      _showSnack("Parent removed.");
      await _loadLinkedParents();
    } catch (e) {
      _showSnack("Failed to remove parent.", isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontFamily: "Sans")),
      backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF6C3FC8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool maxReached = _linkedParents.length >= _maxParents;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0825),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCounterCard(),
                  const SizedBox(height: 24),
                  _buildSectionLabel("Add a Parent"),
                  const SizedBox(height: 12),
                  if (!maxReached) ...[
                    _buildSearchBar(),
                  ] else ...[
                    _buildMaxReachedBanner(),
                  ],
                  const SizedBox(height: 24),
                  if (_isSearching) _buildSearchingIndicator(),
                  if (_message.isNotEmpty && !_isSearching) _buildMessageBanner(),
                  if (_foundParent != null && !_isSearching) _buildFoundParentCard(),
                  const SizedBox(height: 32),
                  _buildConnectedParentsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A0D47),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: const Text(
          "Link Parent",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C3FC8), Color(0xFF1A0D47)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.family_restroom_rounded,
                  size: 64, color: Colors.white.withOpacity(0.12)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCard() {
    final int count = _linkedParents.length;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4527A0), Color(0xFF6C3FC8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3FC8).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Connected Parents",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: "Sans",
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$count",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4, left: 4),
                      child: Text(
                        "/ 2",
                        style: TextStyle(
                          color: Colors.white54,
                          fontFamily: "Sans",
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Progress dots
          Column(
            children: List.generate(_maxParents, (i) {
              final filled = i < count;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? Colors.greenAccent : Colors.white24,
                    boxShadow: filled
                        ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.5), blurRadius: 6)]
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedParentsSection() {
    if (_isLoadingParents) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(color: Color(0xFF6C3FC8)),
        ),
      );
    }

    if (_linkedParents.isEmpty) {
      return Column(
        children: [
          Lottie.asset(
            'assets/lottie/no_parent.json',
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, _) => Icon(
              Icons.family_restroom_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "No parents linked yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontFamily: "Poppins",
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Search by email below to connect a parent.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontFamily: "Sans",
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Connected Parents (${_linkedParents.length}/$_maxParents)"),
        const SizedBox(height: 12),
        ..._linkedParents.map((parent) => _buildParentCard(parent)),
      ],
    );
  }

  Widget _buildParentCard(Map<String, dynamic> parent) {
    final name = "${parent['firstName'] ?? ''} ${parent['lastName'] ?? ''}".trim();
    final email = parent['email'] ?? '';
    final uid = parent['uid'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1040),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF9C27B0), Color(0xFF4527A0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "P",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Poppins",
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          name.isEmpty ? "Parent" : name,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            children: [
              const Icon(Icons.email_outlined, size: 12, color: Colors.white38),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontFamily: "Sans",
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        trailing: _buildLinkedBadge(uid),
      ),
    );
  }

  Widget _buildLinkedBadge(String uid) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 12),
              SizedBox(width: 4),
              Text("Linked", style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontFamily: "Sans")),
            ],
          ),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => _removeParent(uid),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.link_off, color: Colors.red.shade300, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white70,
        fontFamily: "Poppins",
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1040),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.white, fontFamily: "Sans"),
              decoration: InputDecoration(
                hintText: "Enter parent's email address…",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: "Sans"),
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.purple, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
              keyboardType: TextInputType.emailAddress,
              onSubmitted: (_) => _search(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C3FC8), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _isSearching ? null : _search,
                icon: _isSearching
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.search, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF6C3FC8)),
      ),
    );
  }

  Widget _buildMessageBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _message,
              style: const TextStyle(color: Colors.redAccent, fontFamily: "Sans", fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundParentCard() {
    final data = _foundParent!.data() as Map<String, dynamic>;
    final name = "${data['firstName'] ?? ''} ${data['lastName'] ?? ''}".trim();
    final email = data['email'] ?? '';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1040),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF6C3FC8).withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9C27B0), Color(0xFF4527A0)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : "P",
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Poppins",
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name.isEmpty ? "Parent Account" : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                            color: Colors.white54, fontFamily: "Sans", fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                  ),
                  child: const Text("Parent", style: TextStyle(color: Colors.purpleAccent, fontFamily: "Sans", fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLinking ? null : _link,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ).copyWith(
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C3FC8), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: _isLinking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.link, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Link This Parent",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaxReachedBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Colors.amber, size: 28),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Maximum Limit Reached",
                  style: TextStyle(
                    color: Colors.amber,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "You can link up to 2 parent accounts. Remove one above to add another.",
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: "Sans",
                    fontSize: 12,
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
