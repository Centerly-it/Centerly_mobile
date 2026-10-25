part of 'filtered_report_page.dart';

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
                loadingShape: widget.loadingShape,
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
