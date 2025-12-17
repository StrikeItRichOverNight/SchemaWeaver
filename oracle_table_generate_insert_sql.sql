SELECT
    'SELECT ''INSERT INTO ' || t.table_name || '(' ||
    LISTAGG(
            CASE WHEN
                     c.data_type NOT IN ('NUMBER')
                     THEN c.column_name
                 ELSE ''
                END, ', '
    )
            WITHIN GROUP (ORDER BY c.column_id) ||
    CASE WHEN SUM(CASE WHEN c.data_type IN ('NUMBER') THEN 1 ELSE 0 END) > 0
             THEN ' , '
         ELSE '' END  ||
    LISTAGG(
            CASE WHEN
                     c.data_type IN ('NUMBER')
                     THEN c.column_name
                 ELSE ''
                END, ', '
    )
            WITHIN GROUP (ORDER BY c.column_id) || ') '' || ' || CHR(10) ||
    ' ''SELECT '''''' || ' ||
    LISTAGG(
            CASE
                WHEN c.data_type IN ('VARCHAR2', 'CHAR', 'CLOB', 'NVARCHAR2')
                    THEN c.column_name || ' || '''''''
                WHEN c.data_type IN ('DATE', 'TIMESTAMP')
                    THEN 'TO_CHAR(' || c.column_name || ', ''YYYY-MM-DD HH24:MI:SS'') || '''''''
                ELSE
                    CASE WHEN c.data_type NOT IN ('NUMBER','RAW') THEN
                             'TO_CHAR(' || c.column_name || ') || '''''''
                         ELSE
                             ''
                        END
                END,
            ', '''''' || '
    ) WITHIN GROUP (ORDER BY c.column_id) || ''' || ' || CHR(10) ||
    CASE WHEN SUM(CASE WHEN c.data_type IN ('NUMBER') THEN 1 ELSE 0 END) > 0 THEN ' '','' || ' ELSE '' END ||
    LISTAGG(
            CASE
                WHEN c.data_type IN ('NUMBER') and c.data_scale > 0
                    THEN 'TO_NUMBER(' || c.column_name || ') || '' '
                WHEN c.DATA_TYPE IN ('NUMBER') and c.DATA_SCALE = 0
                    THEN 'TO_NUMBER(' || c.column_name || ') || '' '
                ELSE
                    ''
                END,
            ', ''  || '
    ) WITHIN GROUP (ORDER BY c.column_id) || '  ' ||
    CASE WHEN SUM(CASE WHEN c.data_type IN ('NUMBER') THEN 1 ELSE 0 END) > 0 THEN '' ELSE ' '' ' END ||
    ' FROM dual WHERE NOT EXISTS (SELECT 1 FROM ' || t.table_name || ' WHERE ' ||
    LISTAGG(
            CASE WHEN pk.column_name IS NOT NULL THEN
                     pk.column_name || ' = '''''' || ' || pk.column_name || ' || '''''''
                END,
            ' AND '
    ) WITHIN GROUP (ORDER BY pk.position) ||
    ' );'' ' || CHR(10) ||
    'FROM ' || t.table_name || CHR(10) ||
    'ORDER BY ' ||
    LISTAGG(pk.column_name, ', ') WITHIN GROUP (ORDER BY pk.position) || ';'
        AS generated_sql
--into v_sql_generator
FROM user_tables t
         JOIN user_tab_columns c ON t.table_name = c.table_name
         LEFT JOIN (
    SELECT cc.table_name, cc.column_name, cc.position
    FROM user_constraints uc
             JOIN user_cons_columns cc ON uc.constraint_name = cc.constraint_name
    WHERE uc.constraint_type = 'P'
) pk ON c.table_name = pk.table_name AND c.column_name = pk.column_name
WHERE t.table_name = :tableName
  and c.COLUMN_NAME not in ('INS_DAT','UPD_DAT')
GROUP BY t.table_name;
