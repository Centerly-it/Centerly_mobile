# Backend compatibility — unreleased

Schema version range: 202610180001 through 202610180009, canonical in this repo.
No hosted project version or schema release SHA is verified. Flutter still uses
the existing prototype model/REST adapters and is not yet compatible with these
RPCs. T-010 remains in progress, not complete.

Before T-011: verify the canonical migration checksum/version on an approved local
or staging Supabase environment, generate/adapt Dart mappings to SQL signatures,
and test profile, tenant and inactive-session behavior. Pin this repository's
schema commit in both clients; compare schema/version before coordinated releases.
Transfer ownership without reapplying migration IDs when Secretary repo is ready.
