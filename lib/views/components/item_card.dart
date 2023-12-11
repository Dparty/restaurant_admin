import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/api/config.dart';

Widget itemCard(BuildContext context, item, {Function()? onTap, String? type}) {
  return Card(
    margin: const EdgeInsets.all(10.0),
    child: GestureDetector(
      key: Key(item.id),
      onTap: item.status == Status.ACTIVED.name ? onTap : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 18.0 / 13.0,
            child: Image.network(
              item!.images.isEmpty
                  ? ("$defaultImage?imageView2/1/w/268/q/85")
                  : ("${item.images[0]}?imageView2/1/w/268/q/85"),
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 8, left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          color: Color(0xFF575E67), fontSize: 12.0)),
                  Text("\$${(item.pricing / 100).toString()}",
                      style: const TextStyle(
                          color: Color(0xFFCC8053), fontSize: 12.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
