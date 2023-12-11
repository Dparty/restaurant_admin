import 'package:flutter/material.dart';
import 'package:restaurant_admin/api/config.dart';

import 'package:restaurant_admin/models/cart_item.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;
import 'package:restaurant_admin/models/model.dart';

import 'package:provider/provider.dart';

// CartCard for current bill review
class CartCardForBill extends StatelessWidget {
  const CartCardForBill(
      {Key? key,
      required this.item,
      required this.specification,
      this.onDelete})
      : super(key: key);

  final model.Item item;
  final Iterable<Pair> specification;
  final Function? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    // width: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.name!,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                        ),
                        Row(
                          children: [
                            ...specification.map((e) => Text(
                                  "${e.left}: ${e.right}; ",
                                ))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    // width: 100,
                    child: Text("價格：\$${item.pricing / 100}"),
                  )
                ],
              ),
            ),
          ),
          onDelete != null
              ? SizedBox(
                  height: 30,
                  width: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC88D67),
                      elevation: 0,
                    ),
                    onPressed: () {
                      onDelete!();
                    },
                    child: const Text("删除"),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
