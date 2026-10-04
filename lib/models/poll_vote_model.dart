
class PollVoteModel {
  final String id;
  final String pollId;
  final String optionId;
  final String userId;

  const PollVoteModel({
    required this.id,
    required this.pollId,
    required this.optionId,
    required this.userId,
  });

  factory PollVoteModel.fromJson(Map<String, dynamic> json) {
    return PollVoteModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionId: json['option_id'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poll_id': pollId,
      'option_id': optionId,
      'user_id': userId,
    };
  }
}