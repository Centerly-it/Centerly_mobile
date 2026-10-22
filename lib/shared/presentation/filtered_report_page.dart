import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data/read_page.dart';
import 'report_query.dart';
import '../../core/presentation/paged_read_cubit.dart';
import '../../core/widgets/paged_read_body.dart';
import 'report_filter_controls.dart';

class FilteredReportPage<T, S> extends StatefulWidget {
  const FilteredReportPage({
    required this.title,
    required this.initialDate,
    required this.loader,
    required this.identity,
    required this.item,
    this.items,
    required this.header,
    required this.kinds,
    this.kindKey = 'p_kind',
    this.collectorFilter = false,
    this.embedded = false,
    super.key,
  });
  final String title, kindKey;
  final DateTime initialDate;
  final Map<String?, String> kinds;
  final bool collectorFilter, embedded;
  final PageLoader<T, S> loader;
  final String Function(T) identity;
  final Widget Function(BuildContext, T) item;
  final Widget Function(BuildContext, List<T>)? items;
  final Widget Function(BuildContext, ReadPage<T, S>) header;
  @override
  State<FilteredReportPage<T, S>> createState() =>
      _FilteredReportPageState<T, S>();
}

class _FilteredReportPageState<T, S> extends State<FilteredReportPage<T, S>> {
  late final query = ReportQuery(widget.initialDate, widget.kinds.keys.first);
  late final cubit = PagedReadCubit<T, S>(widget.loader, widget.identity);
  void reload() =>
      cubit.apply(query.params(widget.kindKey, widget.collectorFilter));
  @override
  void initState() {
    super.initState();
    reload();
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocProvider.value(
    value: cubit,
    child: Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(widget.title.tr())),
      body: SafeArea(
        child: Column(
          children: [
            ReportFilterControls(
              from: query.from,
              to: query.to,
              kinds: widget.kinds,
              selected: query.kind,
              collectorFilter: widget.collectorFilter,
              onDates: (a, b) {
                setState(() {
                  query.from = a;
                  query.to = b;
                });
                reload();
              },
              onKind: (k) {
                setState(() => query.kind = k);
                reload();
              },
              onGroup: (id) {
                query.group = id;
                reload();
              },
              onCollector: (id) {
                query.collector = id;
                reload();
              },
            ),
            Expanded(
              child: PagedReadBody<T, S>(
                item: widget.item,
                items: widget.items,
                header: widget.header,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
