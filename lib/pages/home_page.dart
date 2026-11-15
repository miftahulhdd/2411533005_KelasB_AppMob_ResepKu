import 'package:flutter/material.dart';
import 'package:resepku/data/dummy_recipes.dart';
import 'package:resepku/pages/setting_page.dart';
import 'package:resepku/widgets/favorite_badge_button.dart';
import 'package:resepku/widgets/recipe_grid_card.dart';
import 'package:resepku/widgets/recipe_tile.dart';
import 'package:resepku/models/recipe.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isGrid = false;

  // null berarti "Semua" cuisine
  String? _cuisine;

  // Daftar cuisine diambil dari data (bukan ditulis manual).
  // toSet() membuang duplikat, toList() mengubahnya kembali menjadi list.
  final List<String> _cuisines = dummyRecipes
      .map((r) => r.cuisine)
      .toSet()
      .toList();

  // Data yang sudah difilter sesuai chip yang dipilih
  List<Recipe> get _filteredRecipes {
    if (_cuisine == null) return dummyRecipes;
    return dummyRecipes.where((r) => r.cuisine == _cuisine).toList();
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _filteredRecipes;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 8),
            const Text('ResepKu'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? 'Tampilan list' : 'Tampilan grid',
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          const FavoriteBadgeButton(),
          IconButton(
            tooltip: 'Pengaturan',
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Aturan 1: ListView horizontal di dalam Column wajib diberi tinggi.
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _cuisines.length + 1, // +1 untuk chip "Semua"
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                // index 0 = "Semua" (null), selebihnya = cuisine dari data
                final String? value = index == 0 ? null : _cuisines[index - 1];
                return ChoiceChip(
                  label: Text(value ?? 'Semua'),
                  selected: _cuisine == value,
                  onSelected: (_) => setState(() => _cuisine = value),
                );
              },
            ),
          ),
          // Aturan 2: list/grid yang mengisi sisa layar di dalam Column
          // dibungkus Expanded.
          Expanded(
            child: _isGrid ? _buildGrid(recipes) : _buildList(recipes),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<Recipe> recipes) {
    return ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeTile(recipe: recipes[index]);
      },
    );
  }

  Widget _buildGrid(List<Recipe> recipes) {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 3 / 4,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return RecipeGridCard(recipe: recipes[index]);
      },
    );
  }
}