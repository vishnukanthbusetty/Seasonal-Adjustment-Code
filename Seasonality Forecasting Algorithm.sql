

# Stored Procedure for applying the seasonality algorithm on the historical data and updating the obtained values as planned data:

IF EXISTS ( SELECT 'X' FROM SYS.OBJECTS WHERE NAME = 'Seasonality_forecast_sproc1' and TYPE ='P')
BEGIN
         DROP PROCEDURE Seasonality_forecast_sproc1
END
GO

# These are input parameters that will be fetched into the SP, on applying seasonality forecast, from the product

CREATE PROCEDURE Seasonality_forecast_sproc1 (        
 @row_num        int,        
 @LANG_ID  int,        
 @PLAN_ID  int,        
 @PLAN_NAME  varchar(250),        
 @SHEET_NAME  varchar(250),        
 @SHEET_ID  int,        
 @VERSION_NO  varchar(10),        
 @INTERVAL  int,        
 @PLAN_TEMP_NAME varchar(250),        
 @FORECAST_NAME varchar(250)       
 --@a_n_error_id  numeric output,        
 --@a_i_error_type  int output,        
 --@a_s_error_desc  varchar output       
)                            
AS                              
BEGIN         
Declare @table_name as  varchar(250)  

# Forming the format of the plan table using the input parameters

select @table_name= '[DW_PNB_DATA_'+cast(@PLAN_ID as varchar) +'_'+cast(@SHEET_ID as varchar)+'_'+cast(@LANG_ID as varchar)+'_'+cast(@VERSION_NO as varchar)+']'    
    
# To convert the row data into column data and to add measures of algorithm I have formed this table

exec('CREATE TABLE Seasonality_forecast_tb'+'_'+@SHEET_ID+' (  [row_num] [int] NULL,
									[period_id] [int] NULL,
									[Measure_value] [numeric](28, 8) NULL,
									[TrendCycle] [numeric](28, 8) NULL,
									[RatioSeasonality] [numeric](28, 8) NULL,
									[UnNormSeasIdx] [numeric](28, 8) NULL,
									[NormSeasIdx] [numeric](28, 8) NULL,
									[SeasAdjActual] [numeric](28, 8) NULL)' )     

exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,1,H_2011_2012_Q4_M1_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,2,H_2011_2012_Q4_M2_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,3,H_2011_2012_Q4_M3_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,4,H_2012_2013_Q1_M4_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,5,H_2012_2013_Q1_M5_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,6,H_2012_2013_Q1_M6_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,7,H_2012_2013_Q2_M7_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,8,H_2012_2013_Q2_M8_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,9,H_2012_2013_Q2_M9_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,10,H_2012_2013_Q3_M10_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,11,H_2012_2013_Q3_M11_M67584368 from '+@table_name+'where row_num='+@row_num)        
exec('Insert into Seasonality_forecast_tb'+'_'+@SHEET_ID+' (row_num,period_id,Measure_value) select  row_num,12,H_2012_2013_Q3_M12_M67584368 from '+@table_name+'where row_num='+@row_num)        
        	
# Algorithm logic:  
# The forecasting process proceeds as follows: 
# (i)	first the data is seasonally adjusted; 
# (ii)	then forecasts are generated for the seasonally adjusted data via linear exponential smoothing; and 
# (iii)	finally, the seasonally adjusted forecasts are "reseasonalized" to obtain forecasts for the original series. The seasonal adjustment process is carried out in the first six columns.

