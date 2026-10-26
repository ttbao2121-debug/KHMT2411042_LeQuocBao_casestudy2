class StatisticsService {
  Future<Map<String, dynamic>> getTaskStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'total': 12,
      'completed': 5,
      'inProgress': 4,
      'pending': 3,
    };
  }
}
