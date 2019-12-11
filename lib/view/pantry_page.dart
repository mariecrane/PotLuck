import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pot_luck/controller/bloc/pantry_bloc.dart';
import 'package:pot_luck/model/pantry.dart';

///@uthors: Preston Locke, Shouayee Vue, Tracy Cai
///pantry_page.dart is the Pantry page that shows a user's current ingredients stored. They are able to add ingredients on this page to their Pnatry.

class PantryPage extends StatelessWidget {
  ///The body of the page
  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          PantryAppBar(),
        ];
      },
      body: BlocBuilder<PantryBloc, PantryState>(
        builder: (context, state) {
          if (state is PantryUpdated) {
            return IngredientsListView(state.pantry);
          }

          if (state is SuggestingIngredients) {
            return _SuggestionListView(state.suggestions);
          }

          if (state is PantrySuggestionsEmpty) {
            return Center(
              child: Text(
                "No ingredients found",
                style: TextStyle(
                    color: Colors.grey, fontFamily: 'MontserratScript'),
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  static Widget buildAppBar(BuildContext context) {
    return null;
  }

  static Widget buildFloatingActionButton(BuildContext context) {
    return null;
  }
}

class PantryAppBar extends StatefulWidget {
  ///Creates the header with the search where users can add new ingredients to th pantry
  @override
  _PantryAppBarState createState() => _PantryAppBarState();
}

class _PantryAppBarState extends State<PantryAppBar> {
  StreamSubscription _bloc;
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _bloc?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _bloc?.cancel();
    _bloc = BlocProvider.of<PantryBloc>(context).listen((state) {
      if (state is PantryUpdated && state.clearInput) {
        _controller.clear();
      }
    });
    return SliverAppBar(
      expandedHeight: 200.0,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: TextField(
            controller: _controller,
            cursorColor: Theme.of(context).primaryColor,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'MontserratScript',
            ),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: InputBorder.none,
              // Shows when TextField is empty
              hintText: "Tap Here to Add Ingredients",
              hintStyle: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'MontserratScript',
              ),
            ),
            onSubmitted: (value) {},
            onChanged: (value) {
              BlocProvider.of<PantryBloc>(context)
                  .add(IngredientBarEdited(value));
            },
          ),
        ),
        background: Image(
          image: AssetImage('assets/images/pantry.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class IngredientsListView extends StatelessWidget {
  ///Creates chips for each ingredient and puts them in a wrap to view
  final Pantry _pantry;

  IngredientsListView(this._pantry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: ListView(
        key: PageStorageKey<String>("pantry_page"),
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Ingredients in Your Pantry",
                  style: TextStyle(
                      fontSize: 24.0, fontFamily: 'MontserratScript')),
            ),
          ),
          Container(
            alignment: Alignment.center,
            child: Wrap(
              runSpacing: 10,
              children: _pantry.ingredients
                  .map<Widget>(
                    (ingredient) => Container(
                      padding: EdgeInsets.all(5),
                      child: InputChip(
                        backgroundColor: Theme.of(context).primaryColor,
                        label: Text(ingredient.name,
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'MontserratScript')),
                        onDeleted: () {
                          BlocProvider.of<PantryBloc>(context)
                              .add(PantryIngredientRemoved(ingredient));
                        },
                        deleteIconColor: Colors.white,
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _SuggestionListView extends StatelessWidget {
  ///This is the suggestion dropdown for the search bar
  final List<PantryIngredient> suggestions;

  const _SuggestionListView(this.suggestions, {Key key}) : super(key: key);

  Widget build(BuildContext context) {
    return ListView.builder(
      key: PageStorageKey<String>("pantry_suggestion_page"),
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int index) {
        var ingredient = suggestions[index];
        return ListTile(
          leading: Icon(Icons.create),
          title: Text(ingredient.name,
              style: TextStyle(fontFamily: 'MontserratScript')),
          trailing: Icon(Icons.add),
          onTap: () {
            BlocProvider.of<PantryBloc>(context)
                .add(PantryIngredientAdded(ingredient));
          },
        );
      },
    );
  }
}
