/*
Stored Procedure and Dynamic SQL for Unloading on Redshift via SQLWorkBench
-- Objective for this SQL
If you may fail to create Stored Procedure using SQLWorkBench by $$.
In that case you can use below code.
*/
CREATE OR REPLACE PROCEDURE unload_redshift_data()
AS '
DECLARE
    wdate text;
    unload_path text;
    unload_sql varchar(65535);
    iam_str text;
    copy_sql varchar(65535);
    proc_date text :=to_char(sysdate,''yyyymmdd'');
BEGIN
 
    truncate test.table_A;
    copy_sql:=''COPY test.table_A FROM ''''s3://buckenname/test/'' || proc_date || '''''' delimiter '''',''''  BLANKSASNULL TRIMBLANKS COMPUPDATE OFF iam_role''''arn:aws:iam::AccountId:role/RoleName'''' gzip'';
    execute copy_sql;

    iam_str:=''iam_role''''arn:aws:iam::AccountId:role/RoleName''''  parallel off DELIMITER '''','''' ALLOWOVERWRITE gzip HEADER;'';
 
    SELECT INTO wdate MIN(sales_date) FROM test.table_A ;
 

    unload_path:=''''''s3://buckenname/test/source/'' || wdate || ''_'''''';
 
    unload_sql:=''
    UNLOAD (''''
       select sales_date,store_code,store_name,sum(sales_amount) sales_amount 
       from test.table_A
       where  sales_date = \\\\'''''' || wdate || ''\\\\''''
       group by sales_date,store_code,store_name
       '''')
    TO '';
 
    unload_sql := unload_sql || unload_path;
    unload_sql:=  unload_sql || iam_str;
    execute unload_sql;
 
 
--if you can confirm sql text
--RAISE INFO    ''INFO RAISE MESSAGE %'', unload_sql;
 
 
END;
'

LANGUAGE plpgsql;

