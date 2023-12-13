import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart' as model;
import '../../../components/dialog.dart';

class PrinterCard extends StatelessWidget {
  PrinterCard({
    Key? key,
    this.onTap,
    required this.printer,
    required this.deletePrinter,
    this.selected,
  }) : super(key: key);

  final model.Printer printer;
  final model.Printer? selected;
  final Function() deletePrinter;
  Function()? onTap;

  @override
  Widget build(BuildContext context) {
    const Map<String, String> printerTypeMap = {'BILL': '帳單', 'KITCHEN': '廚房'};

    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
        child: GestureDetector(
          onTap: onTap,
          child: Card(
            shape: selected?.id == printer.id
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
                          "名稱：${printer.name}",
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        Text("SN編號：${printer.sn}"),
                        const SizedBox(height: 5),
                        Text("打印機類型：${printerTypeMap[printer.type]}"),
                        const SizedBox(height: 10),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showAlertDialog(context, "確認刪除打印機${printer.name}?",
                          onConfirmed: deletePrinter);
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
