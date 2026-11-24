import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';

http.Response _json(Object body, int status) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  group('Recipe.fromJson', () {
    test('rating int 5 dibaca sebagai double 5.0', () {
      final recipe = Recipe.fromJson({
        'id': 1,
        'name': 'Nasi Goreng',
        'rating': 5, // int, bukan 5.0
      });

      expect(recipe.rating, isA<double>());
      expect(recipe.rating, 5.0);
    });

    test('field yang tidak ada diberi nilai bawaan', () {
      final recipe = Recipe.fromJson({'id': 2, 'name': 'Rendang'});

      expect(recipe.cuisine, '-');
      expect(recipe.difficulty, '-');
      expect(recipe.prepTimeMinutes, 0);
      expect(recipe.cookTimeMinutes, 0);
      expect(recipe.servings, 1);
      expect(recipe.caloriesPerServing, 0);
      expect(recipe.rating, 0.0);
      expect(recipe.image, '');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.instructions, isEmpty);
    });
  });

  group('RecipeService.fetchRecipes', () {
    test('mengembalikan List<Recipe> dari respons palsu', () async {
      final client = MockClient((request) async {
        expect(request.url.path, '/recipes');
        expect(request.url.queryParameters['limit'], '2');
        return _json({
          'recipes': [
            {'id': 1, 'name': 'Pizza', 'cuisine': 'Italian', 'rating': 4},
            {'id': 2, 'name': 'Sate', 'cuisine': 'Indonesian', 'rating': 4.5},
          ],
          'total': 2,
          'skip': 0,
          'limit': 2,
        }, 200);
      });
      final service = RecipeService(client: client);

      final recipes = await service.fetchRecipes(limit: 2);

      expect(recipes, hasLength(2));
      expect(recipes.first.name, 'Pizza');
      expect(recipes.first.rating, 4.0);
      expect(recipes.last.cuisine, 'Indonesian');
      service.close();
    });

    test('melempar RecipeServiceException jika status 404', () async {
      final client = MockClient(
        (request) async => _json({'message': 'Not Found'}, 404),
      );
      final service = RecipeService(client: client);

      await expectLater(
        service.fetchRecipes(),
        throwsA(isA<RecipeServiceException>()),
      );
      service.close();
    });
  });
}