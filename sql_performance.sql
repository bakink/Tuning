
select executions,rows_processed,round(rows_processed/executions,1) rp, sql_id,parsing_schema_name,
(select owner||'.'||object_name||'('||program_line#||')' from dba_objects where object_id = program_id) procedure_name,
inst_id,plan_hash_value,sql_plan_baseline,sql_profile,first_load_time,loads,invalidations,parse_calls,child_number,TO_CHAR(exact_matching_signature),
TO_CHAR(FORCE_MATCHING_SIGNATURE),executions,round(cpu_time/executions),round(elapsed_time/executions),round(buffer_gets/executions),plan_hash_value,a.* 
from gv$sql a 
--where sql_id ='9862dfm06jwp1'--'70csx5v39bt7r'--'0m05y44wt1755'--'c0qd56zgmvc39'--'gcwm7t2s90h5k'--gjrhhch8q590k'--'24g1fxcr37gw1'--'0b7aap3pnsujq'--'3ph5xht1v05v3'--'b9g67589av8sx'--'1rwsn9um0tqgk'--'gaak2cxx2k3mk'--'6yzrs1gg8zvfd'--'41xr6640ujvfq'--'6yzrs1gg8zvfd'--aus6dxuk3hph0'--'6yzrs1gg8zvfd'--a910gbb0k12zp'--'0fwjp43f2gxrm'--'8bzv4fd84xu14'--'41xr6640ujvfq'--'2w2batyupdpur'--'41xr6640ujvfq'--'gjrhhch8q590k'--'46yfvuzjz6ddf'--'51xt3wjjyp86f'----'88xmc587hkxx6'--'38gnurj5uqtz8'--'2kdhgxwpvukjk'--'38gnurj5uqtz8'--'1k9fdhrrfu0x9'--'fqvwpy11myr22'--'b6nkhd3ga7yyn'--'6vn3ztggm6zh3'--'41xr6640ujvfq'--'8jvrm62w9hhgy'--'41xr6640ujvfq'--'945fjkv8ysstd'--'75f67c6zv0anp'--'dppv9yru2ap5g'--'5z8ja73whfm9n'--2bjpjyhdy42kmj'
--and executions<>0
where upper(sql_fulltext) like '%/*+ FULL(DLV_MESSAGE) */%'
and executions<>0 
and parsing_schema_name='BPMEPROV_SOAINFRA'
--and sql_id ='2qxjam5v4b78g'
order by 1 desc;

--https://dbaclass.com/monitor-your-db/
--- Queries in last 1 hour ( Run from Toad, for proper view)
  SELECT module,
         parsing_schema_name,
         inst_id,
         sql_id,
         CHILD_NUMBER,
         sql_plan_baseline,
         sql_profile,
         plan_hash_value,
         sql_fulltext,
         TO_CHAR (last_active_time, 'DD/MM/YY HH24:MI:SS'),
         executions,
         elapsed_time / executions / 1000 / 1000,
         rows_processed,
         sql_plan_baseline
    FROM gv$sql
   WHERE last_active_time > SYSDATE - 1 / 24 AND executions <> 0
ORDER BY elapsed_time / executions DESC
