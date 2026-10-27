import 'package:flutter/material.dart';
import 'package:sadqah_jariyah_app/utils/constants/app_colors.dart';
import 'package:sadqah_jariyah_app/utils/theme/app_palette.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  static final Uri _privacyUrl = Uri.parse(
    'https://sites.google.com/view/mutqen-privacy/',
  );

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _hasError = true;
          }),
        ),
      )
      ..loadRequest(_privacyUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.whiteColor,
      backgroundColor: context.palette.topBar,
      appBar: AppBar(
        // backgroundColor: AppColors.primaryColor,
        backgroundColor: context.palette.topBar,
        elevation: 0,
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.whiteColor),
      ),
      body: Stack(
        children: [
          if (_hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'تعذّر تحميل سياسة الخصوصية',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _controller.reload(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading && !_hasError)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
