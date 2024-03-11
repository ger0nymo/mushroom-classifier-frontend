class Result {
  final List<Prediction> predictions;

  Result({required this.predictions});

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      predictions: List<Prediction>.from(
          json['predictions'].map((x) => Prediction.fromJson(x))),
    );
  }
}

class Prediction {
  final String name;
  final double prob;

  Prediction({required this.name, required this.prob});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      name: json['name'],
      prob: json['prob'],
    );
  }
}