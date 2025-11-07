import 'package:flutter/material.dart';
import 'package:flutter_expense_tracker/models/expense.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class ExpenseDatabase extends ChangeNotifier {
  static late Isar isar;
  List<Expense> _allExpenses = [];

  /*
  SETUP 
  */

  // initialize database
  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ExpenseSchema], directory: dir.path);
  }

  /*
  GETTERS 
  */

  List<Expense> get allExpense => _allExpenses;

  /*
  OPERATIONS 
  */

  // create
  Future<void> createNewExpense(Expense newExpense) async {
    // add to db
    await isar.writeTxn(() => isar.expenses.put(newExpense));
    // re-read from db
    await readExpenses();
  }

  // read
  Future<void> readExpenses() async {
    // get all expenses from db
    List<Expense> fetchedExpenses = await isar.expenses.where().findAll();

    // give it to local expense list
    _allExpenses.clear();
    _allExpenses.addAll(fetchedExpenses);

    // update the listeners / ui
    notifyListeners();
  }

  // update
  Future<void> updateExpense(int id, Expense updatedExpense) async {
    // make sure the new expense has the same id as the existing one
    updatedExpense.id = id;
    // update in the database
    await isar.writeTxn(() => isar.expenses.put(updatedExpense));
    // re-read from database
    await readExpenses();
  }

  // delete
  Future<void> deleteExpense(int id) async {
    // delete from database
    await isar.writeTxn(() => isar.expenses.delete(id));
    // re-read from database
    await readExpenses();
  }

  /*
  HELPERS 
  */
}
