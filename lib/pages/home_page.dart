import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/components/my_list_tile.dart';
import 'package:flutter_expense_tracker/database/expense_database.dart';
import 'package:flutter_expense_tracker/helper/helper_functions.dart';
import 'package:flutter_expense_tracker/models/expense.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text editing controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  // open new expense box
  void openNewExpenseBox() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input for expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Expense Name",
              ),
            ),
            // user input for expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: "Expense Amount",
              ),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _createNewExpenseButton()
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    // pre-fill existing values into textfields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // user input for expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Expense Name",
                hintText: existingName,
              ),
            ),
            // user input for expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Expense Amount",
                hintText: existingAmount,
              ),
            ),
          ],
        ),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _editExpenseButton(expense)
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense?"),
        actions: [
          // cancel button
          _cancelButton(),
          // save button
          _deleteExpenseButton(expense.id)
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: Icon(Icons.add),
        ),
        body: ListView.builder(
          itemCount: value.allExpense.length,
          itemBuilder: (context, index) {
            // get individual expense
            Expense individualExpense = value.allExpense[index];
            // return list tile UI
            return MyListTile(
              title: individualExpense.name,
              trailing: formatAmount(individualExpense.amount),
              onEditPressed: (context) => openEditBox(individualExpense),
              onDeletePressed: (context) => openDeleteBox(individualExpense),
            );
          },
        ),
      ),
    );
  }

  // CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // pop the box
        Navigator.pop(context);
        // clear the controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text("Cancel"),
    );
  }

  // SAVE BUTTON -> create new expense
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        // only gonna save if there is some text
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          // pop the box
          Navigator.pop(context);
          // create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );
          // save to the database
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          // clear the controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text("Save"),
    );
  }

  // SAVE BUTTON -> edit existing expense
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        // save as long as there is some change in textfields
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          // pop the box
          Navigator.pop(context);
          // create a new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringToDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          // old expense id
          int existingId = expense.id;

          // save to database
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingId, updatedExpense);
        }
      },
      child: const Text("Save"),
    );
  }

  // DELETE BUTTON
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
      onPressed: () async {
        // pop the box
        Navigator.pop(context);
        // delete the expense from database
        await context.read<ExpenseDatabase>().deleteExpense(id);
      },
      child: const Text("Delete"),
    );
  }
}
