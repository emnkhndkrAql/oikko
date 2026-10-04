
class PollOptionModel {
  final String id;
  final String pollId;
  final String optionText;


  final int voteCount;

  const PollOptionModel({
    required this.id,
    required this.pollId,
    required this.optionText,
    this.voteCount = 0,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionText: json['option_text'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_text': optionText,
    };
  }

  PollOptionModel copyWith({int? voteCount}) {
    return PollOptionModel(
      id: id,
      pollId: pollId,
      optionText: optionText,
      voteCount: voteCount ?? this.voteCount,
    );
  }
}