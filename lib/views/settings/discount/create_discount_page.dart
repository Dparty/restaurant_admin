import 'package:flutter/material.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/provider/selected_discount_provider.dart';
import '../../../provider/selected_printer_provider.dart';

class CreateDiscountPage extends StatefulWidget {
  final String restaurantId;
  final Function()? reload;
  final bool? automaticallyImplyLeading;

  CreateDiscountPage(
    this.restaurantId, {
    this.reload,
    this.automaticallyImplyLeading,
    super.key,
  });

  @override
  // ignore: no_logic_in_create_state
  State<CreateDiscountPage> createState() =>
      _CreateDiscountPageState(restaurantId);
}

class _CreateDiscountPageState extends State<CreateDiscountPage> {
  final _formKey = GlobalKey<FormState>();
  final String restaurantId;
  Discount? discount;
  TextEditingController? label;
  TextEditingController? offset;
  _CreateDiscountPageState(this.restaurantId);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    discount = context.watch<SelectedDiscountProvider>().selectedDiscount;
    label = TextEditingController(text: discount?.label);
    offset = TextEditingController(text: discount?.offset.toString());
    super.didChangeDependencies();
  }

  void create() {
    createDiscount(restaurantId, label!.text, int.parse(offset!.text))
        .then((value) {
      showAlertDialog(context, "創建成功");
      widget.reload!();
      // Navigator.pop(context);
    });
  }

  void update() {
    // updatePrinter(printer!.id, name!.text, sn!.text, printerType,
    //         description!.text ?? '', printerModel)
    //     .then((value) {
    //   showAlertDialog(context, "更新成功");
    //   widget.reload!();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: discount == null ? const Text('新增折扣') : const Text('編輯折扣'),
        automaticallyImplyLeading: widget.automaticallyImplyLeading ?? true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
              key: _formKey,
              child: Column(children: [
                TextFormField(
                  controller: label,
                  decoration: const InputDecoration(
                    hintText: '名稱',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return '輸入名稱';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: offset,
                  decoration: const InputDecoration(
                    hintText: '折扣',
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return '輸入折扣';
                    }
                    return null;
                  },
                ),
                discount == null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              create();
                            }
                          },
                          child: const Text('創建'),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              update();
                            }
                          },
                          child: const Text('修改'),
                        ),
                      ),
              ]))),
    );
  }
}
