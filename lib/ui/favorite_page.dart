import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:pot_luck/search.dart';
import 'package:pot_luck/ui/recipe_page.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var data = [
      //Replace this with dynamic list of favorite recipes
      {
        "id": 73420,
        "image": "https://spoonacular.com/recipeImages/73420-312x231.jpg",
        "imageType": "jpg",
        "likes": 0,
        "title": "Apple Or Peach Strudel"
      },
      {
        "id": 632660,
        "image": "https://spoonacular.com/recipeImages/632660-312x231.jpg",
        "imageType": "jpg",
        "likes": 3,
        "title": "Apricot Glazed Apple Tart"
      },
      {
        "id": 716429,
        "image": "https://spoonacular.com/recipeImages/716429-312x231.jpg",
        "imageType": "jpg",
        "likes": 18,
        "title": "Pasta with Garlic, Scallions, Cauliflower & Breadcrumbs"
      },
      {
        "id": 715538,
        "image": "https://spoonacular.com/recipeImages/715538-312x231.jpg",
        "imageType": "jpg",
        "likes": 317,
        "title": "Bruschetta Style Pork & Pasta"
      }
    ];

    var unescape = HtmlUnescape();
    var favorites = List<SearchResult>();
    data.forEach((result) {
      favorites.add(SearchResult(
        result["id"],
        recipeName: unescape.convert(result["title"]),
        imageUrl: result["image"],
        likes: result["likes"],
      ));
    });

    return ListView.builder(
      key: PageStorageKey<String>("favorites_page"),
      itemCount: favorites.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return RecipeResult(favorites[index]);
      },
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1.0,
      title: Text(
        "Favorites",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          fontSize: 28,
        ),
      ),
    );
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}

class RecipeResult extends StatelessWidget {
  final SearchResult data;

  RecipeResult(this.data);

  @override
  Widget build(BuildContext context) {
    // A container with rounded corners and a shadow by default
    return Card(
      color: Colors.white,
      elevation: 1.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: InkWell(
        splashColor: Colors.blueGrey[200],
        customBorder:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.0)),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => RecipePage(data)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 20.0,
          ),
          child: SizedBox(
            height: 120.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(20.0),
                      child: Image(
                        image: NetworkImage(data.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //Recipe name and used ingredients
                      Text(
                        data.recipeName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          // TODO: font change
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                      ),
//                              Text(
//                                "Uses: " + data.usedIngredients.toString(),
//                                maxLines: 2,
//                                overflow: TextOverflow.ellipsis,
//                                style: const TextStyle(
//                                  fontSize: 14.0,
//                                  color: Colors.black54,
//                                ),
//                              ),
                      Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomLeft,
                          child: Text(
                            data.likes.toString() + " LIKES",
                            style: const TextStyle(
                              fontSize: 13.0,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
