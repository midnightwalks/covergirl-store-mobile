import 'package:flutter/material.dart';
import 'package:tokomakeup/models/store.dart';


class StoreListPage extends StatelessWidget {
  final List<Store> stores;

  const StoreListPage({super.key, required this.stores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Stores"),
      ),
      body: ListView.separated(
        itemCount: stores.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final store = stores[index];
          return ListTile(
            leading: const Icon(Icons.store, color: Colors.deepPurple),
            title: Text(store.name),
            subtitle: Text(store.address),
          );
        },
      ),
    );
  }
}
