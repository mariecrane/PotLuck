import 'package:flutter/material.dart';
import 'package:pot_luck/controller/search.dart';
import 'package:pot_luck/model/recipe.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipePage extends StatelessWidget {
  final SearchResult result;

  RecipePage(this.result);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: true,
        title: Text(result.recipeName, style: TextStyle(color: Colors.white, fontFamily: 'MontserratScript')),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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

          RecipeInfo data = snapshot.data;
          // Now we can show our data
          String ingredient_list = "";
          int n = 0;
          data.ingredients.forEach((ingredient) {
            n++;
            ingredient_list = ingredient_list +
                " " +
                n.toString() +
                ". " +
                ingredient.name +
                "\n";
          });
          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                Card(
                  elevation: 0.0,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.network(
                    data.imageUrl,
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: EdgeInsets.all(10),
                ),
                Card(
                  elevation: 0.0,
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Container(
                      child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 10.0),
                          title: Text('Ingredients:',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'MontserratScript')),
                          subtitle: Text(ingredient_list, style: TextStyle(fontFamily: 'MontserratScript')))),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  margin: EdgeInsets.all(10),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: RaisedButton(
                    elevation: 0.0,
                    onPressed: () {
                      launch(data.sourceUrl);
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                        side: BorderSide(color: Theme.of(context).primaryColor)),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                    child: const Text(
                      'Visit the Webpage',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'MontserratScript'),
                    ),
                  ),
                ),
                ListTile(
                  title: Center(
                      child: Text('@ 2019 ' + data.creditsText,
                          style: TextStyle(fontSize: 10, color: Colors.grey))),
                ),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
