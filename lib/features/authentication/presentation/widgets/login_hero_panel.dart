import 'package:flutter/material.dart';

final class LoginHeroPanel extends StatelessWidget {
  const LoginHeroPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF222522),
      child: Column(
        children: [
          Expanded(child: _CampaignArtwork()),
          SizedBox(height: 190, child: _NewsPanel()),
        ],
      ),
    );
  }
}

final class _CampaignArtwork extends StatelessWidget {
  const _CampaignArtwork();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0E514F), Color(0xFF4A8C91), Color(0xFFBAD6C5)],
            ),
          ),
        ),
        Positioned(
          left: -90,
          top: -130,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 46),
            ),
          ),
        ),
        const Positioned(
          left: 70,
          right: 70,
          bottom: 34,
          child: _CampaignCopy(),
        ),
        const Positioned(
          right: 52,
          top: 90,
          child: Icon(Icons.auto_awesome, size: 210, color: Color(0x8839FF88)),
        ),
      ],
    );
  }
}

final class _CampaignCopy extends StatelessWidget {
  const _CampaignCopy();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xAA79D667),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFCBF4B6), width: 2),
          ),
          child: const Text(
            'BẢN CẬP NHẬT',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'CHIẾN DỊCH\nTHẦN LONG',
          style: TextStyle(
            color: Color(0xFFEFFFD8),
            fontSize: 52,
            height: .95,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: Color(0xFF37786E),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'NHẬP CODE   •   UPDATE1909',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

final class _NewsPanel extends StatelessWidget {
  const _NewsPanel();

  static const _news = [
    ('[THÔNG BÁO] THAY ĐỔI THỜI GIAN SỰ KIỆN', '25/07/2025'),
    ('Tổng Quan Bản Cập Nhật “Kho Báu Bí Ẩn”', '16/07/2025'),
    ('Hướng Dẫn Build Tinh Hạch PVE', '09/06/2025'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 28, 14),
      child: Row(
        children: [
          Container(
            width: 310,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFF102444), Color(0xFFB52B20)],
              ),
            ),
            child: const Center(
              child: Text(
                'THÔNG BÁO\nSỰ KIỆN MỚI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFFFD479),
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tin Tức',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in _news)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.adjust,
                          color: Color(0xFFFF342B),
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.$1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
