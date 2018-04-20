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
