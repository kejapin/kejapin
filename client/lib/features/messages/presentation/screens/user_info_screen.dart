import 'package:flutter/material.dart';
import 'package:client/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/messages_repository.dart';

class UserInfoScreen extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;

  const UserInfoScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _listings = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Fetch User Profile
      final userRes = await supabase
          .from('users')
          .select()
          .eq('id', widget.userId)
          .maybeSingle(); // Use maybeSingle to avoid crash if restricted
      
      // 2. Fetch Listings (if any)
      final listingsRes = await supabase
          .from('properties')
          .select('id, title, price_amount, photos, status')
          .eq('owner_id', widget.userId)
          .eq('status', 'AVAILABLE')
          .limit(10);
      
      if (mounted) {
        setState(() {
          _userData = userRes;
          _listings = List<Map<String, dynamic>>.from(listingsRes);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve URL from props or fetched data or cache
    String? rawUrl = widget.avatarUrl;
    if (_userData != null && _userData!['profile_picture'] != null) {
      rawUrl = _userData!['profile_picture'];
    } else {
      rawUrl ??= MessagesRepository.getUserCache(widget.userId)?['profile_picture'];
    }

    final effectiveUrl = (rawUrl != null && !rawUrl.startsWith('http')) 
        ? MessagesRepository.ensureFullUrl(rawUrl) 
        : rawUrl;

    final role = _userData?['role'] ?? 'TENANT';
    final fullName = _userData != null 
        ? '${_userData!['first_name'] ?? ''} ${_userData!['last_name'] ?? ''}'.trim()
        : widget.userName;
    
    final email = _userData?['email'];
    final phone = _userData?['phone_number'];

    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.structuralBrown),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.userInfo,
          style: GoogleFonts.workSans(
            color: AppColors.structuralBrown,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.mutedGold))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Avatar
                  Hero(
                    tag: 'avatar_${widget.userId}',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: _buildAvatar(effectiveUrl, fullName.isNotEmpty ? fullName : widget.userName),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    fullName.isNotEmpty ? fullName : widget.userName,
                    style: GoogleFonts.workSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.structuralBrown,
                    ),
                  ),
                  
                  // Role Badge
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getRoleColor(role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getRoleColor(role).withOpacity(0.5)),
                    ),
                    child: Text(
                      role.toString().toUpperCase(),
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(role),
                      ),
                    ),
                  ),

                  // Contact Info Section
                  if (email != null || phone != null) ...[
                    const SizedBox(height: 32),
                    _buildSectionHeader(context, "Contact Info"),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0,4))
                          ]
                        ),
                        child: Column(
                          children: [
                            if (email != null)
                              _buildContactRow(Icons.email_outlined, email),
                            if (email != null && phone != null)
                              Divider(height: 1, color: Colors.grey[200]),
                            if (phone != null)
                              _buildContactRow(Icons.phone_outlined, phone),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Listings Section
                  if (_listings.isNotEmpty) ...[
                    const SizedBox(height: 32),
                     _buildSectionHeader(context, "Listings"),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: _listings.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final item = _listings[index];
                          return _buildListingCard(item);
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildActionTile(
                          icon: Icons.flag_outlined, 
                          title: AppLocalizations.of(context)!.reportUser, 
                          color: Colors.red[400],
                          onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report feature coming soon")));
                          }
                        ),
                        const SizedBox(height: 16),
                        _buildActionTile(
                          icon: Icons.block, 
                          title: AppLocalizations.of(context)!.blockUser, 
                          color: Colors.grey[700],
                          onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Block feature coming soon")));
                          }
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.workSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.structuralBrown, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.workSans(
                color: AppColors.structuralBrown,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingCard(Map<String, dynamic> item) {
    final photos = item['photos'];
    String? imageUrl;
    if (photos != null) {
      if (photos is List && photos.isNotEmpty) {
        imageUrl = photos[0];
      } else if (photos is String && photos.isNotEmpty) {
        imageUrl = photos.contains(',') ? photos.split(',')[0].trim() : photos;
      }
    }
    
    final title = item['title'] ?? 'Listing';
    final price = item['price_amount']?.toString() ?? '0';
    final currency = 'KES'; // Default currency as it's not in the properties table yet

    return GestureDetector(
      onTap: () {
        // Navigate to Listing Details?
        // context.push('/listing/${item['id']}'); // Assuming route exists
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: imageUrl != null 
                    ? CachedNetworkImage(
                        imageUrl: imageUrl, 
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_,__) => Container(color: Colors.grey[200]),
                      )
                    : Container(color: Colors.grey[200], child: const Icon(Icons.home, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.workSans(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    '$currency $price',
                    style: GoogleFonts.workSans(color: AppColors.mutedGold, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toUpperCase()) {
      case 'LANDLORD':
      case 'AGENT':
        return AppColors.mutedGold;
      case 'CARETAKER':
        return Colors.green;
      case 'ADMIN':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildAvatar(String? url, String name) {
    if (url == null || url.isEmpty) {
        return CircleAvatar(
          backgroundColor: AppColors.structuralBrown.withOpacity(0.1),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: GoogleFonts.workSans(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
          ),
        );
    }
    
    final isSvg = url.toLowerCase().endsWith('.svg');
    final isLottie = url.toLowerCase().endsWith('.json');

    return ClipOval(
      child: isSvg 
          ? SvgPicture.network(url, fit: BoxFit.cover)
          : isLottie
              ? Lottie.network(url, fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, err) => const Icon(Icons.error),
                ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap, Color? color}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.structuralBrown).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color ?? AppColors.structuralBrown, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.workSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.structuralBrown,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
