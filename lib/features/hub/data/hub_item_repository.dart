import '../domain/hub_item.dart';

abstract interface class HubItemRepository {
  Stream<List<HubItem>> watchItems();

  Future<void> createItem(HubItem item);

  Future<void> createItems(List<HubItem> items);

  Future<void> updateItem(HubItem item);

  Future<void> markDone(HubItem item);

  Future<void> deleteItem(String id);
}
