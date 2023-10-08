import 'package:contacts/pages/all_contacts_page.dart';
import 'package:contacts/pages/loading_page.dart';
import 'package:contacts/pages/new_contact_page.dart';
import 'package:contacts/providers/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Contatos',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 12,
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        home: const MyHomePage(title: 'Contatos'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  void _changePage(int index, ContactProvider contactProvider) {
    setState(() {
      _currentPage = index;
      contactProvider.clearData();
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isLoaded = false;
  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    if (!_isLoaded) {
      ContactProvider contactProvider = Provider.of(context, listen: false);
      await contactProvider.getContacts(context);
      _isLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    ContactProvider contactProvider = Provider.of(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Center(
          child: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 40),
            child: Text(
              "Total: ${contactProvider.contacts.length}",
              style: const TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              const AllContactsPage(),
              NewContactPage(changePage: () => _changePage(0, contactProvider)),
            ],
          ),
          if (contactProvider.isLoadingGetContacts)
            const LoadingPage(message: "Carregando contatos"),
          if (contactProvider.isLoadingDeleteContact)
            const LoadingPage(message: "Excluindo contato"),
          if (contactProvider.isLoadingUpdateContact)
            const LoadingPage(message: "Alterando contato"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: (index) {
          _changePage(index, contactProvider);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list_sharp),
            label: 'Contatos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add_alt_1),
            label: 'Adicionar contato',
          ),
        ],
      ),
    );
  }
}
