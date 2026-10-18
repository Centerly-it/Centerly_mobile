-- Synthetic test identities only. Not hosted Auth accounts or usable credentials.
insert into auth.users(id) values
 ('10000000-0000-0000-0000-000000000001'),('10000000-0000-0000-0000-000000000002'),
 ('20000000-0000-0000-0000-000000000001'),('20000000-0000-0000-0000-000000000002');
insert into public.teachers(id,name,subscription_status) values
 ('10000000-0000-0000-0000-000000000001','Test teacher A','active'),
 ('10000000-0000-0000-0000-000000000002','Test teacher B','active');
insert into public.secretaries(id,teacher_id,name,email) values
 ('20000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Test secretary A','a@example.invalid'),
 ('20000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Test secretary B','b@example.invalid');
insert into public.grade_levels(id,teacher_id,name) values
 ('70000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Level A'),
 ('70000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Level B');
insert into public.groups(id,teacher_id,grade_level_id,name,subject_name,capacity) values
 ('40000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','70000000-0000-0000-0000-000000000001','A','Math',30),
 ('40000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','70000000-0000-0000-0000-000000000002','B','Math',30);
insert into public.students(id,teacher_id,full_name) values
 ('30000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','Synthetic student A'),
 ('30000000-0000-0000-0000-000000000002','10000000-0000-0000-0000-000000000002','Synthetic student B');
insert into public.group_enrollments(teacher_id,group_id,student_id,joined_at) values
 ('10000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001',now()-interval '60 days');
insert into public.sessions(id,teacher_id,group_id,local_date,starts_at,ends_at) values
 ('50000000-0000-0000-0000-000000000001','10000000-0000-0000-0000-000000000001','40000000-0000-0000-0000-000000000001',current_date-30,now()-interval '30 days',now()-interval '30 days'+interval '1 hour');
insert into public.attendance(teacher_id,session_id,student_id) values
 ('10000000-0000-0000-0000-000000000001','50000000-0000-0000-0000-000000000001','30000000-0000-0000-0000-000000000001');
