import '../models/route_models.dart';
import '../models/route_filter_models.dart';

void sortRoutesInPlace(List<Route> routes, SortOption selectedSort) {
  switch (selectedSort) {
    case SortOption.newest:
      routes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case SortOption.oldest:
      routes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      break;
    case SortOption.nameAZ:
      routes.sort((a, b) => a.name.compareTo(b.name));
      break;
    case SortOption.nameZA:
      routes.sort((a, b) => b.name.compareTo(a.name));
      break;
    case SortOption.gradeAsc:
      routes.sort((a, b) => a.gradeId.compareTo(b.gradeId));
      break;
    case SortOption.gradeDesc:
      routes.sort((a, b) => b.gradeId.compareTo(a.gradeId));
      break;
    case SortOption.mostLikes:
      routes.sort((a, b) => b.likesCount.compareTo(a.likesCount));
      break;
    case SortOption.leastLikes:
      routes.sort((a, b) => a.likesCount.compareTo(b.likesCount));
      break;
    case SortOption.mostComments:
      routes.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
      break;
    case SortOption.leastComments:
      routes.sort((a, b) => a.commentsCount.compareTo(b.commentsCount));
      break;
    case SortOption.mostTicks:
      routes.sort((a, b) => b.ticksCount.compareTo(a.ticksCount));
      break;
    case SortOption.leastTicks:
      routes.sort((a, b) => a.ticksCount.compareTo(b.ticksCount));
      break;
  }
}
