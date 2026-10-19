import assert from 'node:assert/strict';
import {test} from 'node:test';
import {sqlTokens} from '../admin/sql_tokens.mjs';
test('migration history comparison ignores outer formatting, preserves bodies and literals',()=>{
  assert.deepEqual(sqlTokens('-- header\r\n CREATE /* nested /* x */ */ FUNCTION a() RETURNS text AS $$ begin; end $$ LANGUAGE plpgsql;'),
    sqlTokens('create function a ( ) returns text as $$ begin; end $$ language plpgsql'));
  assert.notDeepEqual(sqlTokens("select 'a;b'"),sqlTokens("select 'ab'"));
  assert.notDeepEqual(sqlTokens('select $$one$$'),sqlTokens('select $$two$$'));
  assert.deepEqual(sqlTokens("select 'it''s'"),['select',"'it''s'"]);
  assert.throws(()=>sqlTokens('select $$broken'),/Unterminated/);
});
