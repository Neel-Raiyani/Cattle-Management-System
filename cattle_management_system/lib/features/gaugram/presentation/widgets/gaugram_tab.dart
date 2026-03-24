import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/upload_post_screen.dart';

class GauGramTab extends StatelessWidget {
  const GauGramTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 80),
        children: [
          _buildSectionHeader('Gaushala\'s Post'),
          _buildDetailedPostItem(
            context,
            avatar: 'assets/images/user3.png',
            name: 'Ravi Akhiyaniya',
            gaushala: 'Hari Om Gir Gaushala',
            timeAgo: '11 Dec 2025',
          ),
          _buildPostItem(
            context,
            avatar: 'assets/images/user1.png', // Placeholder
            name: 'Jatinbhai Vada',
            gaushala: 'Visavadar Gaushala',
            timeAgo: '7 Days ago',
            imageUrl: 'assets/images/cow_herd.jpg', // Placeholder
            likes: 2,
            comments: 0,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UploadPostScreen()),
          );
        },
        backgroundColor: const Color(0xFFA4C639), // Light Olive Green
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add New Post',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPostItem(
    BuildContext context, {
    required String avatar,
    required String name,
    required String gaushala,
    required String timeAgo,
    String? imageUrl,
    String? caption,
    int likes = 0,
    int comments = 0,
    bool isDocument = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage(
                    avatar,
                  ), // Will fail if asset missing, handle gracefully?
                  radius: 20,
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ), // Fallback
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        gaushala,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Content
          if (imageUrl != null)
            Container(
              height: 200,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(imageUrl), // Will fail if not present
                  fit: BoxFit.cover,
                  onError: (_, __) {}, // Handle error
                ),
              ),
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.white54),
              ),
            ),

          if (isDocument)
            Container(
              height: 100,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.description, color: Colors.blue, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Document.pdf",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

          if (caption != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(caption, style: GoogleFonts.inter(fontSize: 14)),
            ),

          const SizedBox(height: 8),
          const Divider(height: 1),

          // Footer (Likes, Comments, Share)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFA4C639),
                  size: 20,
                ), // Light Green Like
                const SizedBox(width: 4),
                Text(
                  '$likes',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 16),

                const Icon(
                  Icons.comment_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$comments',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 16),

                const Icon(
                  Icons.send_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                const Spacer(),

                Text(
                  timeAgo,
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedPostItem(
    BuildContext context, {
    required String avatar,
    required String name,
    required String gaushala,
    required String timeAgo,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.pink.shade50,
                radius: 24,
                child: const Icon(
                  Icons.person,
                  color: Colors.pink,
                ), // Placeholder for Ravi logic
                // For real usage: backgroundImage: AssetImage(avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      gaushala,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            'https://www.facebook.com/share/v/1AGCDD6tFT/',
            style: GoogleFonts.inter(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'જય શ્રી કૃષ્ણ 🙏 જય ગૌમાતા 🐄\nહરિ ઓમ ગિર ગૌશાળા\n\nઅત્યંત આનંદ અને ગૌરવની વાત છે કે આજે અમારી ગૌશાળામાં સ્વામિનારાયણ મંદિર અકાડેમી પૂજ્ય સંતો પધાર્યા હતા.\n\nતેમના પવિત્ર દર્શન, દિવ્ય આશીર્વાદ અને સહજતાની ઉપસ્થિતિ સમગ્ર ગૌશાળા તેમજ સેવકો ધન્ય અને અભિભૂત બની ગયા.', // Sample Gujarati
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            '#bapsswaminarayan #gaushala #bansigir #gircow #gauseva\n#SevaBhav #bhakti #simplelife #bharuch #hariomgirgaushala\n#viral #bapsmedia',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Read More',
              style: GoogleFonts.poppins(
                color: const Color(0xFFA4C639),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),

          const Divider(height: 24),

          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.black87, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '1',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.chat_bubble_outline, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.send_outlined, size: 20),
                ],
              ),
              Text(
                timeAgo,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
