import 'package:flutter/material.dart';

class PantryPage extends StatelessWidget {
  @override
  static Widget buildAppBar(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: true,
        title: Padding(
          // Adds some padding around our TextField
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: TextField(
            // Type of "Done" button to show on keyboard
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              border: InputBorder.none,
              // Shows when TextField is empty
              hintText: "Add Ingredients to Pantry...",
            ),
            onSubmitted: (value) {},
            onChanged: (value) {},
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.add, color: Theme
              .of(context)
              .primaryColor),
        ),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            EntryItem(data[index]),
        itemCount: data.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   // TODO: implement build
    return null;
  }

  static Widget buildFloatingActionButton
      (BuildContext context) {
    return null;
  }
}

class Entry {
  Entry(this.title, [this.children = const <Entry>[]]);

  final String title;
  final List<Entry> children;
}

final List<Entry> data = <Entry>[
  Entry(
    'Chapter A',
    <Entry>[
      Entry(
        'Section A0',
        <Entry>[
          Entry('Item A0.1'),
          Entry('Item A0.2'),
          Entry('Item A0.3'),
        ],
      ),
      Entry('Section A1'),
      Entry('Section A2'),
    ],
  ),
  Entry(
    'Chapter B',
    <Entry>[
      Entry('Section B0'),
      Entry('Section B1'),
    ],
  ),
  Entry(
    'Chapter C',
    <Entry>[
      Entry('Section C0'),
      Entry('Section C1'),
      Entry(
        'Section C2',
        <Entry>[
          Entry('Item C2.0'),
          Entry('Item C2.1'),
          Entry('Item C2.2'),
          Entry('Item C2.3'),
        ],
      ),
    ],
  ),
];

class EntryItem extends StatelessWidget {
  const EntryItem(this.entry);

  final Entry entry;

  Widget _buildTiles(Entry root) {
    if (root.children.isEmpty) return ListTile(title: Text(root.title));
    return ExpansionTile(
      key: PageStorageKey<Entry>(root),
      title: Text(root.title),
      children: root.children.map(_buildTiles).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}
