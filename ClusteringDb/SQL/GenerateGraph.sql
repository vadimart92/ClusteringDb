DECLARE @dbName VARCHAR(MAX) = 'Work_770_2555_va'
IF (OBJECT_ID('Node_Info', 'U') IS NOT NULL) BEGIN
  DROP TABLE Node_Info
END
CREATE TABLE Node_Info (Id BIGINT IDENTITY, TableName VARCHAR(100), TableSpaceId UNIQUEIDENTIFIER)
CREATE CLUSTERED INDEX Ix_Id ON Node_Info (Id)
IF (OBJECT_ID('RelationInfo', 'U') IS NOT NULL) BEGIN
  DROP TABLE RelationInfo
END
CREATE TABLE RelationInfo (TableName SYSNAME, ColumnName SYSNAME, UsedOn SYSNAME, UsedOnColumn SYSNAME)
GO
IF (OBJECT_ID('Node', 'U') IS NOT NULL) BEGIN
  DROP TABLE Node
END
CREATE TABLE Node (Node BIGINT, DependsOn BIGINT)
GO

INSERT INTO RelationInfo (TableName, ColumnName, UsedOn, UsedOnColumn)
SELECT KP.TABLE_NAME PK_Table
      , KP.COLUMN_NAME PK_Column
      , KF.TABLE_NAME FK_Table
      , KF.COLUMN_NAME FK_Column
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KF ON RC.CONSTRAINT_NAME = KF.CONSTRAINT_NAME
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KP ON RC.UNIQUE_CONSTRAINT_NAME = KP.CONSTRAINT_NAME

DECLARE @tableName SYSNAME
DECLARE @SQL NVARCHAR(MAX)

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
	SELECT t.TABLE_NAME
	FROM INFORMATION_SCHEMA.TABLES t
  WHERE t.TABLE_SCHEMA = 'dbo'
  AND t.TABLE_TYPE = 'BASE TABLE'
  AND t.TABLE_CATALOG = 'Work_770_2555_va'--@dbName
  AND EXISTS(
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS c 
    WHERE t.TABLE_NAME = c.TABLE_NAME 
      AND c.COLUMN_NAME = 'Id'
      AND c.DATA_TYPE = 'uniqueidentifier')
  
OPEN cur

FETCH NEXT FROM cur INTO @tableName

WHILE @@FETCH_STATUS = 0 BEGIN
  SET @SQL = '
    INSERT INTO Node_Info (TableName, TableSpaceId)
    SELECT '''+@tableName+''', Id
    FROM ['+@tableName+'] c'
  
  --PRINT @SQL
  EXEC sys.sp_executesql @SQL

	FETCH NEXT FROM cur INTO @tableName

END

CLOSE cur
DEALLOCATE cur


DECLARE @usedTableName SYSNAME, @columnName SYSNAME

DECLARE cur CURSOR FAST_FORWARD READ_ONLY LOCAL FOR
SELECT DISTINCT ri.TableName,
        --ri.ColumnName,
        ri.UsedOn,
        ri.UsedOnColumn
FROM RelationInfo ri

OPEN cur

FETCH NEXT FROM cur INTO @usedTableName, @tableName, @columnName

WHILE @@FETCH_STATUS = 0 BEGIN
 
    SET @SQL = '
      INSERT INTO Node (Node, DependsOn)
    	SELECT currentNode.Id, ni.Id
      FROM ['+@tableName+'] c
      INNER JOIN Node_Info ni ON c.['+@columnName+'] = ni.TableSpaceId AND ni.TableName = '''+@usedTableName+'''
      INNER JOIN Node_Info currentNode ON currentNode.TableSpaceId = c.Id AND currentNode.TableName = '''+@tableName+'''
      WHERE ni.Id IS NOT NULL
        AND currentNode.Id IS NOT NULL
      '
    --PRINT @SQL
    PRINT 'Processing: ' + @tableName
    EXEC sys.sp_executesql @SQL

	FETCH NEXT FROM cur INTO @usedTableName, @tableName, @columnName

END

CLOSE cur
DEALLOCATE cur

SELECT *
FROM Node n

SELECT *
FROM Node_Info ni