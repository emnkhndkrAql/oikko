import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.events.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.events.isEmpty) {
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

        if (provider.events.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming events.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: provider.loadEvents,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              return _EventCard(event: provider.events[index]);
            },
          ),
        );
      },
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d · h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(event.description, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  dateFormat.format(event.eventDate),
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.location,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ResponseChip(
                    label: 'Going (${event.goingCount})',
                    status: AppConstants.statusGoing,
                    selected: event.userStatus == AppConstants.statusGoing,
                    color: Colors.green,
                    eventId: event.id,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResponseChip(
                    label: 'Interested (${event.interestedCount})',
                    status: AppConstants.statusInterested,
                    selected:
                    event.userStatus == AppConstants.statusInterested,
                    color: Colors.orange,
                    eventId: event.id,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ResponseChip(
                    label: 'Not Going (${event.notGoingCount})',
                    status: AppConstants.statusNotGoing,
                    selected: event.userStatus == AppConstants.statusNotGoing,
                    color: Colors.redAccent,
                    eventId: event.id,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponseChip extends StatelessWidget {
  final String label;
  final String status;
  final bool selected;
  final Color color;
  final String eventId;

  const _ResponseChip({
    required this.label,
    required this.status,
    required this.selected,
    required this.color,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<EventProvider>().respondToEvent(
          eventId: eventId,
          status: status,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? color : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}