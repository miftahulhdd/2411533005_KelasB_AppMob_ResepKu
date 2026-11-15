import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus semua favorit?'),
        content: const Text('Semua resep di daftar favorit akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // setelah await, pastikan halaman masih ada sebelum memakai context
    if (confirmed == true && context.mounted) {
      context.read<FavoriteProvider>().clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
        actions: [
          // Consumer: status tombol ikut berubah saat jumlah favorit berubah
          Consumer<FavoriteProvider>(
            builder: (context, favorite, child) => TextButton.icon(
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Hapus semua'),
              onPressed:
                  favorite.count == 0 ? null : () => _confirmClear(context),
            ),
          ),
        ],
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, favorite, child) {
          if (favorite.count == 0) {
            return const Center(
              child: Text(
                'Belum ada resep favorit.\nTekan ikon hati di daftar resep.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = favorite.items;

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final recipe = items[index];

              return Dismissible(
                // key unik dan stabil: id resep, BUKAN index
                key: ValueKey(recipe.id),
                direction: DismissDirection.endToStart, // hanya geser ke kiri
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  // toggle pada resep yang sudah favorit = menghapusnya
                  favorite.toggle(recipe);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('${recipe.name} dihapus dari favorit'),
                      ),
                    );
                },
                child: ListTile(
                  // tileColor: agar latar merah tidak tembus saat item digeser
                  tileColor: Theme.of(context).colorScheme.surface,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: RecipeImage(url: recipe.image, cacheWidth: 168),
                    ),
                  ),
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}