import 'poll_option_model.dart';


class PollModel {
  final String id;
  final String question;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final List<PollOptionModel> options;


  final String? userVotedOptionId;

  const PollModel({
    required this.id,
    required this.question,
    required this.createdAt,
    this.expiresAt,
    this.options = const [],
    this.userVotedOptionId,
  });

  bool get isExpired =>
      expiresAt != null && expiresAt!.isBefore(DateTime.now());

  bool get hasUserVoted => userVotedOptionId != null;

  int get totalVotes =>
      options.fold<int>(0, (sum, option) => sum + option.voteCount);

  double percentageFor(PollOptionModel option) {
    if (totalVotes == 0) return 0;
    return option.voteCount / totalVotes;
  }

  factory PollModel.fromJson(
      Map<String, dynamic> json, {
        List<PollOptionModel> options = const [],
        String? userVotedOptionId,
      }) {
    return PollModel(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      options: options,
      userVotedOptionId: userVotedOptionId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
    };
  }

  PollModel copyWith({
    List<PollOptionModel>? options,
    String? userVotedOptionId,
  }) {
    return PollModel(
      id: id,
      question: question,
      createdAt: createdAt,
      expiresAt: expiresAt,
      options: options ?? this.options,
      userVotedOptionId: userVotedOptionId ?? this.userVotedOptionId,
    );
  }
}