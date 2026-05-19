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
    // Evita crash caso o Firebase inicialize duas vezes
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
  bool showHomePage; 
  InAppWebViewController? controller;

  TabModel({
    required this.url, 
    this.title = "Lemonade", 
    this.isIncognito = false,
    this.showHomePage = true,
    this.controller,
  });
}

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  List<TabModel> tabs = [TabModel(url: "lemonade://home")];
  int currentTabIndex = 0;
  final TextEditingController urlController = TextEditingController();

  TabModel get currentTab => tabs[currentTabIndex];

  @override
  void initState() {
    super.initState();
    urlController.text = ""; 
  }

  void _addNewTab({bool isIncognito = false}) {
    setState(() {
      tabs.add(TabModel(url: "lemonade://home", isIncognito: isIncognito));
      currentTabIndex = tabs.length - 1;
      urlController.text = "";
    });
  }

  void _closeTab(int index) {
    if (tabs.length == 1) return;
    setState(() {
      tabs.removeAt(index);
      if (currentTabIndex >= tabs.length) {
        currentTabIndex = tabs.length - 1;
      }
      urlController.text = currentTab.showHomePage ? "" : currentTab.url;
    });
  }

  bool _isSiteSecure(String url) {
    return url.startsWith("https://");
  }

  // FUNÇÃO DO MOTOR DE BUSCA BRINDADA CONTRA ERROS DE URL
  void _executarBuscaLemonade(String input) {
    String termo = input.trim();
    if (termo.isEmpty) return;

    String urlFinal = "";

    // Identifica se é um site válido ou se é apenas um texto para pesquisar
    bool isUrl = termo.startsWith("http://") ||
        termo.startsWith("https://") ||
        (termo.contains(".") && !termo.contains(" "));

    if (!isUrl) {
      // Montagem automática oficial do Flutter para a busca privada do DuckDuckGo
      final uriMontada = Uri.https("duckduckgo.com", "/", {"q": termo});
      urlFinal = uriMontada.toString();
    } else {
      if (!termo.startsWith("http://") && !termo.startsWith("https://")) {
        urlFinal = "https://" + termo;
      } else {
        urlFinal = termo;
      }
    }

    setState(() {
      currentTab.url = urlFinal;
      currentTab.showHomePage = false; 
      urlController.text = urlFinal;
    });

    // Envia o link correto montado pelo sistema para a tela do app
    currentTab.controller?.loadUrl(urlRequest: URLRequest(url: WebUri(urlFinal)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Column(
          children: [
            // Gerenciador de Abas do Navegador
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
                                urlController.text = tabs[index].showHomePage ? "" : tabs[index].url;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 4, top: 6, right: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xff1f1f1f) : Colors.transparent,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tabs[index].title.length > 12 ? tabs[index].title.substring(0, 12) + "..." : tabs[index].title,
                                    style: TextStyle(
                                      color: isSelected ? const Color(0xffe2ff88) : Colors.white60,
                                      fontSize: 12,
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
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xffe2ff88)),
                      onPressed: () => _addNewTab(),
                    ),
                  ],
                ),
              ),
            ),
            // Barra de Endereço Superior
            Container(
              height: 55,
              color: const Color(0xff1f1f1f),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    currentTab.showHomePage ? Icons.search : (_isSiteSecure(urlController.text) ? Icons.lock : Icons.lock_open),
                    color: currentTab.showHomePage ? Colors.white38 : (_isSiteSecure(urlController.text) ? Colors.green : Colors.orange),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: "Pesquise de forma privada...",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _executarBuscaLemonade(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // TELA INICIAL DO MOTOR DE BUSCA LEMONADE
      body: IndexedStack(
        index: currentTabIndex,
        children: tabs.map((tab) {
          if (tab.showHomePage) {
            return Container(
              color: const Color(0xff121212),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Ícone Verde Limão Neon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffe2ff88), width: 3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.waves, color: Color(0xffe2ff88), size: 45), 
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "lemonade",
                        style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xffe2ff88)),
                      ),
                      const Text(
                        "Busca privada. Sem rastreamento.",
                        style: TextStyle(fontSize: 14, color: Colors.white38),
                      ),
                      const SizedBox(height: 32),
                      // Barra de Pesquisa Central da Home
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xff1f1f1f),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Pesquise algo...",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              icon: Icon(Icons.search, color: Color(0xffe2ff88)),
                            ),
                            onSubmitted: (value) {
                              _executarBuscaLemonade(value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Tela que mostra as páginas da Web comuns
          return InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(tab.url)),
            onWebViewCreated: (controller) {
              tab.controller = controller;
            },
            onLoadStart: (controller, url) {
              if (url != null) {
                setState(() {
                  tab.url = url.toString();
                  if (tabs[currentTabIndex] == tab) {
                    urlController.text = tab.url;
                  }
                });
              }
            },
            onLoadStop: (controller, url) async {
              if (url != null) {
                String? title = await controller.getTitle();
                setState(() {
                  tab.url = url.toString();
                  tab.title = title ?? "Lemonade";
                  if (tabs[currentTabIndex] == tab) {
                    urlController.text = tab.url;
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
