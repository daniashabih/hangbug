class CertificateModel {
  final String id;
  final String? resultId;
  final String category;
  final int score;
  final String date;
  final bool issued;
  final String? learnerName;

  const CertificateModel({
    required this.id,
    this.resultId,
    required this.category,
    required this.score,
    required this.date,
    this.issued = true,
    this.learnerName,
  });

  String get verificationUrl => 'https://hangbug.vercel.app/certificate/view?id=$id';
  double get percentage => score.toDouble();
  String get issueDate => date;
  bool get isPassed => score >= 70;

  factory CertificateModel.fromJson(Map<String, dynamic> json) {
    final rawScore = json['score'] ?? json['percentage'] ?? 0;
    final parsedScore = rawScore is int
        ? rawScore
        : (int.tryParse(rawScore.toString()) ?? 0);

    return CertificateModel(
      id: json['id']?.toString() ?? '',
      resultId: json['resultId']?.toString(),
      category: json['category']?.toString() ?? json['tech']?.toString() ?? 'Web Development',
      score: parsedScore,
      date: json['date']?.toString() ?? json['issueDate']?.toString() ?? json['createdAt']?.toString() ?? '',
      issued: json['issued'] == true || json['issued'] == null,
      learnerName: json['learnerName']?.toString() ?? json['userName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resultId': resultId,
      'category': category,
      'score': score,
      'date': date,
      'issued': issued,
      'learnerName': learnerName,
    };
  }
}
