import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/iou.dart';
import '../../domain/usecases/add_iou.dart';
import '../../domain/usecases/delete_iou.dart';
import '../../domain/usecases/update_iou.dart';

final addIouProvider =
    Provider<AddIou>((ref) => throw UnimplementedError());
final deleteIouProvider =
    Provider<DeleteIou>((ref) => throw UnimplementedError());
final updateIouProvider =
    Provider<UpdateIou>((ref) => throw UnimplementedError());

class IouNotifier extends Notifier<List<Iou>> {
  @override
  List<Iou> build() => [];

  Future<void> add({
    required String personName,
    required double amount,
    required IouType type,
    required DateTime date,
    String? note,
  }) async {
    final iou = Iou(
      id: const Uuid().v4(),
      personName: personName,
      amount: amount,
      type: type,
      date: date,
      note: note,
    );
    state = [...state, iou];
    await ref.read(addIouProvider)(iou);
  }

  Future<void> settle(String id) async {
    final iou = state.firstWhere((i) => i.id == id);
    final settled = iou.copyWith(isSettled: true);
    state = state.map((i) => i.id == id ? settled : i).toList();
    await ref.read(updateIouProvider)(settled);
  }

  Future<void> delete(String id) async {
    state = state.where((i) => i.id != id).toList();
    await ref.read(deleteIouProvider)(id);
  }
}

final iouNotifierProvider =
    NotifierProvider<IouNotifier, List<Iou>>(IouNotifier.new);

// Derived — totals for the summary header
final iouSummaryProvider =
    Provider<({double totalLent, double totalBorrowed})>((ref) {
  final ious = ref.watch(iouNotifierProvider);
  final active = ious.where((i) => !i.isSettled);

  final lent = active
      .where((i) => i.type == IouType.lent)
      .fold(0.0, (sum, i) => sum + i.amount);

  final borrowed = active
      .where((i) => i.type == IouType.borrowed)
      .fold(0.0, (sum, i) => sum + i.amount);

  return (totalLent: lent, totalBorrowed: borrowed);
});