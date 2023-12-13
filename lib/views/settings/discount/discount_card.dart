import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;
import '../../../components/dialog.dart';

class DiscountCard extends StatelessWidget {
  DiscountCard({
    Key? key,
    this.onTap,
    required this.discount,
    this.selected,
    required this.deleteDiscount,
  }) : super(key: key);

  final model.Discount discount;
  final model.Discount? selected;
  final Function() deleteDiscount;
  Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            shape: selected?.id == discount.id
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(
                      color: const Color(0xFFCC8053).withOpacity(0.6),
                      width: 1,
                    ),
                  )
                : RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 20),
                Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "名稱：${discount.label}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Text("折扣：${discount.offset} %"),
                        const SizedBox(height: 5),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showAlertDialog(context,
                          "確認刪除折扣${discount.label}:${discount.offset}?",
                          onConfirmed: deleteDiscount);
                      // deletePrinter();
                    },
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
