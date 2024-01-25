import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:restaurant_admin/api/bill.dart';
import 'package:restaurant_admin/configs/constants.dart';
import 'package:restaurant_admin/models/restaurant.dart';
import 'package:restaurant_admin/views/components/main_layout.dart';

import 'package:provider/provider.dart';
import 'package:restaurant_admin/provider/restaurant_provider.dart';
import 'package:restaurant_admin/provider/selected_table_provider.dart';

import '../../../api/restaurant.dart';
import '../../../api/utils.dart';
import '../../../models/bill.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import '../components/showbill.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// import '../../provider/socket_util.dart';

class OrderManagement extends StatefulWidget {
  final String restaurantId;
  const OrderManagement(this.restaurantId, {super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => _OrderManagementState(restaurantId);
}

class _OrderManagementState extends State<OrderManagement> {
  final String restaurantId;
  Timer? _timeDilationTimer;

  List<Bill>? oldOrders;
  List<String>? oldIdList;

  DateTime? start = DateTime.now();
  DateTime? end = DateTime.now();

  String type = '';

  int total = 0;

  List<SalesData> _dataSource = List.generate(6, (index) => SalesData('0', 0));

  _OrderManagementState(this.restaurantId);
  late TooltipBehavior _tooltipBehavior;
  var _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  var _itemRowsPerPage = PaginatedDataTable.defaultRowsPerPage;

  @override
  void initState() {
    super.initState();
    var now = DateTime.now();
    _tooltipBehavior = TooltipBehavior(enable: true);
    getDataSource();

    listBills(restaurantId,
            startAt: DateTime(now.year, now.month, now.day, 00, 00, 00)
                    .millisecondsSinceEpoch ~/
                1000,
            endAt: DateTime(now.year, now.month, now.day, 23, 59, 59)
                    .millisecondsSinceEpoch ~/
                1000)
        .then((orders) {
      context.read<SelectedTableProvider>().setAllTableOrders(orders);
      setState(() {
        filterItemData = getItemAmount(orders);
        total = orders.map((item) => item.total.truncate()).sum.truncate();
      });
    });
    // getBills();
  }

  void getDataSource() {
    var now = DateTime.now();
    for (int i = 0; i < 6; i++) {
      listBills(restaurantId,
              startAt: DateTime(now.year, now.month - i - 1, now.day)
                      .millisecondsSinceEpoch ~/
                  1000,
              endAt: DateTime(now.year, now.month - i, now.day)
                      .millisecondsSinceEpoch ~/
                  1000)
          .then((orders) {
        setState(() {
          var tmp = (orders.map((item) => item.total.truncate()).sum / 100)
              .truncate();
          _dataSource[5 - i] =
              SalesData('前${(i).toString()}個月', tmp.toDouble());
          // total = orders.map((item) => item.total).sum;
        });
      });
    }
  }

  List<ItemAmountData> getItemAmount(List<Bill> billList) {
    var itemsMap = <String, ItemAmountData>{};

    for (var i = 0; i < billList.length; i++) {
      for (var order in billList[i].orders) {
        var item = order.item;
        if (!itemsMap.containsKey(item.id)) {
          itemsMap[item.id] = ItemAmountData(item, 1);
        } else {
          itemsMap[item.id]?.amount += 1;
        }
      }
    }

    List<ItemAmountData> itemList = [];
    itemsMap.forEach((k, v) => itemList.add(v));
    return itemList;
  }

  void showBill(orders) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShowCurrentBill(orders: orders);
      },
    );
  }

  bool sort = true;
  List<Bill>? filterData;
  List<ItemAmountData>? filterItemData = [];

  onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (sort) {
        filterData!.sort((a, b) => a.id!.compareTo(b.id!));
      } else {
        filterData!.sort((a, b) => b.id!.compareTo(a.id!));
      }
    } else if (columnIndex == 5) {
      if (sort) {
        filterData!.sort((a, b) => a.total!.compareTo(b.total!));
      } else {
        filterData!.sort((a, b) => b.total!.compareTo(a.total!));
      }
    }
  }

  onSortItemColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (sort) {
        filterItemData!.sort((a, b) => a.info.id!.compareTo(b.info.id!));
      } else {
        filterItemData!.sort((a, b) => b.info.id!.compareTo(a.info.id!));
      }
    } else if (columnIndex == 5) {
      if (sort) {
        filterItemData!.sort((a, b) => a.amount!.compareTo(b.amount!));
      } else {
        filterItemData!.sort((a, b) => b.amount!.compareTo(a.amount!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = context.watch<RestaurantProvider>();
    final tableProvider = context.watch<SelectedTableProvider>();
    List<Bill>? orders = tableProvider.tableOrders;
    filterData = orders;

    void updateOrders() {
      if (start == null || end == null) {}
      listBills(restaurantId,
              startAt: start!.millisecondsSinceEpoch ~/ 1000,
              endAt: end!.millisecondsSinceEpoch ~/ 1000,
              status: type)
          .then((orders) {
        context.read<SelectedTableProvider>().setAllTableOrders(orders);
        setState(() {
          filterItemData = getItemAmount(orders);
          total = orders
              .map((item) => item.total.truncate())
              .reduce((a, b) => a + b);
        });
      });
    }

    return MainLayout(
        automaticallyImplyLeading: true,
        centerTitle: "訂單列表",
        center: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: PaginatedDataTable(
                      actions: [
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            updateOrders();
                          },
                        ),
                      ], //
                      rowsPerPage: _rowsPerPage,
                      // availableRowsPerPage: [8, 16, 20],
                      // onRowsPerPageChanged: (value) =>
                      //     setState(() => _rowsPerPage = value!),
                      onPageChanged: (int? n) {
                        setState(() {
                          if (n != null) {
                            if (BillData(filterData!, showBill).rowCount - n <
                                _rowsPerPage) {
                              _rowsPerPage =
                                  BillData(filterData!, showBill).rowCount - n;
                            } else {
                              _rowsPerPage =
                                  PaginatedDataTable.defaultRowsPerPage;
                            }
                          } else {
                            _rowsPerPage = 0;
                          }
                        });
                      },
                      sortColumnIndex: 0,
                      sortAscending: sort,
                      source: BillData(filterData!, showBill),
                      // header: const Text('訂單列表'),
                      header: SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            ElevatedButton(
                                onPressed: () async {
                                  DateTimeRange? picked =
                                      await showDateRangePicker(
                                          context: context,
                                          cancelText: '取消',
                                          confirmText: '確認',
                                          saveText: '確認',
                                          firstDate: DateTime(2000),
                                          lastDate: DateTime.now(),
                                          builder: (context, child) {
                                            return Theme(
                                              data: ThemeData.light().copyWith(
                                                colorScheme: ColorScheme.light(
                                                  // primary: MyColors.primary,
                                                  primary: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  onPrimary: Colors.white,
                                                  surface: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                                //.dialogBackgroundColor:Colors.blue[900],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                      maxWidth: 400.0,
                                                      maxHeight: 520.0,
                                                    ),
                                                    child: child,
                                                  )
                                                ],
                                              ),
                                            );
                                          });
                                  if (picked != null) {
                                    setState(() {
                                      start = DateTime(
                                          picked.start.year,
                                          picked.start.month,
                                          picked.start.day,
                                          00,
                                          00,
                                          00);
                                      end = DateTime(
                                          picked.end.year,
                                          picked.end.month,
                                          picked.end.day,
                                          23,
                                          59,
                                          59);
                                    });
                                    updateOrders();
                                  }
                                },
                                child: const Text("選擇日期")),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(DateFormat('yyyy年MM月dd日')
                                    .format(start ?? DateTime.now())
                                    ?.toString() ??
                                "-"),
                            const Text("  -  "),
                            Text(DateFormat('yyyy年MM月dd日')
                                    .format(end ?? DateTime.now())
                                    ?.toString() ??
                                "-"),
                            const SizedBox(
                              width: 50,
                            ),
                            SizedBox(
                              width: 350,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Radio(
                                      value: "",
                                      groupValue: type,
                                      onChanged: (value) {
                                        setState(() {
                                          type = value.toString();
                                          updateOrders();
                                          // listBills(restaurantId).then((orders) {
                                          //   updateOrders(orders);
                                          // });
                                        });
                                      },
                                    ),
                                    const Text(
                                      '全部',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                  ]),
                                  Row(children: [
                                    Radio(
                                      value: "SUBMITTED",
                                      groupValue: type,
                                      onChanged: (value) {
                                        setState(() {
                                          type = value.toString();
                                          updateOrders();
                                        });
                                      },
                                    ),
                                    const Text(
                                      '已提交',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                  ]),
                                  Row(children: [
                                    Radio(
                                      value: "PAIED",
                                      groupValue: type,
                                      onChanged: (value) {
                                        setState(() {
                                          type = value.toString();
                                          updateOrders();
                                        });
                                      },
                                    ),
                                    const Text(
                                      '已完成',
                                      style: TextStyle(fontSize: 17.0),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                            SizedBox(
                              child:
                                  Text("所有訂單總額：\$${(total / 100).truncate()}"),
                            )
                          ],
                        ),
                      ),
                      columns: [
                        DataColumn(
                            label: const Text('訂單ID'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            }),
                        const DataColumn(label: Text('取餐號')),
                        const DataColumn(label: Text('訂單時間')),
                        const DataColumn(label: Text('點餐桌')),
                        const DataColumn(label: Text('訂單狀態')),
                        DataColumn(
                            label: const Text('訂單總額'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            }),
                        DataColumn(
                            label: const Text('服務費'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            }),
                        DataColumn(
                            label: const Text('折扣價'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortColumn(columnIndex, ascending);
                            }),
                        const DataColumn(label: Text('訂單詳情')),
                      ],
                      columnSpacing: 70,
                      horizontalMargin: 10,
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: PaginatedDataTable(
                      actions: [
                        IconButton(
                          iconSize: 24,
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            updateOrders();
                          },
                        ),
                      ],
                      rowsPerPage: _itemRowsPerPage,
                      onPageChanged: (int? n) {
                        /// value of n is the number of rows displayed so far
                        setState(() {
                          if (n != null) {
                            if (ItemData(filterItemData!).rowCount - n <
                                _itemRowsPerPage) {
                              _itemRowsPerPage =
                                  ItemData(filterItemData!).rowCount - n;
                            } else {
                              _itemRowsPerPage =
                                  PaginatedDataTable.defaultRowsPerPage;
                            }
                          } else {
                            _itemRowsPerPage = 0;
                          }
                        });
                      },
                      sortColumnIndex: 0,
                      sortAscending: sort,
                      source: ItemData(filterItemData!),
                      header: const Text('出貨列表'),
                      columns: [
                        DataColumn(
                            label: const Text('ID'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortItemColumn(columnIndex, ascending);
                            }),
                        const DataColumn(label: Text('品項名稱')),
                        const DataColumn(label: Text('打印機')),
                        const DataColumn(label: Text('品項狀態')),
                        const DataColumn(label: Text('品項價格')),
                        DataColumn(
                            label: const Text('出貨量(點擊排序)'),
                            onSort: (columnIndex, ascending) {
                              setState(() {
                                sort = !sort;
                              });
                              onSortItemColumn(columnIndex, ascending);
                            }),
                      ],
                      columnSpacing: 70,
                      horizontalMargin: 10,
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
                Center(
                    child: SfCartesianChart(
                        tooltipBehavior: _tooltipBehavior,
                        primaryXAxis: CategoryAxis(),
                        title: ChartTitle(text: '前三月分析'), //Chart title.
                        legend: Legend(isVisible: true), // Enables the legend.
                        series: <LineSeries<SalesData, String>>[
                      LineSeries<SalesData, String>(
                          name: '總額',
                          enableTooltip: true,
                          dataSource: _dataSource,
                          xValueMapper: (SalesData sales, _) => sales.year,
                          yValueMapper: (SalesData sales, _) => sales.sales,
                          dataLabelSettings: const DataLabelSettings(
                              isVisible: true) // Enables the data label.
                          )
                    ])),
              ],
            ),
          ),
        ));
  }
}

