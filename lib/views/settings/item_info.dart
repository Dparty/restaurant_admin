import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_admin/api/config.dart';
import 'package:restaurant_admin/views/settings/add_attribute_page.dart';
import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/components/dialog.dart';
import 'package:restaurant_admin/models/restaurant.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/provider/selected_item_provider.dart';
import '../../configs/constants.dart';
import './printer_row.dart';

class EditItemPage extends StatefulWidget {
  final Item? item;
  final Function()? reload;

  const EditItemPage({Key? key, this.item, this.reload}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  Item? _item;
  TextEditingController? name;
  TextEditingController? pricing;
  TextEditingController? tag;
  TextEditingController? status;
  List<Attribute>? attributes = [];
  List<String>? categories = [];

  bool loading = false;
  List<Printer> printers = [];
  List<String>? printerIds = [];
  String? printerId;

  XFile? image;
  File? imageFile;
  Uint8List webImage = Uint8List(8);
  bool showImage = false;
  String? imgUrl;

  List<String>? _selectedPrinters = [];
  List<PlatformFile>? _paths;

  String _status = "";

  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();
  String? selectedTag = "";

  void _addNewPrinter() {
    setState(() {
      _selectedPrinters ??= [context.read<RestaurantProvider>().printers[0].id];
      _selectedPrinters?.add(context.read<RestaurantProvider>().printers[0].id);
    });
  }

  void _deletePrinter() {
    setState(() {
      _selectedPrinters?.removeLast();
    });
  }

  void _deletePrinterAt(int index) {
    setState(() {
      _selectedPrinters?.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();

    _item = widget.item;
  }

  @override
  void didChangeDependencies() {
    name = TextEditingController(text: widget.item?.name);
    pricing = TextEditingController(
        text: ((widget.item?.pricing ?? 0) / 100).toString());
    tag = TextEditingController(text: widget.item?.tags[0].toString());
    _status = widget.item?.status ?? Status.ACTIVED.name;
    printers = context.read<RestaurantProvider>().printers;
    _item = widget.item;
    // imgUrl = widget.item?.images?.isEmpty? null : widget.item?.images[0];
    _selectedPrinters = widget.item?.printers ?? [];
    attributes = widget.item?.attributes ?? [];

    super.didChangeDependencies();
  }

  Future<bool> validate() async {
    if (loading) return false;
    loading = true;

    if (tag!.text == "") {
      loading = false;
      showAlertDialog(context, "請輸入分類");
      return false;
    }

    if (_selectedPrinters!.isEmpty) {
      loading = false;
      showAlertDialog(context, "請先創建打印機");
      return false;
    }

    if (_paths != null) {
      String res = await ApiClient.uploadFile(
          _item!.id, _paths!.first.bytes!, _paths!.first.name);
      setState(() {
        imgUrl = res;
        _paths = null;
      });
    } else {
      setState(() {
        imgUrl = _item!.images.isEmpty ? '' : _item?.images[0];
      });
    }
    return true;
  }

  void update() async {
    bool isValid = await validate();
    if (isValid == false) return;
    var res = await updateItem(
        _item!.id,
        PutItem(
          printers: _selectedPrinters!,
          tags: [tag!.text],
          name: name!.text,
          pricing: (double.parse(pricing!.text) * 100).toInt(),
          status: _status,
          images: imgUrl?.length == 0 ? [] : [imgUrl],
          attributes: attributes!,
        ));
    if (res != null) {
      showAlertDialog(context, "更新成功");

      widget.reload!();
    }
    loading = false;
  }

  void delete(itemId) {
    deleteItem(itemId).then((_) {
      widget.reload!();
      showAlertDialog(context, "刪除品項成功");
    }).onError((error, stackTrace) {
      showAlertDialog(context, "無法刪除");
    });
  }

  void create() async {
    if (_selectedPrinters!.isEmpty) {
      loading = false;
      showAlertDialog(context, "請先創建打印機");
      return;
    }
    var res = await createItem(
        context.read<RestaurantProvider>().id,
        PutItem(
            printers: _selectedPrinters!,
            tags: [tag!.text],
            name: name!.text,
            pricing: (double.parse(pricing!.text) * 100).toInt(),
            status: _status,
            images: [],
            attributes: attributes!));

    setState(() {
      _item = res;
    });

    update();
  }

  Future<dynamic> _displayAddAttribute(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return const AddAttributePage();
        });
  }

  void _pickFiles() async {
    try {
      var path = (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: false,
        onFileLoading: (FilePickerStatus status) => print(status),
        allowedExtensions: ['png', 'jpg', 'jpeg', 'heic'],
      ))
          ?.files;
      setState(() {
        _paths = path;
      });
    } on PlatformException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    var item = context.watch<SelectedItemProvider>().selectedItem;
    categories = context.read<RestaurantProvider>().categories;

    final _formKey = GlobalKey<FormState>();

    void setSelectPrinter(i, value) {
      setState(() {
        _selectedPrinters?[i] = value;
      });
    }

    List<Widget> _printers = item == null
        ? List.generate(
            _selectedPrinters!.length,
            (int i) => PrinterRow(
                  index: i,
                  selectedPrinters: _selectedPrinters,
                  onSelect: setSelectPrinter,
                  onDelete: _deletePrinterAt,
                ))
        : List.generate(
            item!.printers.length,
            (int i) => PrinterRow(
                  index: i,
                  selectedPrinters: _selectedPrinters,
                  onSelect: setSelectPrinter,
                  onDelete: _deletePrinterAt,
                ));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: item == null ? const Text('新增品項') : const Text('編輯品項'),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                      child: Form(
                key: _formKey,
                child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: [
                      item != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                  ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.delete_outlined,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      showAlertDialog(
                                          context, "確認刪除品項${item.name}?",
                                          onConfirmed: () => delete(item.id));
                                    },
                                    label: const Text(
                                      "刪除該品項",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      fixedSize: const Size(150, 43),
                                    ),
                                  ),
                                ])
                          : const SizedBox(),
                      TextFormField(
                        controller: name,
                        decoration: const InputDecoration(
                          hintText: '輸入品項名稱',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入品項名稱';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        controller: pricing,
                        decoration: const InputDecoration(
                          hintText: '價錢',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入品項價錢';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: tag,
                        focusNode: _focusNode,
                        decoration: const InputDecoration(
                          hintText: '請輸入分類',
                        ),
                        onFieldSubmitted: (String value) {
                          RawAutocomplete.onFieldSubmitted<String>(
                              _autocompleteKey);
                        },
                      ),
                      RawAutocomplete<String>(
                        key: _autocompleteKey,
                        focusNode: _focusNode,
                        textEditingController: tag,
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return categories!.where((String option) {
                            return option
                                .contains(textEditingValue.text.toLowerCase());
                          }).toList();
                        },
                        optionsViewBuilder: (
                          BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options,
                        ) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              child: SizedBox(
                                height: 100,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: options
                                      .map((String option) => GestureDetector(
                                            onTap: () {
                                              onSelected(option);
                                            },
                                            child: ListTile(
                                              title: Text(option),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      // RawAutocomplete<String>(
                      //   key: _autocompleteKey,
                      //   focusNode: _focusNode,
                      //   // textEditingController: tag,
                      //   optionsBuilder: (TextEditingValue textEditingValue) {
                      //     return categories!.where((String option) {
                      //       print(option);
                      //       return option
                      //           .contains(textEditingValue.text.toLowerCase());
                      //     }).toList();
                      //   },
                      //   optionsViewBuilder: (BuildContext context,
                      //       AutocompleteOnSelected<String> onSelected,
                      //       Iterable<String> options) {
                      //     return Align(
                      //       alignment: Alignment.topLeft,
                      //       child: Material(
                      //         elevation: 4.0,
                      //         child: SizedBox(
                      //           height: 200.0,
                      //           child: ListView.builder(
                      //             padding: const EdgeInsets.all(8.0),
                      //             itemCount: options.length,
                      //             itemBuilder:
                      //                 (BuildContext context, int index) {
                      //               final String option =
                      //                   options.elementAt(index);
                      //               return GestureDetector(
                      //                 onTap: () {
                      //                   onSelected(option);
                      //                 },
                      //                 child: ListTile(
                      //                   title: Text(option),
                      //                 ),
                      //               );
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 20,
                          child: Row(
                            children: [
                              const Text('品項狀態:  '),
                              Radio(
                                value: "ACTIVED",
                                groupValue: _status,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _status = value;
                                    });
                                  }
                                },
                              ),
                              const Text('正常 '),
                              Radio(
                                value: "DEACTIVED",
                                groupValue: _status,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _status = value;
                                    });
                                  }
                                },
                              ),
                              const Text('估空 '),
                            ],
                          ),
                        ),
                      ),
                      ...?attributes?.map((a) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text("屬性:${a.label}"),
                              ),
                              ...a.options.map((o) => Expanded(
                                    child: Text("${o.label}:+${o.extra / 100}"),
                                  )),
                              ElevatedButton(
                                onPressed: () =>
                                    setState(() => attributes?.remove(a)),
                                child: const Text('刪除'),
                              )
                            ],
                          ))),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                          ),
                          // onPressed: addAttribute,
                          onPressed: () async {
                            final Attribute? attribute =
                                await _displayAddAttribute(context);
                            setState(() {
                              if (attribute != null) attributes?.add(attribute);
                            });
                          },
                          label: const Text(
                            "增加屬性",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(208, 43),
                          ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Text('打印機：'),
                                ElevatedButton(
                                  onPressed: _addNewPrinter,
                                  child: const Text("添加"),
                                ),
                                // ElevatedButton(
                                //   onPressed: _deletePrinter,
                                //   child: const Icon(Icons.remove),
                                // ),
                              ],
                            ),
                            SizedBox(
                              height: 50.0,
                              // width: 50,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                // scrollDirection: Axis.vertical,

                                child: Row(
                                  children: _printers,
                                ),
                                // children: _printers,
                              ),
                            ),
                          ])),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          onPressed: () => _pickFiles(), //_pickImage()
                          child: const Text('上傳圖片'),
                        ),
                      ),
                      _paths != null
                          ? Padding(
                              padding: const EdgeInsets.all(5),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 150.00,
                                  width: 150.00,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: MemoryImage(
                                              _paths!.first.bytes!))),
                                ),
                              ),
                            )
                          : item != null
                              ? SizedBox(
                                  height: 150,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FadeInImage(
                                      image: NetworkImage(
                                        item.images.isEmpty
                                            ? defaultImage
                                            : item.images[0],
                                      ),
                                      fit: BoxFit.fitHeight,
                                      placeholder: const AssetImage(
                                          "images/default.png"),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                      item != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    update();
                                  }
                                },
                                child: const Text('提交編輯'),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    create();
                                  }
                                },
                                child: const Text('創建'),
                              ),
                            ),
                    ]),
              ))),
            ],
          )),
    );
  }
}
