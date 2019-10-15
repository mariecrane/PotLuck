import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pot_luck/search.dart';

class RecipePage extends StatelessWidget {
  final SearchResult result;

  RecipePage(this.result);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        automaticallyImplyLeading: true,
        title: Text(result.recipeName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: FutureBuilder<RecipeInfo>(
        future: RecipeSearch.instance.getRecipeInfo(result),
        builder: (context, snapshot) {
          // We have not received our response yet
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          // TODO: Use data variable to fill in live data returned from our API
          RecipeInfo data = snapshot.data;
          // Now we can show our data
          String ingredient_list = "";
          data.ingredients.forEach((ingredient){ingredient_list = ingredient_list + " " + ingredient.name + "\n";});
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.all(10),
                ),
                ListTile(
                  title: Text('Ingredients:'),
                  subtitle: Text(ingredient_list
                ),
                ),
                ListTile(
                  title: Center(child: Text('Interested in this Recipe?')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RaisedButton(
                    onPressed: () {launch(data.sourceUrl);},
                    textColor: Colors.white,
                    color: Colors.red[300],
                    child: const Text(
                      'Click Here To Visit the Webpage',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
