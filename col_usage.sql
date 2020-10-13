prompt **
prompt ** Column Usage statistics Partition Keyi belirleme
prompt **

SELECT r.name owner,
       o.name tabl,
       c.name colmn,
       DECODE (
             c.type#,
             1, DECODE (c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
             2, DECODE (c.scale,
                        NULL, DECODE (c.precision#, NULL, 'NUMBER', 'FLOAT'),
                        'NUMBER'),
             8, 'LONG',
             9, DECODE (c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
             12, 'DATE',
             23, 'RAW',
             24, 'LONG RAW',
             69, 'ROWID',
             96, DECODE (c.charsetform, 2, 'NCHAR', 'CHAR'),
             100, 'BINARY_FLOAT',
             101, 'BINARY_DOUBLE',
             105, 'MLSLABEL',
             106, 'MLSLABEL',
             112, DECODE (c.charsetform, 2, 'NCLOB', 'CLOB'),
             113, 'BLOB',
             114, 'BFILE',
             115, 'CFILE',
             178, 'TIME(' || c.scale || ')',
             179, 'TIME(' || c.scale || ')' || ' WITH TIME ZONE',
             180, 'TIMESTAMP(' || c.scale || ')',
             181, 'TIMESTAMP(' || c.scale || ')' || ' WITH TIME ZONE',
             231, 'TIMESTAMP(' || c.scale || ')' || ' WITH LOCAL TIME ZONE',
             182, 'INTERVAL YEAR(' || c.precision# || ') TO MONTH',
             183,    'INTERVAL DAY('
                  || c.precision#
                  || ') TO SECOND('
                  || c.scale
                  || ')',
             208, 'UROWID',
             'UNDEFINED') as column_type,
       equality_preds,
       equijoin_preds,
       nonequijoin_preds,
       range_preds,
       like_preds,
       null_preds,
       timestamp
  FROM sys.col_usage$ u,
       sys.obj$ o,
       sys.col$ c,
       sys.user$ r
 WHERE     r.name = UPPER ('&p_owner')
       AND o.name LIKE UPPER ('%&p_segment_name%')
       AND o.obj# = u.obj#
       AND c.obj# = u.obj#
       AND c.col# = u.intcol#
       AND o.owner# = r.user#
       --AND (u.equijoin_preds > 0 OR u.nonequijoin_preds > 0)
ORDER BY equality_preds desc,equijoin_preds desc
/ 
 
