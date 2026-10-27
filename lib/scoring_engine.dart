/// Small pure scoring model used by CricScore.
/// This initial engine intentionally models a single innings. Before competitive
/// use, extend with batter/bowler state, strike rotation, penalty rules, and innings.
class DeliveryRecord {
  const DeliveryRecord({
    required this.batterRuns,
    required this.extras,
    required this.legalBall,
    required this.wicket,
    this.extraType,
    this.dismissal,
  });
  final int batterRuns;
  final int extras;
  final bool legalBall;
  final bool wicket;
  final String? extraType;
  final String? dismissal;
  int get totalRuns => batterRuns + extras;
}
