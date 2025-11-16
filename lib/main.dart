import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:html_unescape/html_unescape.dart';

void main() {
  runApp(const MaterialApp(home: McqPage()));
}

class McqPage extends StatefulWidget {
  const McqPage({super.key});

  @override
  State<McqPage> createState() => _McqPageState();
}

class _McqPageState extends State<McqPage> {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://prod.etestpaper.net',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  bool isLoading = false;
  List<dynamic> mcqs = [];
  String? errorMessage;

  /// Replace this with your actual bearer token
  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2ODg3NGUzNzVmNmY4NmMxYTk3YTYwNmUiLCJncm91cCI6IlNjaWVuY2UiLCJsZXZlbCI6IkhTQyAyMDI2IiwiaWF0IjoxNzYzMzExMjY2LCJleHAiOjE3OTQ4Njg4NjZ9.eQH24yeS4hnar1mK-0Zwv2UddCoC1Tog9tOaemL-wuM';

  @override
  void initState() {
    super.initState();
    fetchMcqs();
  }

  Future<void> fetchMcqs() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _dio.get(
        '/api/mcq',
        queryParameters: {
          'topic': '659bba2c4d86e9250304ab2c',
          'limit': 100,
          'offset': 0,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        setState(() => mcqs = response.data['mcqs'] ?? []);
      } else {
        setState(() => errorMessage = 'Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      setState(() => errorMessage = e.response?.data.toString() ?? e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// Clean HTML and separate math from text
  List<String> splitMathAndText(String html) {
    final unescape = HtmlUnescape();
    String s = unescape.convert(html);
    s = s.replaceAll(RegExp(r'<[^>]*>'), ''); // remove HTML tags
    // Split at each $...$ (math) block
    final parts = <String>[];
    final regex = RegExp(r'\$(.*?)\$');
    int lastIndex = 0;

    for (final match in regex.allMatches(s)) {
      if (match.start > lastIndex) {
        parts.add(s.substring(lastIndex, match.start)); // text
      }
      parts.add('\$${match.group(1)}\$'); // math
      lastIndex = match.end;
    }

    if (lastIndex < s.length) {
      parts.add(s.substring(lastIndex)); // remaining text
    }

    return parts.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MCQ Loader')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: mcqs.length,
                  itemBuilder: (_, i) {
                    final item = mcqs[i];
                    final parts = splitMathAndText(item['question']);
                    print("math : ${mcqs.length}");
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: parts.map((part) {
                            if (part.startsWith(r'$') && part.endsWith(r'$')) {
                              // math part
                              final mathContent = part.substring(
                                1,
                                part.length - 1,
                              );
                              return Math.tex(
                                mathContent,
                                mathStyle: MathStyle.display,
                                textStyle: const TextStyle(fontSize: 18),
                              );
                            } else {
                              // regular text part
                              return Text(
                                part,
                                style: const TextStyle(fontSize: 18),
                              );
                            }
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchMcqs,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
