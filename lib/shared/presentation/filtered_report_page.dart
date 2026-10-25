import '../../core/widgets/content_skeleton.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/data/read_page.dart';
import 'report_query.dart';
import '../../core/presentation/paged_read_cubit.dart';
import '../../core/widgets/paged_read_body.dart';
import 'report_filter_controls.dart';

part 'filtered_report_state.dart';

class FilteredReportPage<T, S> extends StatefulWidget {
  const FilteredReportPage({
    required this.title,
    required this.initialDate,
    required this.loader,
    required this.identity,
    required this.item,
    this.items,
    this.loadingShape = LoadingShape.cards,
    required this.header,
    required this.kinds,
    this.kindKey = 'p_kind',
    this.collectorFilter = false,
    this.embedded = false,
    super.key,
  });
  final LoadingShape loadingShape;
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
