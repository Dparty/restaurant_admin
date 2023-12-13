import 'package:flutter/material.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import '../../../models/restaurant.dart';
import 'printer_card.dart';

class PrintersListView extends StatelessWidget {
  final List printersList;
  final Function()? reload;
  final Function? onTap;
  final Printer? selected;
  const PrintersListView(
      {Key? key,
      required this.printersList,
      this.reload,
      this.onTap,
      this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    void removePrinter(id) {
      deletePrinter(id).then((_) {
        reload!();
        showAlertDialog(context, "刪除打印機成功");
      }).onError((error, stackTrace) {
        showAlertDialog(context, "無法刪除，可能有品項使用此打印機");
      });
    }

    return Container(
      child: ListView(children: [
        ...printersList
            .map(
              (item) => PrinterCard(
                selected: selected,
                printer: item,
                deletePrinter: () => removePrinter(item.id),
                onTap: () => onTap!(item),
              ),
            )
            .toList()
      ]),
    );
  }
}
