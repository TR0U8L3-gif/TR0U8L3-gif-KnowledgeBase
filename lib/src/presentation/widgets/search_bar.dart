import 'package:flutter/material.dart';
import 'package:knowledge_base/src/domain/state/app_state.dart';
import 'package:provider/provider.dart';

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Search...',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          Provider.of<AppState>(context, listen: false).setSearchQuery(value);
        },
      ),
    );
  }
}
