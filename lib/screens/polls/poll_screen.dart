import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/poll_provider.dart';
import 'poll_widget.dart';

class PollScreen extends StatefulWidget {
  const PollScreen({super.key});

  @override
  State<PollScreen> createState() => _PollScreenState();
}

class _PollScreenState extends State<PollScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PollProvider>().loadPolls();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.polls.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.polls.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        if (provider.polls.isEmpty) {
          return const Center(
            child: Text(
              'No active polls right now.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadPolls,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.polls.length,
            itemBuilder: (context, index) {
              return PollWidget(poll: provider.polls[index]);
            },
          ),
        );
      },
    );
  }
}