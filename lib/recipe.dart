import 'package:flutter/material.dart';

class RecipePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        automaticallyImplyLeading: true,
        title: Text("Recipe Title"),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        ),
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.network(
                'https://placeimg.com/640/480/any',
                fit: BoxFit.fill,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              margin: EdgeInsets.all(10),
            ),
            ListTile(
              title: Text('Brief Description of Recipe'),
              subtitle: Text("A description"),
            ),
            ListTile(
              title: Text('Ingredients:'),
              subtitle: Text("A list of ingredients"),
            ),
            ListTile(
              title: Center(child: Text('Interested in this Recipe?')),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: RaisedButton(
                onPressed: () {},
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
      ),
    );
  }
}