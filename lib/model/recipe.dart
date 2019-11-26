/// Models the available info about a single recipe
class RecipeInfo {
  final int id;
  final String title;
  final String imageUrl;
  final String sourceUrl;
  final String creditsText;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeInfo(
      {this.id,
      this.title,
      this.imageUrl,
      this.sourceUrl,
      this.creditsText,
      this.ingredients,
      this.steps});
}

/// Models a single step of instructions for a single recipe
class RecipeStep {
  final String instructionsText;

  RecipeStep({this.instructionsText});
}

/// Models a single ingredient necessary for a specific recipe, including the
/// amount needed
class RecipeIngredient {
  final int id;
  final String name;
  final double amount;
  final String unit;
  final String imageUrl;

  RecipeIngredient({this.id, this.name, this.amount, this.unit, this.imageUrl});
}

/// Encodes all the data that is returned by our recipe API interface
/// (Can be expanded later)
class SearchResult {
  final int id;
  final String recipeName;
  final int missedIngredientCount;
  final int usedIngredientCount;
  final String missedIngredients;
  final String usedIngredients;
  final String imageUrl;
  final int likes;

  SearchResult(
    this.id, {
    this.recipeName,
    this.missedIngredientCount,
    this.usedIngredientCount,
    this.missedIngredients,
    this.usedIngredients,
    this.imageUrl,
    this.likes,
  });
}
