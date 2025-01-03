class questionmodel {
  final int questionId;
  final String question;

  questionmodel({
    required this.questionId,
    required this.question,
  });

  factory questionmodel.fromJson(Map<String, dynamic> json) {
    return questionmodel(
      questionId: json['questionId'],
      question: json['question'],
    );
  }
}
