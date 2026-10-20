/// Ad placements used by the app. The AdMob implementation comes later; screens
/// only talk to this interface so ads never appear mid-question.
abstract class AdService {
  /// Shown between a finished test and its results; implementations enforce the frequency cap.
  Future<void> showInterstitial();
}

class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<void> showInterstitial() async {}
}
