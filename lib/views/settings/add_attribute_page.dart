import 'package:flutter/material.dart';
import 'package:restaurant_admin/components/dialog.dart';

import '../../models/restaurant.dart';

class AddAttributePage extends StatefulWidget {
  const AddAttributePage({super.key});

  @override
  State<StatefulWidget> createState() => _AddAttributePageState();
}

class _AddAttributePageState extends State<AddAttributePage> {
  final attributeLabel = TextEditingController();
  final label = TextEditingController();
  List<OptionEditList> options = [OptionEditList()];

  void addOption() {
    setState(() {
      options.add(OptionEditList());
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
      String text = options[i].label.text;
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
      optionSet.add(options[i].label.text);
    }

    Navigator.pop(
        context,
        Attribute(
            label: label.text,
            options: options
                .map((o) => Option(
                    label: o.label.text,
                    extra: o.pricing.text.isNotEmpty
                        ? (double.parse(o.pricing.text) * 100).toInt()
                        : 0))
                .toList()));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('增加屬性')),
      body: Column(
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
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                hintText: '額外價錢',
                              ),
                              keyboardType: TextInputType.number,
                              controller: o.pricing,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => deleteOption(options.indexOf(o)),
                            child: const Text('刪除'),
                          )
                        ]),
                      ),
                    )
                    .toList(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: addOption,
                    child: const Text('增加選項'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: submit,
                    child: const Text('完成'),
                  ),
                ),
              ],
            ),
          )),
        ],
      ));
}

class OptionEditList {
  final label = TextEditingController();
  final pricing = TextEditingController();
}
