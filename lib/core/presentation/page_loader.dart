import '../data/read_page.dart';

typedef PageLoader<T, S> =
    Future<ReadPage<T, S>> Function(
      Map<String, dynamic> filters,
      String? cursor,
    );
typedef FreshPageLoader<T, S> =
    Future<ReadPage<T, S>> Function(
      Map<String, dynamic> filters,
      String? cursor,
      bool refresh,
    );
