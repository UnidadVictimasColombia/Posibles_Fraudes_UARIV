
Delete [dbo].[ConsultaBDOAJvsDeclaracionesUsuarios]

SELECT *
 into [dbo].[ConsultaBDOAJvsDeclaracionesUsuarios]
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 8.0;HDR=NO;Database=F:\UARIV\Fraudes\Fuentes\CruceBDOAJvsDeclaracionesSIPOD.xlsx;Extended properties='' ColNameHeader=True;HDR=YES;',
    'select * from [Select oajpersonas_crucefraude$]')
	order by F1

SELECT * FROM ##tmpSIPOD
Drop table ##tmpSIPOD

EXEC sp_configure 'show advanced options', 1
RECONFIGURE
GO
EXEC sp_configure 'ad hoc distributed queries', 1
RECONFIGURE
GO


EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'AllowInProcess', 1 
GO 
EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.16.0', N'DynamicParameters', 1 
GO 