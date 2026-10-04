# Oikko 🤝

> Club Governance and Management Mobile Application  
> Built with Flutter + Supabase | Version: v1.1

---

## Version History

| Version | Description |
|---------|-------------|
| v1.0 | Baseline: Auth, Announcements, Polls, Events, Admin Dashboard |
| v1.1 | DDBMS upgrade: Branch support, Role hierarchy, Notification Center, Analytics |
| v2.0 | (Planned) Full distributed architecture, Multi-org, Advanced features |

---

## Features (v1.1)

- 🔐 Authentication with role-based access (Super Admin / Admin / Moderator / Member)
- 📢 Announcement feed with branch filtering + emergency replication
- 🗳️ Live polling with real-time vote results
- 📅 Event management with RSVP tracking
- 🏢 Branch/Multi-org support (DDBMS horizontal fragmentation)
- 🔔 Notification center (read/unread)
- 📊 Basic analytics dashboard (admin only)
- 🗄️ DDBMS: Horizontal + Vertical + Hybrid fragmentation via Supabase

---

## DDBMS Design (SE 208)

| Concept | Implementation |
|---------|---------------|
| Horizontal Fragmentation | Events, Polls, Announcements split by `branch_id` |
| Vertical Fragmentation | `profiles` → `profiles` (basic) + `profile_private` (sensitive) |
| Partial Replication | `is_global=true` + `priority=emergency` announcements replicated to all nodes |
| Reconstruction | Views: `events_reconstructed`, `member_full` |
| Data Locality | Each member assigned to a branch (logical site) |

---

## Software Evolution (SE 216)

This project follows the **Software Evolution Life Cycle**:
- Requirements analysis → Impact analysis → Implementation → Testing → Release

Lehman's Laws demonstrated:
- **Continuing Change**: v1.0 → v1.1 → v2.0
- **Increasing Complexity**: DDBMS, roles, notifications added
- **Continuing Growth**: Feature set expands each version

---

## Setup

1. Clone the repo
2. Copy `lib/core/constants.example.dart` → `lib/core/constants.dart`
3. Fill in your Supabase URL and anon key
4. Run SQL schema: `supabase/v1.1_schema.sql`
5. `flutter pub get`
6. `flutter run`

---

## Git Workflow
