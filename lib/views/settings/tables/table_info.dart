import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

import 'package:restaurant_admin/api/restaurant.dart';
import 'package:restaurant_admin/components/dialog.dart';

// models
import 'package:restaurant_admin/models/restaurant.dart' as model;

// providers
import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/selected_table_provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/api/utils.dart';

import '../../../components/qr_code.dart';

class TableInfoView extends StatefulWidget {
  final model.Table? table;
  final Function()? reload;

  const TableInfoView({Key? key, this.table, this.reload}) : super(key: key);

  @override
  State<TableInfoView> createState() => _TableInfoViewState();
}

class _TableInfoViewState extends State<TableInfoView> {
  TextEditingController? label;
  TextEditingController? x;
  TextEditingController? y;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    label = TextEditingController(text: widget.table?.label.toString());
    super.didChangeDependencies();
  }

  void create(id, label) {
    createTable(id, label).then((table) {
      showAlertDialog(context, "創建成功");
      widget.reload!();
    });
  }

  void update(id, label) {
    updateTable(id, label).then((table) {
      showAlertDialog(context, "更新成功");
      widget.reload!();
    });
  }

  void delete(tableId) {
    deleteTable(tableId).then((_) {
      widget.reload!();
      showAlertDialog(context, "刪除餐桌成功");
    }).onError((error, stackTrace) {
      showAlertDialog(context, "無法刪除餐桌，可能有進行中訂單");
    });
  }

  Future<void> _downloadImage(url) async {
    if (kIsWeb) {
      await WebImageDownloader.downloadImageFromWeb(url);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();
    var table = context.watch<SelectedTableProvider>().selectedTable;
    final formKey = GlobalKey<FormState>();
    String url = '';
    String remoteDownloadUrl = '';

    if (table != null) {
      url = createOrderingUrl(restaurant.id, table.id);
      remoteDownloadUrl = createOrderingUrlRemote(restaurant.id, table.id);
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: table == null ? const Text('新增餐桌') : const Text('編輯餐桌'),
        ),
        body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Form(
                  key: formKey,
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      TextFormField(
                        controller: label,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        decoration: const InputDecoration(
                          hintText: '輸入餐桌標籤',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return '請輸入餐桌標籤';
                          }
                          return null;
                        },
                      ),
                      // TextFormField(
                      //   controller: x,
                      //   autovalidateMode: AutovalidateMode.onUserInteraction,
                      //   decoration: const InputDecoration(
                      //     hintText: '輸入餐桌位置 x',
                      //   ),
                      //   validator: (String? value) {
                      //     if (value == null || value.isEmpty) {
                      //       return '輸入餐桌位置 x';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      // TextFormField(
                      //   controller: y,
                      //   autovalidateMode: AutovalidateMode.onUserInteraction,
                      //   decoration: const InputDecoration(
                      //     hintText: '輸入餐桌位置 y',
                      //   ),
                      //   validator: (String? value) {
                      //     if (value == null || value.isEmpty) {
                      //       return '輸入餐桌位置 y';
                      //     }
                      //     return null;
                      //   },
                      // ),
                      table == null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 100),
                              child: ElevatedButton(
                                onPressed: () {
                                  create(
                                    restaurant.id,
                                    label?.text,
                                  );
                                },
                                child: const Text('創建'),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 40,
                                    width: 160,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFC88D67),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        showAlertDialog(
                                            context, "確認刪除餐桌${table.label}?",
                                            onConfirmed: () =>
                                                delete(table.id));
                                      },
                                      child: const Text("刪除餐桌"),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    width: 160,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFFC88D67),
                                        elevation: 0,
                                      ),
                                      onPressed: () {
                                        if (formKey.currentState!.validate()) {
                                          update(
                                            table.id,
                                            label?.text,
                                          );
                                        }
                                      },
                                      child: const Text("編輯餐桌"),
                                    ),
                                  ),
                                ],
                              )),
                    ],
                  ),
                ),
                table == null
                    ? Container()
                    : Column(
                        children: [
                          Center(
                              child: Column(
                            children: [
                              SizedBox(
                                child: QRCode(
                                  qrSize: 320,
                                  qrData: url,
                                  onPressed: () {
                                    _downloadImage(remoteDownloadUrl);
                                  },
                                ),
                              )
                            ],
                          )),
                        ],
                      )
              ],
            )));
  }
}
