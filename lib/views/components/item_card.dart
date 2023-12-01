import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/api/config.dart';

Widget itemCard(BuildContext context, item, {Function()? onTap, String? type}) {
  return Padding(
      padding:
          const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0, right: 5.0),
      child: GestureDetector(
          key: Key(item.id),
          onTap: item.status == Status.ACTIVED.name ? onTap : () => {},
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 3.0,
                        blurRadius: 5.0)
                  ],
                  color: item.status == Status.DEACTIVED.name
                      ? const Color(0xFFFFECDF).withOpacity(0.5)
                      : Colors.white),
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 150,
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image(
                            image: ResizeImage(
                          NetworkImage(
                            item!.images.isEmpty
                                ? ("$defaultImage?imageView2/1/w/268/q/85")
                                : ("${item.images[0]}?imageView2/1/w/268/q/85"),
                          ),
                          width: 268,
                          height: 268,
                        ))),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 20),
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
              ))));
}
