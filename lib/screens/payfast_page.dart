import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/constants.dart';
import 'payment_status_screen.dart';

class PayFastWebView extends StatefulWidget {
  final Map<String, String> formData;
  const PayFastWebView({super.key,required this.formData });
  static const id = 'payFastWebView';

  @override
  State<PayFastWebView> createState() => _PayFastWebViewState();
}

class _PayFastWebViewState extends State<PayFastWebView> {

  bool isLoading = true;
  String pageStatusMessage = 'please wait...';
  late final WebViewController _controller;

  // final  _controller =WebViewController()
  //   ..setJavaScriptMode(JavaScriptMode.unrestricted)
  //   ..setNavigationDelegate(
  //     NavigationDelegate(
  //       onProgress: (int progress) {
  //         // Update loading bar.
  //       },
  //       onPageStarted: (String url) {},
  //       onPageFinished: (String url) {},
  //       onHttpError: (HttpResponseError error) {},
  //       onWebResourceError: (WebResourceError error) {},
  //       onNavigationRequest: (NavigationRequest request) {
  //         if (request.url.startsWith('https://www.youtube.com/')) {
  //           return NavigationDecision.prevent;
  //         }
  //         return NavigationDecision.navigate;
  //       },
  //     ),
  //   )
  //   ..loadRequest(Uri.parse('https://flutter.dev'));

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          setState(() => isLoading = false);
        },
        onWebResourceError: (WebResourceError error) {
          setState(() => pageStatusMessage = 'Error loading page');
        },
        onNavigationRequest: (NavigationRequest request) {
          // ✅ Detect PayFast redirects for success/cancel
          if (request.url.contains('success')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PaymentStatusScreen(success: true)),
            );
            return NavigationDecision.prevent;
          } else if (request.url.contains('cancel')) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const PaymentStatusScreen(success: false)),
            );
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));

    _loadPayFastForm();
  }

  void _loadPayFastForm() {
    final buffer = StringBuffer();
    buffer.writeln("<html><body onload='document.forms[0].submit()'>");
    buffer.writeln("<form id='payfastForm' action='https://sandbox.payfast.co.za/eng/process' method='post'>");

    widget.formData.forEach((key, value) {
      buffer.writeln("<input type='hidden' name='$key' value='$value' />");
    });

    buffer.writeln("</form></body></html>");

    final htmlContent = buffer.toString();
    final encodedHtml = base64Encode(const Utf8Encoder().convert(htmlContent));

    _controller.loadRequest(
      Uri.dataFromString(
        htmlContent,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Process Payment', style: TextStyle(fontSize: 16, color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Constants.primaryColor,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}