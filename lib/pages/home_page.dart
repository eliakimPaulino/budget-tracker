import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:budget_tracker/model/transaction_item.dart';
import 'package:provider/provider.dart';
import '../view_models/budget_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AddTransactionDialog(
                  itemToAdd: (transactionItem) {
                    final budgetService =
                        Provider.of<BudgetViewModel>(context, listen: false);
                    budgetService.addItem(transactionItem);
                  },
                );
              });
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SizedBox(
            width: screenSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Consumer<BudgetViewModel>(
                    builder: ((context, value, child) {
                      final balance = value.getBalance();
                      final budget = value.getBudget();
                      double percentage = balance / budget;
                      if (percentage < 0) {
                        percentage = 0;
                      } else if (percentage > 1) {
                        percentage = 1;
                      }

                      return CircularPercentIndicator(
                        // radius: screenSize.width / 2,
                        radius: 150.0,
                        animation: true,
                        animationDuration: 500,
                        lineWidth: 10.0,
                        percent: percentage,
                        // percent: .5,
                        backgroundColor: Colors.green.shade300,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                                'R\$ ${balance.toString().split(".")[0]}',
                                // 'R\$ ${value.balance.toString()}',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                )),
                            const Text(
                              'Balanço',
                              style: TextStyle(fontSize: 18),
                            ),
                            Text(
                              'Orçamento: R\$${budget.toString()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        progressColor: Colors.red[900],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Itens',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Consumer<BudgetViewModel>(
                  builder: ((context, value, child) {
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: value.items.length,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return TransactionCard(
                            item: value.items[index],
                          );
                        });
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final TransactionItem item;
  const TransactionCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(children: [
                  const Text("Deletar item?"),
                  const Spacer(),
                  TextButton(
                      onPressed: () {
                        final budgetViewModel = Provider.of<BudgetViewModel>(
                            context,
                            listen: false);
                        budgetViewModel.deleteItem(item);
                        Navigator.pop(context);
                      },
                      child: const Text("Sim")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Não"))
                ]),
              ),
            );
          })),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
        child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    offset: const Offset(0, 25),
                    blurRadius: 50),
              ],
            ),
            padding: const EdgeInsets.all(15.0),
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Text(item.itemTitle, style: const TextStyle(fontSize: 18)),
                const Spacer(),
                Text(
                    (!item.isExpense ? '+ R\$ ' : '- R\$ ') +
                        item.amount.toString(),
                    style: const TextStyle(fontSize: 16))
              ],
            )),
      ),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final Function(TransactionItem) itemToAdd;

  const AddTransactionDialog({
    Key? key,
    required this.itemToAdd,
  }) : super(key: key);

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final TextEditingController itemTitleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool _isExpenseController = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.3,
          height: 300,
          child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(children: [
                const Text('Adicione um gasto ou saldo',
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 15),
                TextField(
                  controller: itemTitleController,
                  decoration: const InputDecoration(hintText: 'Descrição'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType
                      .number, // makes sure the keyboard doesn’t have letters
                  inputFormatters: <TextInputFormatter>[
                    // forces only numbers to be typed
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: const InputDecoration(hintText: 'Valor'),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('É despesa?'),
                      Switch.adaptive(
                          value: _isExpenseController,
                          onChanged: (b) {
                            setState(() {
                              _isExpenseController = b;
                            });
                          })
                    ]),
                const SizedBox(height: 15),
                ElevatedButton(
                    onPressed: () {
                      if (amountController.text.isNotEmpty &&
                          itemTitleController.text.isNotEmpty) {
                        widget.itemToAdd(TransactionItem(
                            amount: double.parse(amountController.text),
                            itemTitle: itemTitleController.text,
                            isExpense: _isExpenseController));
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Adicionar')),
              ]))),
    );
  }
}
