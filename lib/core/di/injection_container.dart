import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:ledgr/features/budget/data/datasources/budget_local_datasources.dart';
import 'package:ledgr/features/budget/data/models/budget_model.dart';
import 'package:ledgr/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:ledgr/features/budget/domain/usecases/add_budget.dart';
import 'package:ledgr/features/budget/domain/usecases/delete_budget.dart';
import 'package:ledgr/features/budget/domain/usecases/update_budget.dart';
import 'package:ledgr/features/budget/presentation/providers/budget_provider.dart';
import 'package:ledgr/features/ious/data/datasource/iou_local_datasource.dart';
import 'package:ledgr/features/ious/data/models/iou_model.dart';
import 'package:ledgr/features/ious/data/repositories/iou_repository.dart';
import 'package:ledgr/features/ious/domain/usecases/add_iou.dart';
import 'package:ledgr/features/ious/domain/usecases/delete_iou.dart';
import 'package:ledgr/features/ious/domain/usecases/update_iou.dart';
import 'package:ledgr/features/ious/presentation/provider/iou_provider.dart';
import 'package:ledgr/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:ledgr/features/transactions/data/models/transaction_model.dart';
import 'package:ledgr/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:ledgr/features/transactions/domain/usecases/add_transaction.dart';
import 'package:ledgr/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:ledgr/features/transactions/domain/usecases/update_transaction.dart';
import 'package:ledgr/features/transactions/presentation/providers/transaction_provider.dart';

Future<List<Override>> initDependencies() async {
  // Transactions
  final transactionBox = await Hive.openBox<TransactionModel>('transactions');
  final transactionDatasource = TransactionLocalDataSourceImpl(transactionBox);
  final transactionRepository = TransactionRepositoryImpl(transactionDatasource);

  // Budget
  final budgetBox = await Hive.openBox<BudgetModel>('budgets');
  final budgetDatasource = BudgetLocalDataSourceImpl(budgetBox);
  final budgetRepository = BudgetRepositoryImpl(budgetDatasource);

  // IOU
  final iouBox = await Hive.openBox<IouModel>('ious');
  final iouDatasource = IouLocalDataSourceImpl(iouBox);
  final iouRepository = IouRepositoryImpl(iouDatasource);

  return [
    addTransactionProvider.overrideWithValue(AddTransaction(transactionRepository)),
    deleteTransactionProvider.overrideWithValue(DeleteTransaction(transactionRepository)),
    updateTransactionProvider.overrideWithValue(UpdateTransaction(transactionRepository)),
    addBudgetProvider.overrideWithValue(AddBudget(budgetRepository)),
    deleteBudgetProvider.overrideWithValue(DeleteBudget(budgetRepository)),
    updateBudgetProvider.overrideWithValue(UpdateBudget(budgetRepository)),
    addIouProvider.overrideWithValue(AddIou(iouRepository)),
    deleteIouProvider.overrideWithValue(DeleteIou(iouRepository)),
    updateIouProvider.overrideWithValue(UpdateIou(iouRepository)),
  ];
}