class BillData extends DataTableSource {
  BillData(List<Bill> _data, Function? onClick) {
    this._data = _data;
    this.onClick = onClick;
  }

  late List<Bill> _data;
  Function? onClick;
  Map<String, String> statusMap = {'SUBMITTED': '已提交', 'PAIED': '已完成'};

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index].id.toString())),
      DataCell(Text(_data[index].pickUpCode.toString())),
      DataCell(Text(DateFormat('yyyy-MM-dd, HH:mm')
          .format(DateTime.fromMillisecondsSinceEpoch(
              _data[index].createdAt * 1000))
          .toString())),
      DataCell(Text(_data[index].tableLabel.toString())),
      DataCell(
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _data[index].status == 'SUBMITTED'
                    ? Colors.blue
                    : Colors.yellow,
              ),
              height: 10,
              width: 10,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(statusMap[_data[index].status]!),
          ],
        ),
      ),
      DataCell(Text(
          '\$ ${(_data[index].orders.map((e) => e.item.pricing).sum / 100).truncate().toString()}')),
      DataCell(Text(' ${(_data[index].offset).toString()}%')),
      DataCell(Text('\$ ${(_data[index].total / 100).truncate().toString()}')),
      DataCell(
        SizedBox(
          height: 30,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.white,
              // side: const BorderSide(width: 0, color: Colors.white),
            ),
            onPressed: () {
              onClick!(_data[index]);
            },
            child: const Text(
              "查看",
              style: TextStyle(color: kPrimaryColor),
            ),
          ),
        ),
      )
    ]);
  }
}

class ItemData extends DataTableSource {
  ItemData(List<ItemAmountData> _data) {
    this._data = _data;
  }

  late List<ItemAmountData> _data;
  Function? onClick;
  Map<String, String> statusMap = {'ACTIVED': '正常', 'DEACTIVED': '估空'};

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _data.length;
  @override
  int get selectedRowCount => 0;
  @override
  DataRow getRow(int index) {
    return DataRow(cells: [
      DataCell(Text(_data[index].info.id.toString())),
      DataCell(Text(_data[index].info.name.toString())),
      DataCell(Text(_data[index].info.printers.toString())),
      DataCell(
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _data[index].info.status == 'ACTIVED'
                    ? Colors.blue
                    : Colors.yellow,
              ),
              height: 10,
              width: 10,
            ),
            const SizedBox(
              width: 10,
            ),
            Text(statusMap[_data[index].info.status]!),
          ],
        ),
      ),
      DataCell(Text('\$ ${(_data[index].info.pricing / 100).toString()}')),
      DataCell(Text((_data[index].amount).toString())),
    ]);
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}

class ItemAmountData {
  ItemAmountData(this.info, this.amount);
  final Item info;
  late int amount;
}
