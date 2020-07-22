Set nocount on

DECLARE

    @columns NVARCHAR(MAX) = '',

    @months NVARCHAR(MAX) = '',

    @sql     NVARCHAR(MAX) = '';

   

DECLARE @current  NVARCHAR(10) =replace(LEFT(CONVERT(varchar, DATEADD(month,-1,GETDATE()),23),8)+'01','-','')

DECLARE @ymd date = CONVERT(DATE, @current)

DECLARE @end int = CAST(replace(DATEADD(month, -23, @ymd),'-','') AS int)

 

-- select the trade_date

SELECT

    @columns+=QUOTENAME(A.trade_date) + ','

FROM

      TestA (NOLOCK) as A

      where A.trade_date between @end and @current

GROUP BY A.trade_date

ORDER BY trade_date DESC;


— Add alias name for Extracting Month columns of Dynamic SQL

SELECT

     @months+= 'ISNULL('+QUOTENAME(A.trade_date) + ',0) ' + QUOTENAME('month'+LTRIM(STR(ROW_NUMBER() OVER(ORDER BY A.trade_date DESC)-1)) ) + ','  

FROM

    TestA (NOLOCK) as A

      where A.trade_date between @end and @current

GROUP BY A.trade_date

ORDER BY A.trade_date DESC


-- remove the last comma

SET @columns = LEFT(@columns, LEN(@columns) - 1);

SET @months = LEFT(@months, LEN(@months) - 1);


-- construct dynamic SQL

SET @sql ='SET NOCOUNT ON;

SELECT ' + @current  +'  CID, ' + @months + ' FROM  

(

    SELECT

                 CID

                ,ISNULL([Sales],0) AS Sales

                ,A.trade_date

    FROM

      TestA as A (NOLOCK)

      WHERE A.[tdade_date] between '+cast(@end as varchar(10))+' and ' +cast(@current as varchar(10)) +'

) t

PIVOT(

     SUM(Sales)

     FOR trade_date IN ('+ @columns +')

) AS pivot_table;';

 -- execute the dynamic SQL

EXECUTE sp_executesql @sql;
