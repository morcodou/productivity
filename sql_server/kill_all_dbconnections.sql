USE [master];
GO

DECLARE @sqlversion AS DECIMAL(18, 4) = CAST(LEFT(CAST(SERVERPROPERTY('productversion') AS VARCHAR), 4) AS DECIMAL(18, 4))
DECLARE @kill VARCHAR(8000) = '';

DECLARE @dbnames VARCHAR(8000) = 'dbname00;dbname01;dbname03;'  

IF OBJECT_ID('tempdb..#TDBNamesID') IS NOT NULL
	DROP TABLE #TDBNamesID

SELECT 
		DISTINCT db_id(RTRIM(LTRIM(value))) databaseId
		INTO  #TDBNamesID
FROM	STRING_SPLIT(@dbnames, ';')  
WHERE	RTRIM(LTRIM(value)) <> ''; 

IF(@sqlversion >= 11.0) --For MS SQL Server 2012 and aboverest	
BEGIN
	SELECT @kill = @kill + 'kill ' + CONVERT(VARCHAR(5), SESSION_ID) + ';' 
	FROM	SYS.DM_EXEC_SESSIONS SESS
				INNER JOIN #TDBNamesID
				ON SESS.DATABASE_ID = #TDBNamesID.databaseId

	PRINT @kill
	EXEC(@kill);
END