exec('select * into #temp from         
(        
select  fact.row_num,fact.period_id,fact.Measure_value ,        
  prev2.Measure_value prev2,prev1.Measure_value prev1 ,next1.Measure_value next1,next2.Measure_value next2,        
  ((fact.Measure_value+prev2.Measure_value+prev1.Measure_value+next1.Measure_value)/4+(fact.Measure_value+prev1.Measure_value+next1.Measure_value+next2.Measure_value)/4)/2 ''TrendCycle'',        
  (fact.Measure_value *100)/(((fact.Measure_value+prev2.Measure_value+prev1.Measure_value+next1.Measure_value)/4+(fact.Measure_value+prev1.Measure_value+next1.Measure_value+next2.Measure_value)/4)/2 )''RatioSeasonality''       
from Seasonality_forecast_tb'+'_'+@SHEET_ID+' fact        
 left join Seasonality_forecast_tb'+'_'+@SHEET_ID+' prev1        
 on fact.row_num=prev1.row_num        
 and fact.Period_id=(prev1.Period_id+1)        
 left join Seasonality_forecast_tb'+'_'+@SHEET_ID+' prev2        
 on fact.row_num=prev1.row_num        
 and fact.Period_id=(prev2.Period_id+2)        
 left join Seasonality_forecast_tb'+'_'+@SHEET_ID+' next1        
 on fact.row_num=prev1.row_num        
 and fact.Period_id=(next1.Period_id-1)        
 left join Seasonality_forecast_tb'+'_'+@SHEET_ID+' next2        
 on fact.row_num=prev1.row_num        
 and fact.Period_id=(next2.Period_id-2)        
--order by fact.ou_id,fact.template_id,fact.period_id         
)a        
        
select * into #temp2 from         
(        
select   a.row_num,a.period_id,a.measure_value,a.TrendCycle,a.RatioSeasonality,--b.RatioSeasonality,c.RatioSeasonality,        
  (a.RatioSeasonality+ isnull(b.RatioSeasonality,0)+isnull(c.RatioSeasonality,0))/2 ''UnNormSeasIdx''        
from #temp a        
 left join #temp b         
 on a.row_num=b.row_num        
 and a.Period_id=b.Period_id+4        
 and a.RatioSeasonality is not null        
 left join #temp c         
 on a.row_num=c.row_num        
 and a.Period_id=c.Period_id-4        
 and a.RatioSeasonality is not null        
--order by a.ou_id,a.template_id,a.period_id         
)a        
        
        
select * into #temp3 from         
(        
select   a.row_num,a.period_id,a.Measure_value,a.TrendCycle,a.RatioSeasonality,        
   a.UnNormSeasIdx,--b.UnNormSeasIdx,c.UnNormSeasIdx,d.UnNormSeasIdx,        
  (a.UnNormSeasIdx*4*100)/(a.UnNormSeasIdx+b.UnNormSeasIdx+c.UnNormSeasIdx+d.UnNormSeasIdx)''NormSeasIdx''         
from #temp2  a        
 left join #temp2 b         
 on a.row_num=b.row_num        
 and a.Period_id=b.Period_id-1        
 left join #temp2 c         
 on a.row_num=b.row_num        
 and a.Period_id=c.Period_id-2        
 left join #temp2 d         
 on a.row_num=b.row_num        
 and a.Period_id=d.Period_id-3        
--order by a.ou_id,a.template_id,a.period_id         
)a        
        
Merge Seasonality_forecast_tb'+'_'+@SHEET_ID+' as t1        
using        
(        
select  a.row_num,a.period_id,a.Measure_value,a.TrendCycle,a.RatioSeasonality,        
  a.UnNormSeasIdx,--a.NormSeasIdx,b.NormSeasIdx  ,c.NormSeasIdx  ,d.NormSeasIdx,        
  isnull(a.NormSeasIdx,isnull(b.NormSeasIdx  ,isnull(c.NormSeasIdx,d.NormSeasIdx) ))  ''NormSeasIdx'',        
  (a.Measure_value*100)/ isnull(a.NormSeasIdx,isnull(b.NormSeasIdx  ,isnull(c.NormSeasIdx,d.NormSeasIdx) ))''SeasAdjActual''        
from #temp3 a        
 left join #temp3 b         
 on a.row_num=b.row_num        
 and a.Period_id=b.Period_id-4        
 left join #temp3 c         
 on a.row_num=b.row_num        
 and a.Period_id=c.Period_id+4        
 left join #temp3 d         
 on a.row_num=b.row_num        
 and a.Period_id=d.Period_id+8        
--order by a.row_num,a.period_id         
) as t2        
 on t1.row_num = t2.row_num        
 and t1.period_id = t2.period_id        
        
when matched then update set        
 t1.row_num = t2.row_num,        
 t1.period_id = t2.period_id,        
 t1.measure_value = t2.measure_value,        
 t1.trendcycle = t2.trendcycle,        
 t1.ratioseasonality = t2.ratioseasonality,        
 t1.unnormseasidx = t2.unnormseasidx,        
 t1.normseasidx = t2.normseasidx,        
 t1.seasadjactual = t2.seasadjactual        
when not matched then        
insert (row_num,period_id,Measure_value,TrendCycle,RatioSeasonality,UnNormSeasIdx,NormSeasIdx,SeasAdjActual)         
values (t2.row_num,t2.period_id,t2.Measure_value,t2.TrendCycle,t2.RatioSeasonality,t2.UnNormSeasIdx,t2.NormSeasIdx,t2.SeasAdjActual);       
       
drop table #temp        
drop table #temp2        
drop table #temp3  ')      
        
exec ('update'+@table_name+        
'set P_2014_Q1_M4_M67584368 = SeasAdjActual         
 from'+ @table_name +'t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 4')        
        
exec ('update'+@table_name+         
'set P_2014_Q1_M5_M67584368 = SeasAdjActual         
 from'+ @table_name+ 't1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 5')        
        
exec ('update'+@table_name+         
'set P_2014_Q1_M6_M67584368 = SeasAdjActual         
 from' +@table_name+ ' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 6')        
        
exec ('update'+@table_name+         
'set P_2014_Q2_M7_M67584368 = SeasAdjActual         
 from '+@table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 7')        
        
exec ('update'+@table_name+         
'set P_2014_Q2_M8_M67584368 = SeasAdjActual         
 from' +@table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num     
 where period_id = 8')        
        
exec ('update'+@table_name+         
'set P_2014_Q2_M9_M67584368 = SeasAdjActual         
 from'+ @table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 9')        
        
exec ('update'+@table_name+         
'set P_2014_Q3_M10_M67584368 = SeasAdjActual         
 from' +@table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 10')        
        
exec ('update'+@table_name+         
'set P_2014_Q3_M11_M67584368 = SeasAdjActual         
 from'+ @table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 11')        
        
exec ('update'+@table_name+         
'set P_2014_Q3_M12_M67584368 = SeasAdjActual         
 from'+ @table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 12')        
        
exec ('update'+@table_name+         
'set P_2015_Q4_M1_M67584368 = SeasAdjActual         
 from'+ @table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 1')        
        
exec ('update'+@table_name+         
'set P_2015_Q4_M2_M67584368 = SeasAdjActual         
 from'+@table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 2')        
        
exec ('update'+@table_name+         
'set P_2015_Q4_M3_M67584368 = SeasAdjActual         
 from'+ @table_name+' t1        
 join Seasonality_forecast_tb'+'_'+@SHEET_ID+' t2         
 on t1.row_num = t2.row_num        
 where period_id = 3')  
  
/# Dropping the table after doing calculations on one row 

 exec('drop table Seasonality_forecast_tb'+'_'+@SHEET_ID+'')      
end


# Stored procedure for applying the algorithm on every row of plan table using cursor 

IF EXISTS ( SELECT 'X' FROM SYS.OBJECTS WHERE NAME = 'Seasonality_forecast_sproc' and TYPE ='P')
BEGIN
         DROP PROCEDURE Seasonality_forecast_sproc
END
GO
CREATE PROCEDURE Seasonality_forecast_sproc  (        
 @LANG_ID  int,        
 @PLAN_ID  int,        
 @PLAN_NAME  varchar(250),        
 @SHEET_NAME  varchar(250),        
 @SHEET_ID  int,        
 @VERSION_NO  varchar(10),        
 @INTERVAL  int,        
 @PLAN_TEMP_NAME varchar(250),        
 @FORECAST_NAME varchar(250),      
 @a_n_error_id  numeric output,        
 @a_i_error_type  int output,        
 @a_s_error_desc  varchar output         
)                         
AS                              
BEGIN         

 Declare @table_name as  varchar(250)        
 select @table_name= '[DW_PNB_DATA_'+cast(@PLAN_ID as varchar) +'_'+cast(@SHEET_ID as varchar)+'_'+cast(@LANG_ID as varchar)+'_'+cast(@VERSION_NO as varchar)+']'        
           
  create table #row_tb        
   (        
    row_num int        
   )        
           
           exec('insert into #row_tb        
            (        
                 row_num        
            )        
            select distinct row_num from'+ @table_name)        
        
            Declare @row_num as varchar(10)        
            Declare @exec as varchar(max)        
                    
            Declare MY_data CURSOR FOR        
            Select row_num from  #row_tb (Nolock)        
        
            OPEN MY_data        
                  FETCH NEXT FROM MY_data INTO @row_num         
                        WHILE @@FETCH_STATUS = 0        
                        BEGIN        
                 
            set @exec = 'exec Seasonality_forecast_sproc1 '+cast(@row_num as varchar)+','+cast(@LANG_ID as varchar)+','+cast(@PLAN_ID as varchar)+','+''''+
						cast(@PLAN_NAME as varchar)+''''+','+''''+cast(@SHEET_NAME as varchar)+''''+','+cast(@SHEET_ID as varchar)+','+cast(@VERSION_NO as varchar)+','+
						cast(@INTERVAL as varchar)+','+''''+cast(@PLAN_TEMP_NAME as varchar)+''''+','+''''+cast(@FORECAST_NAME as varchar)+''''
						--+','+cast(null as varchar)+' output' +','+cast(null as varchar)+' output'+','+''''+cast('null' as varchar)+''''+'output'       
        exec (@exec)        
                    
    FETCH NEXT FROM MY_data INTO @row_num         
                        END        
                              CLOSE MY_data        
                              DEALLOCATE MY_data      
   drop table #row_tb        
end

