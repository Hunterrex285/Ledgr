import 'package:ledgr/features/ious/data/datasource/iou_local_datasource.dart';

import '../../domain/entities/iou.dart';
import '../models/iou_model.dart';

class IouRepositoryImpl implements IouRepository {
  final IouLocalDataSource localDataSource;
  const IouRepositoryImpl(this.localDataSource);

  @override
  Future<List<Iou>> getAll() async {
    final models = await localDataSource.getAll();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> add(Iou iou) =>
      localDataSource.save(IouModel.fromEntity(iou));

  @override
  Future<void> update(Iou iou) =>
      localDataSource.save(IouModel.fromEntity(iou));

  @override
  Future<void> delete(String id) => localDataSource.delete(id);
}

class IouRepository {
  Future<void> add(Iou iou) async {}

  Future<void> delete(String id) async {}

  Future<void> update(Iou iou) async {}
}