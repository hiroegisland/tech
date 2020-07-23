/*
--Objective
Consolidate by concatenating multiple columns with comma.
This is alternative way about ‘string_agg’ ('string_agg' can use by SQL server 2017 later version)
*/

Select EMP_NAME,LEFT(DEPT_NAME, LEN(DEPT_NAME) - 1) DEPT_NAME
from ( 
     select Z_EMP.NAME EMP_NAME,
         (select Z_DEPT.NAME +',' from  Z_DEPT_EMP LEFT JOIN Z_DEPT ON Z_DEPT_EMP.DEPTID=Z_DEPT.ID 
                    Where  Z_DEPT_EMP.EMPID=Z_EMP.ID
           for XML PATH('') ) as DEPT_NAME 
          from Z_EMP
) t
