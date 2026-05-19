import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase Web/Mobile sem precisar do arquivo google-services.json
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "SUA_API_KEY_AQUI", // Encontre no painel do Firebase se necessário
      appId: "1:763178048678:android:5702a131240233a18ee867",
      messagingSenderId: "763178048678",
      projectId: "lemonade-aa1f0",
    ),
  );

  // Ativa a depuração interna do sistema
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

  // Injeta o Console de Desenvolvedor Eruda (Estilo Kiwi Browser)
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
            var url = WebUri(value);
            if (!value.startsWith("http")) {
              url = WebUri("https://google.com");
            }
            webViewController?.loadUrl(urlRequest: URLRequest(url: url));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.code), // Botão para abrir o DevTools na tela
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
          // Abre qualquer site antigo/inseguro sem travar (Estilo Firefox)
          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          javaScriptEnabled: true,
          domStorageEnabled: true,
        ),
        // Ignora erros de SSL expirado ou inválido de sites antigos
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
