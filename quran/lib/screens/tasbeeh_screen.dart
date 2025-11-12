import 'package:flutter/material.dart';

class TasbeehScreen extends StatefulWidget {
  const TasbeehScreen({super.key});

  @override
  State<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends State<TasbeehScreen> {
  int counter = 0;
  int selectedTab = 0;

  final List<String> tasbeehOptions = [
    'SubhanAllah\n(Glory be to Allah)',
    'Alhamdulillah\n(All praise is due to Allah)',
    'Allahu Akbar\n(Allah is the Greatest)',
    'La ilaha illallah\n(There is no god but Allah)',
  ];

  void _increment() {
    setState(() => counter++);
  }

  void _decrement() {
    if (counter > 0) {
      setState(() => counter--);
    }
  }

  void _reset() {
    setState(() => counter = 0);
  }

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
                      'Tasbeeh Counter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tasbeeh Options
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(
                          tasbeehOptions.length,
                          (index) => GestureDetector(
                            onTap: () => setState(() => selectedTab = index),
                            child: Container(
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: selectedTab == index
                                    ? Color(0xFF1db854)
                                    : Color(0xFF1a472a),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selectedTab == index
                                      ? Color(0xFFd4af37)
                                      : Color(0xFF4a7c5e),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                tasbeehOptions[index].split('\n')[0],
                                style: TextStyle(
                                  color: selectedTab == index
                                      ? Colors.white
                                      : Color(0xFFb0b0b0),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    // Tasbeeh Display
                    Container(
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Color(0xFF1a472a).withOpacity(0.6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFd4af37), width: 3),
                      ),
                      child: Column(
                        children: [
                          Text(
                            tasbeehOptions[selectedTab],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            counter.toString(),
                            style: TextStyle(
                              color: Color(0xFFd4af37),
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                    // Control Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Decrement Button
                        GestureDetector(
                          onTap: _decrement,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF1db854),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFd4af37),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                        // Increment Button
                        GestureDetector(
                          onTap: _increment,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Color(0xFF1db854),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFd4af37),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        // Reset Button
                        GestureDetector(
                          onTap: _reset,
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Color(0xFF1db854),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFFd4af37),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
