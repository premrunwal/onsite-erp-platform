enum LivenessChallenge {
  blink,
  turnHeadLeft,
  turnHeadRight,
  smile,
}

class LivenessChallengeResult {
  final LivenessChallenge challenge;
  final bool passed;
  final double score;

  LivenessChallengeResult({
    required this.challenge,
    required this.passed,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
        'challengeType': challenge.name.toUpperCase(),
        'score': score,
        'timestampMs': DateTime.now().millisecondsSinceEpoch,
      };
}

class LivenessVerifier {
  static String getPromptMessage(LivenessChallenge challenge) {
    switch (challenge) {
      case LivenessChallenge.blink:
        return '👁️ Slowly blink your eyes';
      case LivenessChallenge.turnHeadLeft:
        return '🔄 Turn head to the left';
      case LivenessChallenge.turnHeadRight:
        return '🔄 Turn head to the right';
      case LivenessChallenge.smile:
        return '😊 Smile naturally';
    }
  }

  static List<LivenessChallenge> getRandomChallengeSequence() {
    final list = [
      LivenessChallenge.blink,
      LivenessChallenge.turnHeadLeft,
      LivenessChallenge.turnHeadRight,
      LivenessChallenge.smile,
    ];
    list.shuffle();
    return list.take(2).toList();
  }
}
