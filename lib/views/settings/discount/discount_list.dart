import 'package:flutter/material.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import '../../../models/restaurant.dart';
import 'discount_card.dart';

class DiscountListView extends StatelessWidget {
  final List discountList;
  final Function()? reload;
  final Function? onTap;
  final Discount? selected;

  const DiscountListView(
      {Key? key,
      required this.discountList,
      this.reload,
      this.onTap,
      this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void removeDiscount(id) {
      deleteDiscount(id).then((_) {
        reload!();
        showAlertDialog(context, "刪除折扣成功");
      }).onError((error, stackTrace) {
        showAlertDialog(context, "無法刪除");
      });
    }

    return Container(
      child: ListView(children: [
        ...discountList
            .map(
              (item) => DiscountCard(
                selected: selected,
                discount: item,
                deleteDiscount: () => removeDiscount(item.id),
                onTap: () => onTap!(item),
              ),
            )
            .toList()
      ]),
    );
  }
}
