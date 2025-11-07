import 'package:isar/isar.dart';

// this line is needed to generate the isar file
part 'expense.g.dart';
// run the command: dart run build_runner build 
// this command creates this generated file

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  final String name;
  final double amount;
  final DateTime date;

  Expense({required this.name, required this.amount, required this.date});
}
