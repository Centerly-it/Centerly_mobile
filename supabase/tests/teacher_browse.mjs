import assert from 'node:assert/strict';
export async function testTeacherBrowse(db, actor, teacher, other, secretary) {
  let count=0;
  const value=async sql=>Object.values((await db.query(sql)).rows[0])[0];
  const eq=async(sql,wanted)=>{assert.deepEqual(await value(sql),wanted);count++;};
  const denied=async(sql,message)=>{await assert.rejects(db.query(sql),new RegExp(message));count++;};
  await actor(teacher);
  await eq('select count(*)::int from public.list_teacher_groups()',1);
  await eq("select count(*)::int from public.list_teacher_groups('missing')",0);
  await eq("select count(*)::int from public.list_teacher_groups('Math')",1);
  await eq("select (g->>'students_count')::int from public.list_teacher_groups() g",1);
  await eq("select jsonb_array_length(g->'roster_preview') from public.list_teacher_groups() g",1);
  await eq("select count(*)::int from public.list_teacher_groups(p_grade_level_id=>'70000000-0000-0000-0000-000000000002')",0);
  await denied('select public.list_teacher_groups(p_limit=>101)','VALIDATION_ERROR');
  await denied("select public.list_teacher_groups(p_search=>repeat('x',201))",'VALIDATION_ERROR');
  await eq("select (public.get_teacher_overview(current_date-30)->'attendance_counts'->>'not_marked')::int",1);
  await eq("select (public.get_teacher_overview(current_date-30)->'attendance_counts'->>'absent')::int",0);
  await eq("select count(*)::int from public.list_teacher_sessions(current_date-30,current_date-30)",1);
  await eq("select g->>'group_name' from public.list_teacher_sessions(current_date-30,current_date-30) g",'A');
  await denied("select public.list_teacher_sessions(current_date,current_date+62)",'VALIDATION_ERROR');
  await actor(other);
  await eq("select count(*)::int from public.list_teacher_sessions(current_date-30,current_date-30)",0);
  await eq("select count(*)::int from public.list_teacher_groups() g where g->>'name'='A'",0);
  await eq("select (public.get_teacher_overview(current_date-30)->'attendance_counts'->>'not_marked')::int",0);
  await db.exec('reset role; set role anon');
  await denied('select public.list_teacher_groups()','permission denied');
  await denied('select public.list_teacher_sessions(current_date,current_date)','permission denied');
  await denied('select public.get_teacher_overview()','permission denied');
  await actor(secretary);
  await denied('select public.list_teacher_groups()','FORBIDDEN_ROLE');
  await denied('select public.list_teacher_sessions(current_date,current_date)','FORBIDDEN_ROLE');
  await denied('select public.get_teacher_overview()','FORBIDDEN_ROLE');
  await db.exec('reset role');
  await db.exec(`insert into public.groups(teacher_id,grade_level_id,name,subject_name,capacity)
    select '${teacher}','70000000-0000-0000-0000-000000000001','Scale '||n,'Math',30
    from generate_series(1,10000) n`);
  await actor(teacher);
  await eq('select count(*)::int from public.list_teacher_groups(p_limit=>100)',100);
  const last=await value("select max(g->>'id') from public.list_teacher_groups(p_limit=>100) g");
  await eq(`select count(*)::int from public.list_teacher_groups(p_cursor=>'${last}',p_limit=>100) g where g->>'id'<='${last}'`,0);
  await db.exec('reset role');
  await db.exec("delete from public.groups where name like 'Scale %'");
  return count;
}
