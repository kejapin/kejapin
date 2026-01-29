import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Messages', showSearch: false),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search landlord, property...',
                hintStyle: GoogleFonts.workSans(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          // Messages List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMessageTile(
                  name: 'Sarah Jenkins',
                  time: '9:41 AM',
                  property: 'The Lofts @ Westlands',
                  message: "I've confirmed the appointment for tomorrow at 2 PM. See you there!",
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCFJYdunEc08i3_8k4U7Sci8l_X-oMDmnPh8ms72SkSbLsCsrojyjLTsEfNApj_zDT3KVUg-61TJyb6BrXQFPfIV5LM46zDj5TFDUdm1FFhI6ZBtJhpjwSLB7-1EYO1MTUrtsUw3gIgBEmBSyd8A9p-ym8enYp5mBJnm07w-waJeLSFSUgnyiAJUoXOSHepp9evfAjPzHcCq5DPxa3NzcW4HWpbBFtN8i1njL3TB3P6eGlpc0nojHiTzvzOVB5T4zg7IhXw0aYDQ9Q',
                  isUnread: true,
                ),
                const SizedBox(height: 8),
                _buildMessageTile(
                  name: 'David Kimani',
                  time: 'Yesterday',
                  property: 'Riverside Park Apts',
                  message: "Thanks for your interest. The service charge covers security...",
                  avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDhRwsGchV2b3D2Q8tyUPVmZHqfVzxUo8uTuPNI1CsnXwfLfqONt-euHU-1Zr0VYZb7s5Kf5UxoEACvKu_BvwPpQHrUdxzGjPXIY8C_SyphK7XR3PYIEtkbVxv_5pcF4E3GhhPNnY191zYdUcVa8MORFkP99oT7B5mw1WVIEZEN-wUtKg1KVxR6wefEswTjvF7UajikJIC6m-PMnvMRoGFr1Oz-lHa_ElTDEbkpW5EEi19Gtyq7jcxqSSxgZO1MjvgVLEjnrPeXwgc',
                  isUnread: true,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Divider(height: 1, color: Colors.black12),
                ),
                _buildMessageTile(
                  name: 'Olive Tree Housing',
                  time: 'Tue',
                  property: 'Kileleshwa Heights',
                  message: "Let me know if you have any other questions regarding the lease agreement.",
                  initials: 'OT',
                  isUnread: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile({
    required String name,
    required String time,
    required String property,
    required String message,
    String? avatarUrl,
    String? initials,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.structuralBrown.withOpacity(0.1),
                  image: avatarUrl != null
                      ? DecorationImage(
                          image: NetworkImage(avatarUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: avatarUrl == null
                    ? Center(
                        child: Text(
                          initials ?? '',
                          style: GoogleFonts.workSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.structuralBrown,
                          ),
                        ),
                      )
                    : null,
              ),
              if (isUnread)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.sageGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.workSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.structuralBrown,
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.workSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUnread ? AppColors.mutedGold : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.apartment, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property,
                        style: GoogleFonts.workSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: GoogleFonts.workSans(
                          fontSize: 14,
                          fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                          color: isUnread ? AppColors.structuralBrown : Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        margin: const EdgeInsets.only(top: 6, left: 8),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.mutedGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
