import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';

class PrinterRow extends StatefulWidget {
  int index;
  List<String>? selectedPrinters;
  Function? onSelect;
  Function? onDelete;

  PrinterRow(
      {Key? key,
      required this.index,
      required this.selectedPrinters,
      this.onSelect,
      this.onDelete})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PrinterRow();
}

class _PrinterRow extends State<PrinterRow> {
  @override
  Widget build(BuildContext context) {
    var printers = context.watch<RestaurantProvider>().printers;
    return SizedBox(
        width: 100.0,
        child: Row(children: <Widget>[
          DropdownButton<String>(
            value: widget.selectedPrinters?[widget.index] ?? printers[0].id,
            // : widget.selectedPrinters?[widget.index],
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: (String? value) {
              widget.onSelect!(widget.index, value);
            },
            items: printers.map<DropdownMenuItem<String>>((Printer value) {
              return DropdownMenuItem<String>(
                value: value.id,
                child: Text(value.name),
              );
            }).toList(),
          ),
          GestureDetector(
            onTap: () {
              print(widget.index);
              widget.onDelete!(widget.index);
            },
            child: const Icon(
              Icons.delete,
              // color: kPrimaryColor,
              size: 20,
            ),
          )
        ]));
  }
}
