import 'package:flutter/material.dart';

class FivePillarsScreen extends StatefulWidget {
  const FivePillarsScreen({super.key});

  @override
  State<FivePillarsScreen> createState() => _FivePillarsScreenState();
}

class _FivePillarsScreenState extends State<FivePillarsScreen> {
  final List<Map<String, String>> pillars = [
    {
      'title': 'Shahada',
      'subtitle': 'Declaration of Faith',
      'description':
          'The declaration of faith in Allah and His messenger Muhammad (PBUH). "There is no god but Allah, and Muhammad is His messenger."',
    },
    {
      'title': 'Salah',
      'subtitle': 'Prayer',
      'description':
          'Performing the five obligatory prayers daily: Fajr, Dhuhr, Asr, Maghrib, and Isha. Prayers are performed facing the Kaaba in Mecca.',
    },
    {
      'title': 'Zakat',
      'subtitle': 'Almsgiving',
      'description':
          'Giving 2.5% of annual savings to the poor and needy. Zakat purifies the soul and wealth of the giver.',
    },
    {
      'title': 'Sawm',
      'subtitle': 'Fasting',
      'description':
          'Fasting during the holy month of Ramadan from dawn to sunset. It teaches discipline, empathy, and spiritual growth.',
    },
    {
      'title': 'Hajj',
      'subtitle': 'Pilgrimage',
      'description':
          'The pilgrimage to Mecca performed once in a lifetime by those who are physically and financially able.',
    },
  ];

  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a472a), Color(0xFF0d2818)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFd4af37),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Five Pillars',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Pillars List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: pillars.length,
                  itemBuilder: (context, index) {
                    final pillar = pillars[index];
                    final isExpanded = selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(
                        () => selectedIndex = isExpanded ? null : index,
                      ),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Color(0xFF1a472a).withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isExpanded
                                ? Color(0xFFd4af37)
                                : Color(0xFF4a7c5e),
                            width: isExpanded ? 2 : 1.5,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${index + 1}. ${pillar['title']}',
                                            style: TextStyle(
                                              color: Color(0xFFd4af37),
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            pillar['subtitle']!,
                                            style: TextStyle(
                                              color: Color(0xFFb0b0b0),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: Color(0xFFd4af37),
                                    ),
                                  ],
                                ),
                              ),
                              // Description (shown when expanded)
                              if (isExpanded)
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                        color: Color(0xFF4a7c5e),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    pillar['description']!,
                                    style: TextStyle(
                                      color: Color(0xFFb0b0b0),
                                      fontSize: 13,
                                      height: 1.6,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
