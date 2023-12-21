import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_admin/components/dialog.dart';

import '../../configs/constants.dart';
import '../../models/restaurant.dart';
import 'formatter.dart';

class AddAttributePage extends StatefulWidget {
  AddAttributePage({super.key, this.attribute});

  Attribute? attribute;

  @override
  State<StatefulWidget> createState() => _AddAttributePageState();
}

class _AddAttributePageState extends State<AddAttributePage> {
  final attributeLabel = TextEditingController();
  TextEditingController label = TextEditingController();
  List<OptionEditList> options = [OptionEditList('', '')];

  @override
  void initState() {
    super.initState();
    if (widget.attribute == null) {
      options = [OptionEditList('', '')];
    } else {
      setState(() {
        options = widget.attribute!.options
            .map((e) => OptionEditList(e.label, (e.extra / 100).toString()))
            .toList();
        label = TextEditingController(text: widget.attribute!.label);
      });
    }
  }

  void addOption() {
    setState(() {
      options.add(OptionEditList('', ''));
    });
  }

  void deleteOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  void submit() {
    var optionSet = <String>{};
    if (label.text.isEmpty) {
      setState(() {
        showAlertDialog(context, '請輸入屬性名');
      });
      return;
    }
    if (options.isEmpty) {
      setState(() {
        showAlertDialog(context, '不能沒有選項');
      });
      return;
    }
    for (var i = 0; i < options.length; i++) {
      String text = options[i].label!.text;
      if (text.isEmpty) {
        setState(() {
          showAlertDialog(context, "第${i + 1}個選項為空");
        });
        return;
      }
      if (optionSet.contains(text)) {
        setState(() {
          showAlertDialog(context, '有重複的選項');
        });
        return;
      }
      optionSet.add(options[i].label!.text);
    }

    Navigator.pop(
        context,
        Attribute(
            label: label.text,
            options: options
                .map((o) => Option(
                    label: o.label!.text,
                    extra: o.pricing!.text.isNotEmpty
                        ? (double.parse(o.pricing!.text) * 100).toInt()
                        : 0))
                .toList()));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height - 200;
    var width = MediaQuery.of(context).size.width - 800;
    return AlertDialog(
      title: const Text('新增屬性'),
      content: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '輸入屬名',
                        ),
                        controller: label,
                      ),
                    ),
                    ...options
                        .map(
                          (o) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Row(children: [
                              Expanded(
                                  child: TextField(
                                decoration: const InputDecoration(
                                  hintText: '選項標籤',
                                ),
                                controller: o.label,
                              )),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: '額外價錢',
                                  ),
                                  inputFormatters: [
                                    XNumberTextInputFormatter(
                                        maxIntegerLength: 100,
                                        maxDecimalLength: 2,
                                        isAllowDecimal: true),
                                  ],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  controller: o.pricing,
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    deleteOption(options.indexOf(o)),
                                child: const Text('刪除'),
                              )
                            ]),
                          ),
                        )
                        .toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor, // Background color
                        ),
                        onPressed: addOption,
                        child: const Text('增加選項'),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          )),
      actions: <Widget>[
        MaterialButton(
          textColor: kPrimaryColor,
          child: const Text('取消'),
          onPressed: () {
            setState(() {
              // _confirmName.text = "";
              Navigator.pop(context);
            });
          },
        ),
        MaterialButton(
          color: kPrimaryColor,
          textColor: Colors.white,
          onPressed: submit,
          child: const Text('確認'),
        ),
      ],
    );
  }
}

class OptionEditList {
  TextEditingController? label;
  TextEditingController? pricing;

  OptionEditList(String? label, String? pricing) {
    this.label = TextEditingController(text: label ?? '');
    this.pricing = TextEditingController(text: pricing ?? '');
  }
}
