import 'package:flutter/material.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/components/dynamic_textfield.dart';
import 'package:restaurant_admin/configs/constants.dart';
import 'package:restaurant_admin/models/restaurant.dart';

class CreateRestaurantPage extends StatefulWidget {
  final Restaurant? restaurant;

  const CreateRestaurantPage({super.key, this.restaurant});

  @override
  State<StatefulWidget> createState() => _CreateRestaurantPageState();
}

class _CreateRestaurantPageState extends State<CreateRestaurantPage> {
  TextEditingController? name;
  TextEditingController? description;
  List<TextEditingController>? _listController = [TextEditingController()];
  final TextEditingController _confirmName = TextEditingController();
  String? valueText;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.restaurant?.name);
    description = TextEditingController(text: widget.restaurant?.description);
    _listController = widget.restaurant == null
        ? [TextEditingController()]
        : widget.restaurant?.categories
            .map((e) => TextEditingController(text: e))
            .toList();
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('請輸入完整餐廳名字確認'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _confirmName,
              decoration: const InputDecoration(hintText: "請輸入完整餐廳名字確認"),
            ),
            actions: <Widget>[
              MaterialButton(
                textColor: kPrimaryColor,
                child: const Text('取消'),
                onPressed: () {
                  setState(() {
                    _confirmName.text = "";
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                color: kPrimaryColor,
                textColor: Colors.white,
                child: const Text('確認刪除'),
                onPressed: () {
                  if (valueText == widget.restaurant?.name) {
                    delete();
                  } else {
                    _confirmName.text = "";
                    Navigator.pop(context);
                    showAlertDialog(context, "名稱不一致，無法刪除");
                  }
                },
              ),
            ],
          );
        });
  }

  create() {
    if (name!.text == "") {
      showAlertDialog(context, "請輸入餐廳名稱");
      return;
    }

    List<String> categoryList = _listController!
        .where((element) => element.text != "")
        .map((e) => e.text)
        .toList();

    createRestaurant(name!.text, description!.text, categoryList)
        .then((value) => Navigator.pop(context));
  }

  update() {
    List<String> categoryList = _listController!
        .where((element) => element.text != "")
        .map((e) => e.text)
        .toList();

    updateRestaurant(
            widget.restaurant!.id, name!.text, description!.text, categoryList)
        .then((value) => Navigator.pop(context));
  }

  delete() {
    deleteRestaurant(widget.restaurant!.id).then((value) {
      Navigator.pop(context);
      showAlertDialog(context, "刪除成功",
          onConfirmed: () => Navigator.pop(context));
    });
  }

  List<String> getCategoriesList(String str) {
    String cleanupWhitespace(String input) =>
        input.replaceAll(RegExp(r"\s+"), "");
    var temp = cleanupWhitespace(str).split('r/[\n\s+,，；;]/g');
    return temp.where((String element) => element != '').toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('創建餐廳'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                hintText: '名稱',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '請輸入餐廳名稱';
                }
                return null;
              },
            ),
            TextFormField(
              controller: description,
              decoration: const InputDecoration(
                hintText: '描述',
              ),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return '請輸入描述';
                }
                return null;
              },
            ),
            widget.restaurant != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: 100,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _displayTextInputDialog(context);
                                _confirmName.text = '';
                              },
                              child: const Text('刪除餐廳'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: 100,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: update,
                              child: const Text('提交編輯'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      width: 100,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: create,
                        child: const Text('創建餐廳'),
                      ),
                    ),
                  ),
          ],
        ),
      ));
}
