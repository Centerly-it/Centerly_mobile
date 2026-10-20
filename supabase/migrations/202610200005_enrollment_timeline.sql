-- LOCAL PROPOSAL ONLY. Enforce future enrollment writes without inventing history.
-- Existing violations MUST be reported and explicitly repaired before VALIDATE.
alter table public.group_enrollments add constraint enrollment_status_timeline
 check((status='active' and left_at is null) or
       (status='inactive' and left_at is not null and left_at>=joined_at)) not valid;
