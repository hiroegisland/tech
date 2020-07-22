  /*
  Objective
  Pivot only text data without counting.
  */
  SELECT  id, en,ja  from dbo.test_fruits
    PIVOT(max(name)
    FOR lang IN ([en],[ja])
    ) AS pivot_table
