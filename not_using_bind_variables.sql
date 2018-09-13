insert into ALZADMIN.NOT_USING_BIND_VARIABLES
SELECT q.* ,sysdate, null
  FROM (  SELECT
                x.FORCE_MATCHING_SIGNATURE,                               
                x.sql_id,
                 x.SQL_TEXT,
                 x.module,
                 x.parsing_schema_name,
                 x.SHARABLE_MEM,
                 x.EXECUTIONS,
                 --x.sira,
                 x.plsql_procedure
            FROM (SELECT a.FORCE_MATCHING_SIGNATURE,
                         a.sql_id,
                         a.SQL_TEXT,
                         a.inst_id,
                         a.module,
                         a.parsing_schema_name,
                         a.SHARABLE_MEM,
                         a.EXECUTIONS,
                         ROW_NUMBER ()
                         OVER (PARTITION BY a.sql_id
                               ORDER BY a.program_id DESC, a.program_line#)
                            sira,
                         DECODE (
                            a.program_id,
                            0, NULL,
                               b.owner
                            || '.'
                            || b.object_name
                            || '('
                            || a.program_line#
                            || ')')
                            plsql_procedure
                    FROM gv$sqlarea a, dba_objects b
                   WHERE     a.program_id = b.object_id
                         AND a.MODULE IS NOT NULL
                         AND a.PARSING_SCHEMA_ID NOT LIKE '%SYS%'
                         AND a.PARSING_SCHEMA_NAME <> 'SYS'
                         AND a.FORCE_MATCHING_SIGNATURE <> 0
                         AND a.MODULE NOT IN ('OEM',
                                              'Data Pump Worker',
                                              'Admin Connection')) x
           WHERE     x.sira = 1
                 AND EXISTS
                        (SELECT 1
                           FROM gv$sqlarea ga
                          WHERE     ga.FORCE_MATCHING_SIGNATURE =
                                       x.FORCE_MATCHING_SIGNATURE
                                AND ga.sql_id <> x.sql_id)
                 AND x.force_matching_signature IN (  SELECT x.FORCE_MATCHING_SIGNATURE
                                                        FROM (SELECT a.FORCE_MATCHING_SIGNATURE,
                                                                     a.sql_id,
                                                                     a.SQL_TEXT,
                                                                     a.inst_id,
                                                                     a.module,
                                                                     a.parsing_schema_name,
                                                                     a.SHARABLE_MEM,
                                                                     a.EXECUTIONS,
                                                                     --a.KEPT_VERSIONS,
                                                                     --round(a.buffer_gets / decode(a.executions, 0, 1, a.executions)) buffer_per_Exec,
                                                                     ROW_NUMBER ()
                                                                     OVER (
                                                                        PARTITION BY a.sql_id
                                                                        ORDER BY
                                                                           a.program_id DESC,
                                                                           a.program_line#)
                                                                        sira,
                                                                     DECODE (
                                                                        a.program_id,
                                                                        0, NULL,
                                                                           b.owner
                                                                        || '.'
                                                                        || b.object_name
                                                                        || '('
                                                                        || a.program_line#
                                                                        || ')')
                                                                        plsql_procedure
                                                                FROM gv$sqlarea a,
                                                                     dba_objects b
                                                               WHERE     a.program_id =
                                                                            b.object_id
                                                                     AND a.MODULE
                                                                            IS NOT NULL
                                                                     AND a.PARSING_SCHEMA_ID NOT LIKE
                                                                            '%SYS%'
                                                                     AND a.PARSING_SCHEMA_NAME <>
                                                                            'SYS'
                                                                     AND a.FORCE_MATCHING_SIGNATURE <>
                                                                            0
                                                                     AND a.MODULE NOT IN ('OEM',
                                                                                          'Data Pump Worker',
                                                                                          'Admin Connection'))
                                                             x
                                                       WHERE     x.sira = 1
                                                             AND EXISTS
                                                                    (SELECT 1
                                                                       FROM gv$sqlarea ga
                                                                      WHERE     ga.FORCE_MATCHING_SIGNATURE =
                                                                                   x.FORCE_MATCHING_SIGNATURE
                                                                            AND ga.sql_id <>
                                                                                   x.sql_id)
                                                    GROUP BY x.FORCE_MATCHING_SIGNATURE
                                                      HAVING (COUNT (x.sql_id)) >
                                                                1)
        ORDER BY x.FORCE_MATCHING_SIGNATURE) q
 WHERE ROWNUM < 20000;
commit;
spool off
exit;

