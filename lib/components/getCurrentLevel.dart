class GameUtils {
  static int getCurrentLevel(int score) {
    int level = 1;
    if (score >= 100) {
      level = 5;
    } else if (score >= 50) {
      level = 4;
    } else if (score >= 30) {
      level = 3;
    } else if (score >= 10) {
      level = 2;
    }

    return level;
  }
}
