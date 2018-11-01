-- son AWR snapshot içinde plan değişikliği
select x.sql_id,x.plan_hash_value,y.plan_hash_value onceki_plan,x.executions_son,y.executions_once,
x.ELAP_PER_EXEC_son, y.ELAP_PER_EXEC_once, round(x.ELAP_PER_EXEC_son/decode(y.ELAP_PER_EXEC_once,0,1,y.ELAP_PER_EXEC_once),2) ORAN, 
100-round(y.ELAP_PER_EXEC_once/decode(x.ELAP_PER_EXEC_son,0,1,x.ELAP_PER_EXEC_son)*100) "Saving Rate%",
x.CPU_per_exec_son, y.CPU_per_exec_once,
x.BUFFER_GETS_son, y.BUFFER_GETS_once,
x.DISK_READS_son,y.DISK_READS_once,
x.ROWS_PROCESSED_son,y.ROWS_PROCESSED_once,
x.APWAIT_DELTA_son,y.APWAIT_DELTA_once,
x.IOWAIT_DELTA_son, y.IOWAIT_DELTA_once,
x.CLWAIT_DELTA_son, y.CLWAIT_DELTA_once,
x.PLSEXEC_DELTA_son, y.PLSEXEC_DELTA_once,
dbms_lob.substr( c.sql_text, 500, 1 ) sql_ilk_200,c.sql_text from 
(select a.sql_id,a.PLAN_HASH_VALUE,
sum(a.EXECUTIONS_DELTA) EXECUTIONS_son
,round(sum(a.BUFFER_GETS_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) BUFFER_GETS_son
,round(sum(a.DISK_READS_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) DISK_READS_son
,round(sum(a.ROWS_PROCESSED_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) ROWS_PROCESSED_son
,round(sum(a.ELAPSED_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) ELAP_PER_EXEC_son
,round(sum(a.CPU_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) CPU_per_exec_son
,round(sum(a.PLSEXEC_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) PLSEXEC_DELTA_son
,round(sum(a.CLWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) CLWAIT_DELTA_son
,round(sum(a.APWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) APWAIT_DELTA_son
,round(sum(a.IOWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) IOWAIT_DELTA_son
from DBA_HIST_SQLSTAT a, DBA_HIST_SNAPSHOT b 
where 
a.snap_id= b.snap_id
and A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
and A.dbid = b.dbid
and trunc(B.BEGIN_INTERVAL_TIME) = trunc(sysdate)
and a.parsing_schema_name not in ('SYS','DBSNMP')
group by sql_id,a.PLAN_HASH_VALUE) x,
(select a.sql_id,a.PLAN_HASH_VALUE,
sum(a.EXECUTIONS_DELTA) EXECUTIONS_once
,round(sum(a.BUFFER_GETS_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) BUFFER_GETS_once
,round(sum(a.DISK_READS_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) DISK_READS_once
,round(sum(a.ROWS_PROCESSED_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))) ROWS_PROCESSED_once
,round(sum(a.ELAPSED_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) ELAP_PER_EXEC_once
,round(sum(a.CPU_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) CPU_per_exec_once
,round(sum(a.PLSEXEC_TIME_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) PLSEXEC_DELTA_once
,round(sum(a.CLWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) CLWAIT_DELTA_once
,round(sum(a.APWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) APWAIT_DELTA_once
,round(sum(a.IOWAIT_DELTA)/sum(decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA))/1000,2) IOWAIT_DELTA_once
from DBA_HIST_SQLSTAT a, DBA_HIST_SNAPSHOT b 
where 
a.snap_id= b.snap_id
and A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
and A.dbid = b.dbid
and trunc(B.BEGIN_INTERVAL_TIME) <trunc(sysdate)
and a.parsing_schema_name not in ('SYS','DBSNMP')
group by sql_id,a.PLAN_HASH_VALUE) y
,DBA_HIST_SQLTEXT c
where x.sql_id = y.sql_id
and x.sql_id = c.sql_id
and x.plan_hash_value <> y.plan_hash_value 
and x.plan_hash_Value <> 0
and x.executions_son <>0
and y.executions_once <>0
--and x.elap_per_exec*2 < y.elap_per_exec
and x.elap_per_exec_son > y.elap_per_exec_once*1.5
--and x.sql_id ='9m82p8p2d7z84'
order by oran desc--x.sql_id
       
---------------------------
       
-- sorunlu SQL'in dba_hist_sqlstat dan kontrol edilmesi.
select a.snap_id,
PLAN_HASH_VALUE,
to_char(b.BEGIN_INTERVAL_TIME,'dd/mm/yyyy HH24:mi') period,A.INSTANCE_NUMBER Node,  a.EXECUTIONS_DELTA,
round(a.ELAPSED_TIME_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA)/1000,2) "ELAP_PER_EXEC(msn)",
round((a.ELAPSED_TIME_DELTA/c.tm_db_time)*100,2) elap_oran,
round((A.CPU_TIME_DELTA/c.TM_DB_CPU)*100,2) cpu_oran,
round((A.CPU_TIME_DELTA/((c.OSSTAT_BUSY_TIME+c.OSSTAT_IDLE_TIME)*10000))*100,2) total_cpu_oran
,round(a.BUFFER_GETS_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA),2) "buffer gets"
,round(a.DISK_READS_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA),2) "disk reads"
,round(a.ROWS_PROCESSED_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA),2) "rows_processed"
,round(a.FETCHES_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA),2) "end of fetches"
,round(a.END_OF_FETCH_COUNT_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA),2) "end of fetches"
,round(a.PHYSICAL_READ_BYTES_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA)/1024/1024/1024,2) "phy reads bytes"
,round(a.PLSEXEC_TIME_DELTA/decode(a.EXECUTIONS_DELTA,0,1,a.EXECUTIONS_DELTA)/1000) "CLWAIT_DELTA"
--round((a.DISK_READS_DELTA/c.user_io_total_waits)*100,2) io_oran
from DBA_HIST_SQLSTAT a, DBA_HIST_SNAPSHOT b , ALZADMIN.DBA_AWR_SUMMARY_REPORT c
--from DBA_HIST_SQLSTAT@OPUSDATA@MIG_SOURCE_DB a, DBA_HIST_SNAPSHOT@OPUSDATA@MIG_SOURCE_DB b
where 
--a.snap_id =17977 and 
a.sql_id ='1hbuxfa0ut4y9'--'0b7aap3pnsujq'--'gaak2cxx2k3mk'--'0w26b63m8nw2p'--'6yzrs1gg8zvfd'--'aus6dxuk3hph0'--'6yzrs1gg8zvfd'--'a910gbb0k12zp'--'28hmatnjfhhqa'--'41xr6640ujvfq'--'9u6dgpmy1h34j'--'4gfgbq5kd98th'--'41xr6640ujvfq'--'gjrhhch8q590k'--'2z1zzs3t2f00q'--'dbbphhp4zbkjw'--'ch0gjc7u709q6'--'46yfvuzjz6ddf'--'51xt3wjjyp86f'--'41xr6640ujvfq'--'88xmc587hkxx6'--'4gfgbq5kd98th'--'38gnurj5uqtz8'--'88f4ynfw27hwr'--'cg4afw5xs6gcz'--'2kdhgxwpvukjk'--'38gnurj5uqtz8'--41xr6640ujvfq'--'b6nkhd3ga7yyn'--'945fjkv8ysstd'--'8jvrm62w9hhgy'--'4gfgbq5kd98th'--'5z8ja73whfm9n'--'3fkswhu76znaw'--'43n9n0mug4ny6'--'bcct9qfs6xz4z'--'2zfu0yw0yx1xj'--'2c0ktkw4r0zsr'--'9tujtnvwzxwy3'--'dmy98v1t50ngg'--'2gj1qxf4tkp4u'
and a.snap_id= b.snap_id
and A.INSTANCE_NUMBER = B.INSTANCE_NUMBER
and a.snap_id = c.snap_id
and a.INSTANCE_NUMBER = c.INSTANCE_NUMBER
and a.dbid = b.dbid
and a.dbid = c.dbid
--and a.EXECUTIONS_DELTA <> 0
and trunc(B.BEGIN_INTERVAL_TIME) >= trunc(sysdate-240)
--and to_char(b.BEGIN_INTERVAL_TIME,'hh24:mi:ss') between '00:30:00' and '23:59:00'
--and plan_hash_value =2986248906
order by a.snap_id desc, A.INSTANCE_NUMBER;
---
select x.sql_id,
       x.plan_hash_value,
       y.instance_number,
       y.snap_id "SNAPSHOT_ID",
       to_char(y.begin_interval_time, 'DD.MM.YYYY HH24:MI:SS') "BAŞLANGIÇ",
       to_char(y.end_interval_time, 'DD.MM.YYYY HH24:MI:SS') "BİTİŞ",
       nvl(x.executions_delta, 0) "ECECUTIONS",
       x.px_servers_execs_delta "PX_ECECUTIONS",
       trunc((x.elapsed_time_delta / 1000000), 0) "ELAPSED_TIME(SEC)",
       trunc(((x.elapsed_time_delta /
             decode(nvl(x.executions_delta, 0), 0, 1, x.executions_delta)) /
             1000000),
             4) "ELAPSED_TIME(SEC)_PER_EXEC",
       trunc((x.cpu_time_delta / x.executions_delta / 1000000), 4) "CPU_TIME(SEC)_PER_EXEC",
       trunc((x.disk_reads_delta / x.executions_delta), 2) "DISK_READS_PER_EXEC",
       trunc((x.buffer_gets_delta / x.executions_delta), 2) "BUFFER_GETS_PER_EXEC",
       trunc((x.rows_processed_delta / x.executions_delta), 2) "ROWS_PROCESSED_PER_EXEC",
       trunc((x.direct_writes_delta / x.executions_delta), 2) "DIRECT_WRITES_PER_EXEC",
       optimizer_cost,
       x.invalidations_delta "INVALIDATIONS",
       sql_profile,
       version_count,
       x.module,
       x.action,
       trunc((x.iowait_delta / x.executions_delta / 1000000), 4) "USR_IO_WAIT_TIME(SEC)_PER_EXEC",
       trunc((x.clwait_delta / x.executions_delta / 1000000), 4) "CLUSTR_WAIT_TIME(SEC)_PER_EXEC",
       trunc((x.apwait_delta / x.executions_delta / 1000000), 4) "APP_WAIT_TIME(SEC)_PER_EXEC",
       trunc((x.ccwait_delta / x.executions_delta / 1000000), 4) "CONCRY_WAIT_TIME(SEC)_PER_EXEC",
       trunc((x.plsexec_time_delta / x.executions_delta / 1000000), 4) "PLSQL_EXEC_TIME(SEC)_PER_EXEC",
       trunc((x.javexec_time_delta / x.executions_delta / 1000000), 4) "JAVA_EXEC_TIME(SEC)_PER_EXEC"
  from dba_hist_sqlstat x, dba_hist_snapshot y
where y.snap_id = x.snap_id
   and y.instance_number = x.instance_number
   and executions_delta > 0
   and x.sql_id = '1hbuxfa0ut4y9'
order by SNAPSHOT_ID desc, optimizer_cost;
       
       
       
