import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyA8l1HEX06pz732OkS0ao79RU9wpsUjRuE", // Sua chave real inserida aqui!
      appId: "1:763178048678:android:5702a131240233a18ee867",
      messagingSenderId: "763178048678",
      projectId: "lemonade-aa1f0",
      storageBucket: "lemonade-aa1f0.firebasestorage.app",
    ),
  );

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
  Widget build(BuildContext context) {
    return const BrowserView();
  }
}

class BrowserView extends StatefulWidget {
  const BrowserView({super.key});

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  InAppWebViewController? webViewController;
  final TextEditingController urlController = TextEditingController(text: "https://google.com");

  void _injectDevTools() {
    webViewController?.evaluateJavascript(source: """
      (function () {
        if (window.eruda) return;
        var src = '//cdn.jsdelivr.net/npm/eruda';
        var script = document.createElement('script');
        script.src = src;
        document.body.appendChild(script);
        script.onload = function () { eruda.init(); };
      })();
    """);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: urlController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Digite a URL ou pesquise...",
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            String trimmed = value.trim();
            if (trimmed.isEmpty) return;

            WebUri url;
            // Se tiver cara de link (ex: site.com, http://, https://)
            if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
              url = WebUri(trimmed);
            } else if (trimmed.contains(".") && !trimmed.contains(" ")) {
              url = WebUri("https://$trimmed");
            } else {
              // Se for apenas texto, vira uma pesquisa automática no Google
              url = WebUri("https://google.com{Uri.encodeComponent(trimmed)}");
            }
            
            webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: "DevTools",
            onPressed: _injectDevTools,
          ),
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
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadStop: (controller, url) {
          if (url != null) {
            urlController.text = url.toString();
          }
        },
      ),
    );
  }
}
