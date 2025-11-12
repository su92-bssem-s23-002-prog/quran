import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime selectedDate;
  Map<String, dynamic>? islamicDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _loadIslamicDate(selectedDate);
  }

  Future<void> _loadIslamicDate(DateTime date) async {
    setState(() => isLoading = true);
    try {
      final formatter = DateFormat('dd-MM-yyyy');
      final formattedDate = formatter.format(date);
      final data = await ApiService.getIslamicDate(formattedDate);
      print('Islamic Date Response: $data'); // Debug print
      setState(() {
        // Extract the 'data' object from the response
        islamicDate = data['data'] ?? data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading Islamic date: $e');
    }
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
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Header
                Row(
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
                      'Islamic Calendar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Date Picker
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF1a472a).withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF4a7c5e), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Gregorian Date',
                        style: TextStyle(
                          color: Color(0xFFb0b0b0),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  primaryColor: Color(0xFFd4af37),
                                  colorScheme: ColorScheme.dark(
                                    primary: Color(0xFFd4af37),
                                    secondary: Color(0xFF1db854),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                            await _loadIslamicDate(picked);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF0d2818),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Color(0xFF4a7c5e),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'MMMM dd, yyyy',
                                ).format(selectedDate),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: Color(0xFFd4af37),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Islamic Date Info
                if (isLoading)
                  Center(
                    child: CircularProgressIndicator(color: Color(0xFFd4af37)),
                  )
                else if (islamicDate != null)
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1a472a).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFd4af37), width: 2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Islamic Date',
                          style: TextStyle(
                            color: Color(0xFFb0b0b0),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  'Day',
                                  style: TextStyle(
                                    color: Color(0xFF7a9a6b),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${islamicDate?['hijri']?['day'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 60,
                              color: Color(0xFF4a7c5e),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Month',
                                  style: TextStyle(
                                    color: Color(0xFF7a9a6b),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${islamicDate?['hijri']?['month']?['en'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 60,
                              color: Color(0xFF4a7c5e),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Year',
                                  style: TextStyle(
                                    color: Color(0xFF7a9a6b),
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '${islamicDate?['hijri']?['year'] ?? 'N/A'}',
                                  style: TextStyle(
                                    color: Color(0xFFd4af37),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
