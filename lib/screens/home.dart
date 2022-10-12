import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../view_models/budget_view_model.dart';
import '../services/theme_service.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<BottomNavigationBarItem> bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil')
  ];

  List<Widget> pages = const [
    HomePage(),
    ProfilePage(),
  ];

  int _currentePageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rastreador de Orçamento'),
        leading: IconButton(
          onPressed: () {
            themeService.darkTheme = !themeService.darkTheme;
          },
          icon: Icon(themeService.darkTheme ? Icons.sunny : Icons.dark_mode),
        ),
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return BudgetDialog(
                      budgetToAdd: (budget) {
                        final budgetService =
                            Provider.of<BudgetViewModel>(context, listen: false);
                        budgetService.budget = budget;
                      },
                    );
                  },
                );
              },
              icon: const Icon(Icons.attach_money))
        ],
      ),
      body: pages[_currentePageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentePageIndex,
        items: bottomNavItems,
        onTap: (index) {
          setState(
            () {
              _currentePageIndex = index;
            },
          );
        },
      ),
    );
  }
}

class BudgetDialog extends StatefulWidget {
  final Function(double) budgetToAdd;

  const BudgetDialog({Key? key, required this.budgetToAdd}) : super(key: key);

  @override
  State<BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<BudgetDialog> {
  final TextEditingController budgetController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: SizedBox(
            width: MediaQuery.of(context).size.width / 1.3,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Orçamento', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: budgetController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration:
                        const InputDecoration(hintText: 'Insira seu orçamento'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                      onPressed: () {
                        if (budgetController.text.isNotEmpty) {
                          widget
                              .budgetToAdd(double.parse(budgetController.text));
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Adicionar')),
                ],
              ),
            )));
  }
}
