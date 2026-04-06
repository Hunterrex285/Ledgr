import 'package:ledgr/features/ious/data/repositories/iou_repository.dart';


class DeleteIou {
  final IouRepository repository;
  const DeleteIou(this.repository);

  Future<void> call(String id) => repository.delete(id);
}