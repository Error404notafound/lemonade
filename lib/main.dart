import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  InAppWebViewController.setWebContentsDebuggingEnabled(true);
  runApp(const LemonadeApp());
}

class LemonadeApp extends StatelessWidget {
  const LemonadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const BrowserScreen(),
    );
  }
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? webViewController;
  final TextEditingController urlController = TextEditingController(text: "https://google.com");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: "Digite a URL ou pesquise...",
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            var url = WebUri(value);
            if (!value.startsWith("http")) {
              url = WebUri("https://google.com/search?q=$value");
            }
            webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => webViewController?.reload(),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://google.com")),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
        initialSettings: InAppWebViewSettings(
          allowUniversalAccessFromFileURLs: true,
          allowFileAccessFromFileURLs: true,
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
        ),
      ),
    );
  }
}
