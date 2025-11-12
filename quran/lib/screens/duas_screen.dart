import 'package:flutter/material.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  final List<Map<String, String>> duas = [
    {
      'title': 'Dua for Guidance',
      'arabic': 'اللهم اهدنا الصراط المستقيم',
      'english': 'Allahumma ahdina al-sirat al-mustaqeem',
      'translation': 'O Allah, guide us to the straight path',
      'category': 'General',
    },
    {
      'title': 'Dua for Forgiveness',
      'arabic': 'اللهم اغفر لي ذنبي وإثمي',
      'english': 'Allahumma ighfir li dhanbi wa ithmi',
      'translation': 'O Allah, forgive my sin and my transgression',
      'category': 'Repentance',
    },
    {
      'title': 'Dua for Protection',
      'arabic': 'أعوذ بالله من الشيطان الرجيم',
      'english': 'A\'udhu billahi min ash-shaytan ar-rajeem',
      'translation': 'I seek refuge in Allah from the accursed Satan',
      'category': 'Protection',
    },
    {
      'title': 'Dua for Knowledge',
      'arabic': 'اللهم زدني علماً ولا تزغ قلبي',
      'english': 'Allahumma zidni \'ilman wa la tazigh qalbi',
      'translation': 'O Allah, increase me in knowledge and keep my heart firm',
      'category': 'Knowledge',
    },
    {
      'title': 'Dua for Peace',
      'arabic': 'اللهم أصلح بيننا وبين الناس',
      'english': 'Allahumma aslih baynana wa bayna an-naas',
      'translation': 'O Allah, make peace between us and the people',
      'category': 'Peace',
    },
    {
      'title': 'Dua for Health',
      'arabic': 'اللهم عافني في جسدي',
      'english': 'Allahumma \'aafini fi jasadi',
      'translation': 'O Allah, grant me wellness in my body',
      'category': 'Health',
    },
  ];

  List<Map<String, String>> filteredDuas = [];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    filteredDuas = duas;
  }

  void _filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == 'All') {
        filteredDuas = duas;
      } else {
        filteredDuas = duas
            .where((dua) => dua['category'] == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = {'All', ...duas.map((d) => d['category']!)};

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
                      'Duas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Category Filter
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: List.generate(categories.length, (index) {
                    final category = categories.elementAt(index);
                    final isSelected = selectedCategory == category;
                    return GestureDetector(
                      onTap: () => _filterByCategory(category),
                      child: Container(
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(0xFF1db854)
                              : Color(0xFF1a472a),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFFd4af37)
                                : Color(0xFF4a7c5e),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Color(0xFFb0b0b0),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Duas List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1a472a).withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF4a7c5e),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            dua['title']!,
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Arabic Text
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF0d2818),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Color(0xFF4a7c5e),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              dua['arabic']!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Color(0xFFd4af37),
                                fontSize: 18,
                                fontFamily: 'Traditional Arabic',
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          // Transliteration
                          Text(
                            'Transliteration: ${dua['english']}',
                            style: TextStyle(
                              color: Color(0xFF7a9a6b),
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Translation
                          Text(
                            'Translation: "${dua['translation']}"',
                            style: TextStyle(
                              color: Color(0xFFb0b0b0),
                              fontSize: 12,
                            ),
                          ),
                        ],
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
