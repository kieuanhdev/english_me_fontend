abstract class AppRouteArgs {
  static String lessonId(dynamic arguments) {
    if (arguments is String && arguments.trim().isNotEmpty) {
      return arguments;
    }
    if (arguments is Map && arguments['lessonId'] != null) {
      return arguments['lessonId'].toString();
    }
    return '';
  }

  static bool showExercises(dynamic arguments) {
    if (arguments is Map && arguments['theoryOnly'] == true) return false;
    return true;
  }

  static Map<String, dynamic> map(dynamic arguments) {
    if (arguments is Map<String, dynamic>) return arguments;
    return const {};
  }
}
