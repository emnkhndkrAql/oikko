import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/poll_model.dart';
import '../../models/poll_option_model.dart';
import '../../providers/poll_provider.dart';


class PollWidget extends StatelessWidget {
  final PollModel poll;

  const PollWidget({super.key, required this.poll});

  @override
  Widget build(BuildContext context) {
    final bool showResults = poll.hasUserVoted || poll.isExpired;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.poll_outlined,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    poll.question,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (poll.isExpired)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Poll closed',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            const SizedBox(height: 16),
            ...poll.options.map((option) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: showResults
                    ? _ResultBar(
                  option: option,
                  percentage: poll.percentageFor(option),
                  isSelected: poll.userVotedOptionId == option.id,
                )
                    : _VoteButton(
                  option: option,
                  poll: poll,
                ),
              );
            }),
            const SizedBox(height: 4),
            Text(
              '${poll.totalVotes} vote${poll.totalVotes == 1 ? '' : 's'}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  final PollOptionModel option;
  final PollModel poll;

  const _VoteButton({required this.option, required this.poll});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          context.read<PollProvider>().vote(
            pollId: poll.id,
            optionId: option.id,
          );
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.centerLeft,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(option.optionText),
        ),
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  final PollOptionModel option;
  final double percentage;
  final bool isSelected;

  const _ResultBar({
    required this.option,
    required this.percentage,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                option.optionText,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, size: 16, color: primary),
            const SizedBox(width: 6),
            Text('${(percentage * 100).round()}%'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percentage),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                color: isSelected ? primary : primary.withOpacity(0.5),
              );
            },
          ),
        ),
      ],
    );
  }
}