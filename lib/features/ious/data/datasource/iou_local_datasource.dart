import 'package:hive/hive.dart';
import '../models/iou_model.dart';

abstract class IouLocalDataSource {
  Future<List<IouModel>> getAll();
  Future<void> save(IouModel model);
  Future<void> delete(String id);
}

class IouLocalDataSourceImpl implements IouLocalDataSource {
  final Box<IouModel> box;
  const IouLocalDataSourceImpl(this.box);

  @override
  Future<List<IouModel>> getAll() async => box.values.toList();

  @override
  Future<void> save(IouModel model) => box.put(model.id, model);

  @override
  Future<void> delete(String id) => box.delete(id);
}