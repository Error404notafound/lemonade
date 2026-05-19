import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA8l1HEX06pz732OkS0ao79RU9wpsUjRuE",
        appId: "1:763178048678:android:5702a131240233a18ee867",
        messagingSenderId: "763178048678",
        projectId: "lemonade-aa1f0",
        storageBucket: "lemonade-aa1f0.firebasestorage.app",
      ),
    );
  } catch (e) {
    // Evita crash caso o Firebase inicialize duas vezes durante hot reload
  }

  InAppWebViewController.setWebContentsDebuggingEnabled(true);
  runApp(const LemonadeApp());
}

class LemonadeApp extends StatelessWidget {
  const LemonadeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff121212),
        appBarTheme: const AppBarTheme(backgroundColor: const Color(0xff1f1f1f)),
      ),
      home: const BrowserScreen(),
    );
  }
}

class TabModel {
  String url;
  String title;
  bool isIncognito;
  InAppWebViewController? controller;

  TabModel({required this.url, this.title = "Nova Guia", this.isIncognito = false});
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  List<TabModel> tabs = [TabModel(url: "https://google.com")];
  int currentTabIndex = 0;
  final TextEditingController urlController = TextEditingController();

  TabModel get currentTab => tabs[currentTabIndex];

  void _addNewTab({bool isIncognito = false}) {
    setState(() {
      tabs.add(TabModel(url: "https://google.com", isIncognito: isIncognito));
      currentTabIndex = tabs.length - 1;
      urlController.text = currentTab.url;
    });
  }

  void _closeTab(int index) {
    if (tabs.length == 1) return;
    setState(() {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      }
      urlController.text = currentTab.url;
    });
  }

  void _injectDevTools() {
    currentTab.controller?.evaluateJavascript(source: """
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

  bool _isSiteSecure(String url) {
    return url.startsWith("https://");
  }

  void _showKebabMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff252525),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Linha Superior de Ações Rápidas
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        Navigator.pop(context);
                        currentTab.controller?.reload();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_alt),
                      tooltip: "Salvar Página",
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: const Icon(Icons.code),
                      tooltip: "DevTools",
                      onPressed: () {
                        Navigator.pop(context);
                        _injectDevTools();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white24),
              // Lista de Opções Principais
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text("Nova guia"),
                onTap: () {
                  Navigator.pop(context);
                  _addNewTab();
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off, color: Colors.purpleAccent),
                title: const Text("Modo anônimo"),
                onTap: () {
                  Navigator.pop(context);
                  _addNewTab(isIncognito: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.group_work_outlined),
                title: const Text("Incluir no novo grupo"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text("Downloads"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text("Favoritos"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text("Histórico"),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text("Tradutor"),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Column(
          children: [
            // 1. Barra Estilo Desktop para Controle das Abas Múltiplas
            SafeArea(
              child: Container(
                height: 45,
                color: const Color(0xff181818),
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: tabs.length,
                        itemBuilder: (context, index) {
                          bool isSelected = index == currentTabIndex;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                currentTabIndex = index;
                                urlController.text = currentTab.url;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 4, top: 6, right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? (tabs[index].isIncognito ? const Color(0xff3a3a3a) : const Color(0xff1f1f1f))
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    tabs[index].isIncognito ? Icons.visibility_off : Icons.public,
                                    size: 14, 
                                    color: tabs[index].isIncognito ? Colors.purpleAccent : Colors.white60
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    constraints: const BoxConstraints(maxWidth: 80),
                                    child: Text(
                                      tabs[index].title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected ? Colors.white : Colors.white60,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _closeTab(index),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white38),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Ícone outline de "+" para adicionar nova aba ao lado das existentes
                    IconButton(
                      icon: const Icon(Icons.add_outlined, color: Colors.white70),
                      onPressed: () => _addNewTab(),
                    ),
                  ],
                ),
              ),
            ),
            // 2. Barra de Endereços Principal e Controles Globais
            Container(
              height: 55,
              color: const Color(0xff1f1f1f),
              child: Row(
                children: [
                  // Ícone outline de Casa (Resetar Página)
                  IconButton(
                    icon: const Icon(Icons.home_outlined),
                    onPressed: () {
                      final homeUri = WebUri("https://google.com");
                      currentTab.controller?.loadUrl(urlRequest: URLRequest(url: homeUri));
                    },
                  ),
                  Expanded(
                    child: Container(
                      height: 38,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xff2d2d2d),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          // Cadeado indicador de segurança SSL
                          Icon(
                            _isSiteSecure(urlController.text) ? Icons.lock : Icons.lock_open,
                            size: 16,
                            color: _isSiteSecure(urlController.text) ? Colors.green : Colors.redAccent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: urlController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration(
                                hintText: "Digite a URL ou pesquise...",
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onSubmitted: (value) {
                                String trimmed = value.trim();
                                if (trimmed.isEmpty) return;

                                WebUri url;
                                if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
                                  url = WebUri(trimmed);
                                } else if (trimmed.contains(".") && !trimmed.contains(" ")) {
                                  url = WebUri("https://$trimmed");
                                } else {
                                  url = WebUri("https://google.com{Uri.encodeComponent(trimmed)}");
                                }
                                currentTab.controller?.loadUrl(urlRequest: URLRequest(url: url));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Menu Kebab (Três Pontinhos)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _showKebabMenu,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 3. Área de Renderização da Aba Ativa com IndexedStack para preservar estado
      body: IndexedStack(
        index: currentTabIndex,
        children: tabs.map((tab) {
          return InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(tab.url)),
            onWebViewCreated: (controller) {
              tab.controller = controller;
            },
            initialSettings: InAppWebViewSettings(
              allowUniversalAccessFromFileURLs: true,
              allowFileAccessFromFileURLs: true,
              mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              // Força o User Agent para Versão Desktop se desejado globalmente
              preferredContentMode: UserPreferredContentMode.RECOMMENDED,
              // Configuração para isolamento total do Modo Anônimo
              incognito: tab.isIncognito,
            ),
            onReceivedServerTrustAuthRequest: (controller, challenge) async {
              return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
            },
            onTitleChanged: (controller, title) {
              if (title != null) {
                setState(() => tab.title = title);
              }
            },
            onLoadStop: (controller, url) {
              if (url != null) {
                setState(() {
                  tab.url = url.toString();
                  if (tabs[currentTabIndex] == tab) {
                    urlController.text = url.toString();
                  }
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }
}
