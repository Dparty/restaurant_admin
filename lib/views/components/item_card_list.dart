import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import './item_card.dart';

class ItemCardListView extends StatefulWidget {
  final List<Item>? itemList;
  int crossAxisCount = 3;
  Item? selectedItem;
  Function? onTap;
  String? type = 'order'; // order or config

  ItemCardListView({
    Key? key,
    required this.itemList,
    required this.crossAxisCount,
    this.onTap,
    this.type,
    this.selectedItem,
  }) : super(key: key);

  @override
  State<ItemCardListView> createState() => _ItemCardListViewState();
}

class _ItemCardListViewState extends State<ItemCardListView> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height + 500.0) / 2;
    final double itemWidth = size.width / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: ListView(
        physics: const PageScrollPhysics(),
        children: <Widget>[
          const SizedBox(height: 15.0),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              width: MediaQuery.of(context).size.width - 30.0,
              height: MediaQuery.of(context).size.height - 210.0,
              child: GridView.count(
                  physics: const PageScrollPhysics(),
                  // crossAxisCount: widget.crossAxisCount,
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 1440 ? 4 : 3,
                  // childAspectRatio: (itemWidth / itemHeight),
                  childAspectRatio: 0.95,
                  primary: false,
                  children: [
                    ...widget.itemList!
                        .map((item) => itemCard(context, item, onTap: () {
                              widget.onTap!(item);
                            },
                                type: widget.type,
                                selectedItem: widget.selectedItem))
                        .toList()
                  ])),
          const SizedBox(height: 15.0)
        ],
      ),
    );
  }
}
