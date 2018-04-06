
--https://ferhatsengonul.wordpress.com/2016/02/07/calculating-tps-from-ash-via-sql_exec_id/
--http://orabase.org/index.php/2016/02/08/calculating-tps-from-ash-via-sql_exec_id/
SELECT TO_CHAR (sample_time, 'HH24:MI'),
       MAX (sql_exec_id) - MIN (sql_exec_id) EXECUTIONS_PER_MINUTE
  FROM v$active_Session_history
 WHERE     sample_time BETWEEN TO_DATE ('2016-02-02 23:00',
                                        'YYYY-MM-DD HH24:MI')
                           AND TO_DATE ('2016-02-02 23:59',
                                        'YYYY-MM-DD HH24:MI')
       AND sql_id = 'd9q0btbtvr5bv'
group by TO_CHAR (sample_time, 'HH24:MI')
order by 1 asc;

-- to split results it frame by 10 minutes:

select date#,"'1'" as first_node,"'2'" as second_node from (
SELECT TRUNC(sample_time, 'MI') - MOD(TO_CHAR(sample_time, 'MI'), 10) / (24 * 60) as date#,instance_number,
       MAX (sql_exec_id) - MIN (sql_exec_id) EXECUTIONS_PER_10_MINUTE
  FROM gv$active_Session_history
 WHERE    sql_id = '77qx41mkwcm92'
group by TRUNC(sample_time, 'MI') - MOD(TO_CHAR(sample_time, 'MI'), 10) / (24 * 60),instance_number
order by 1 asc )
pivot 
(
   sum(EXECUTIONS_PER_10_MINUTE)
   for instance_number in ('1'  ,'2' )
) order by date# asc;

---

select * from (
select s.INSTANCE_NUMBER,s.sql_id,
sum( nvl(s.executions_delta,0)) execs,TO_CHAR (ss.begin_interval_time, 'DD.MM.YYYY HH24') date#
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS, dba_hist_sqltext st
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
and elapsed_time_delta > 0
and st.sql_id=s.sql_id
and s.sql_id='8xjwqbfwwppuf'
-- and st.sql_text not like '/* SQL Analyze%'
--and s.sql_id in ( select p.sql_id from dba_hist_sql_plan p where p.object_name=’OPN_HIS’)
and ss.begin_interval_time > sysdate-14
group by TO_CHAR (ss.begin_interval_time, 'DD.MM.YYYY HH24'),s.sql_id,s.INSTANCE_NUMBER )
pivot ( sum(execs) for instance_number in (1,2 )
) order by 1;

----

select * from (
select s.sql_id,
sum( nvl(s.executions_delta,0)) execs,TO_CHAR (ss.begin_interval_time, 'DD.MM.YYYY HH24') date#
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS, dba_hist_sqltext st
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
and elapsed_time_delta > 0
and st.sql_id=s.sql_id
-- and st.sql_text not like '/* SQL Analyze%'-- and s.sql_id in ( select p.sql_id from dba_hist_sql_plan p where p.object_name='OPN_HIS')
and ss.begin_interval_time > sysdate-7
group by TO_CHAR (ss.begin_interval_time, 'DD.MM.YYYY HH24'),s.sql_id )
pivot ( sum(execs) for sql_id in (
'8xjwqbfwwppuf' ,'14crnjtpxh9aa')
) order by 1;
