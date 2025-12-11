import '../database/database_helper.dart';
import '../models/wishlist_item.dart';

/// Service layer for Wishlist operations
/// Handles CRUD operations, deposits, and purchase tracking
class WishlistService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Create a new wishlist item
  Future<int> createWishlistItem({
    required String title,
    required double price,
    DateTime? targetDate,
    String? imageUrl,
    int priority = 999,
  }) async {
    final now = DateTime.now().toIso8601String();
    final item = WishlistItem(
      title: title,
      price: price,
      targetDate: targetDate?.toIso8601String(),
      imageUrl: imageUrl,
      priority: priority,
      createdAt: now,
      updatedAt: now,
    );
    return await _db.insertWishlistItem(item);
  }

  /// Get all active (not purchased) wishlist items
  Future<List<WishlistItem>> getActiveItems() async {
    return await _db.getActiveWishlistItems();
  }

  /// Get all wishlist items (including purchased)
  Future<List<WishlistItem>> getAllItems() async {
    return await _db.getAllWishlistItems();
  }

  /// Get a specific wishlist item by ID
  Future<WishlistItem?> getItemById(int id) async {
    return await _db.getWishlistItemById(id);
  }

  /// Deposit money toward a wishlist item
  /// Returns the updated item
  Future<WishlistItem?> depositToItem(int itemId, double amount) async {
    final item = await _db.getWishlistItemById(itemId);
    if (item == null) return null;

    final updatedItem = item.copyWith(
      savedAmount: item.savedAmount + amount,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.updateWishlistItem(updatedItem);
    return updatedItem;
  }

  /// Withdraw money from a wishlist item
  /// Returns the updated item or null if insufficient funds
  Future<WishlistItem?> withdrawFromItem(int itemId, double amount) async {
    final item = await _db.getWishlistItemById(itemId);
    if (item == null || item.savedAmount < amount) return null;

    final updatedItem = item.copyWith(
      savedAmount: item.savedAmount - amount,
      updatedAt: DateTime.now().toIso8601String(),
    );

    await _db.updateWishlistItem(updatedItem);
    return updatedItem;
  }

  /// Mark item as purchased
  Future<bool> markAsPurchased(int itemId) async {
    final item = await _db.getWishlistItemById(itemId);
    if (item == null) return false;

    final updatedItem = item.copyWith(
      isPurchased: true,
      updatedAt: DateTime.now().toIso8601String(),
    );
    final result = await _db.updateWishlistItem(updatedItem);
    return result > 0;
  }

  /// Update wishlist item details
  Future<bool> updateItem(WishlistItem item) async {
    final updatedItem = item.copyWith(
      updatedAt: DateTime.now().toIso8601String(),
    );
    final result = await _db.updateWishlistItem(updatedItem);
    return result > 0;
  }

  /// Permanently delete a wishlist item
  Future<bool> deleteItem(int itemId) async {
    final result = await _db.deleteWishlistItem(itemId);
    return result > 0;
  }

  /// Calculate progress percentage (0.0 - 1.0)
  double getProgressPercent(WishlistItem item) {
    return item.progressPercent;
  }

  /// Get total saved across all active wishlist items
  Future<double> getTotalSaved() async {
    final items = await getActiveItems();
    return items.fold<double>(
      0.0,
      (sum, item) => sum + item.savedAmount,
    );
  }

  /// Get count of purchased items
  Future<int> getPurchasedItemsCount() async {
    final items = await getAllItems();
    return items.where((i) => i.isPurchased).length;
  }

  /// Update priority for multiple items (for reordering)
  Future<bool> updatePriorities(Map<int, int> itemIdToPriority) async {
    for (final entry in itemIdToPriority.entries) {
      final item = await _db.getWishlistItemById(entry.key);
      if (item != null) {
        final updated = item.copyWith(
          priority: entry.value,
          updatedAt: DateTime.now().toIso8601String(),
        );
        await _db.updateWishlistItem(updated);
      }
    }
    return true;
  }
}
