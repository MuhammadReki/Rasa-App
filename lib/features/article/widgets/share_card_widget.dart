import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/models/article.dart';

/// Widget card yang bakal di-screenshot buat share
/// Ukuran 360×640 (rasio 9:16) — cocok buat IG Story / WA Status
class ShareCardWidget extends StatelessWidget {
  final Article article;
  final int templateIndex; // 0: Minimal, 1: Bold, 2: Quote

  const ShareCardWidget({
    super.key,
    required this.article,
    this.templateIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (templateIndex) {
      case 1:
        return _buildBold();
      case 2:
        return _buildQuote();
      default:
        return _buildMinimal();
    }
  }

  // ===========================
  // TEMPLATE 0 — MINIMAL
  // ===========================
  Widget _buildMinimal() {
    return Container(
      width: 360,
      height: 640,
      decoration: const BoxDecoration(
        color: Color(0xFFFAF3E0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(24)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: article.coverUrl,
                  height: 340,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 340,
                    color: const Color(0xFFF0E4D6),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 340,
                    color: const Color(0xFFF0E4D6),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFFFAF3E0).withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 24,
                  left: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      article.tag,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFAA5C5C),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                      letterSpacing: -0.8,
                      color: const Color(0xFF3E2C23),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      height: 1.6,
                      color: const Color(0xFF6B5449),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFF0E4D6),
                        backgroundImage: article.authorAvatarUrl.isNotEmpty
                            ? CachedNetworkImageProvider(
                                article.authorAvatarUrl)
                            : null,
                        child: article.authorAvatarUrl.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 14,
                                color: Color(0xFFB4694D),
                              )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.authorName,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3E2C23),
                              ),
                            ),
                            Text(
                              'Penulis di Rasa',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: const Color(0xFF947867),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC97B5A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🌸', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          'Rasa',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '· ruang aman untuk rasa',
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================
  // TEMPLATE 1 — BOLD
  // ===========================
  Widget _buildBold() {
    return Container(
      width: 360,
      height: 640,
      decoration: const BoxDecoration(
        color: Color(0xFF3E2C23),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.35,
              child: CachedNetworkImage(
                imageUrl: article.coverUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.black),
                errorWidget: (_, __, ___) => Container(color: Colors.black),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC97B5A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    article.tag,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  article.title,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1.12,
                    letterSpacing: -1.0,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 40,
                  height: 3,
                  color: const Color(0xFFC97B5A),
                ),
                const SizedBox(height: 16),
                Text(
                  article.preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white.withValues(alpha: 0.15),
                      backgroundImage: article.authorAvatarUrl.isNotEmpty
                          ? CachedNetworkImageProvider(
                              article.authorAvatarUrl)
                          : null,
                      child: article.authorAvatarUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.authorName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          article.date,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text('🌸', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 4),
                    Text(
                      'Rasa',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
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

  // ===========================
  // TEMPLATE 2 — QUOTE
  // ===========================
  Widget _buildQuote() {
    return Container(
      width: 360,
      height: 640,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8B4A0),
            Color(0xFFC97B5A),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"',
              style: GoogleFonts.playfairDisplay(
                fontSize: 80,
                fontWeight: FontWeight.w700,
                height: 0.8,
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  article.preview,
                  maxLines: 10,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              width: 50,
              height: 3,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  backgroundImage: article.authorAvatarUrl.isNotEmpty
                      ? CachedNetworkImageProvider(
                          article.authorAvatarUrl)
                      : null,
                  child: article.authorAvatarUrl.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.authorName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      article.tag,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🌸', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  'Rasa',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '· ruang aman untuk rasa',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}