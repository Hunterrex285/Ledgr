import 'package:ledgr/features/ious/data/repositories/iou_repository.dart';

import '../entities/iou.dart';

class AddIou {
  final IouRepository repository;
  const AddIou(this.repository);

  Future<void> call(Iou iou) => repository.add(iou);
}