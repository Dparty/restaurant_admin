import 'package:flutter/material.dart';
import '../../components/cart_card.dart';
import '../../components/dialog.dart';
import '../../models/bill.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;
import 'package:restaurant_admin/models/order.dart';

class ShowCurrentBill extends StatefulWidget {
  final Bill orders;
  const ShowCurrentBill({Key? key, required this.orders}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ShowCurrentBillState();
}

class _ShowCurrentBillState extends State<ShowCurrentBill> {
  late List<Order> tmpOrders;
  List<model.Specification> deleted = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      tmpOrders = List.from(widget.orders.orders);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("取餐號：${widget.orders?.pickUpCode}"),
      content: Builder(builder: (context) {
        var height = MediaQuery.of(context).size.height - 200;
        var width = MediaQuery.of(context).size.width - 800;
        return Column(
          children: [
            // Container(
            //   width: 150,
            //   height: 35.0,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(10.0),
            //       color: const Color(0xFFC88D67)),
            //   child: InkWell(
            //     onTap: () async {
            //       showAlertDialog(
            //         context,
            //         "確認修改訂單?",
            //         onConfirmed: () async {
            //           await cancelBillItems(widget.orders.id, deleted)
            //               .then((e) {
            //             Navigator.of(context).pop();
            //             showAlertDialog(context, "訂單已修改");
            //           });
            //         },
            //       );
            //     },
            //     child: const Center(
            //         child: Text(
            //       '提交更改',
            //       style: TextStyle(
            //           fontSize: 14.0,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white),
            //     )),
            //   ),
            // ),
            SizedBox(
              height: height,
              width: width,
              child: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: tmpOrders
                      .asMap()
                      .map((i, element) => MapEntry(
                          i,
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CartCardForBill(
                              item: element.item,
                              specification: element.specification,
                              // onDelete: () {
                              //   tmpOrders.removeAt(i);
                              //   deleted.add(model.Specification(
                              //     itemId: element.item.id,
                              //     options: element.specification.toList(),
                              //   ));
                              //   setState(() {
                              //     tmpOrders = tmpOrders;
                              //     deleted = deleted;
                              //   });
                              // }
                            ),
                          )))
                      .values
                      .toList()),
            )
          ],
        );
      }),
    );
  }
}
