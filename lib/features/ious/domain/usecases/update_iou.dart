import 'package:ledgr/features/ious/data/repositories/iou_repository.dart';

import '../entities/iou.dart';

class UpdateIou {
  final IouRepository repository;
  const UpdateIou(this.repository);

  Future<void> call(Iou iou) => repository.update(iou);
}