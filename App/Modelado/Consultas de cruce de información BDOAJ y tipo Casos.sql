/****** Script for SelectTopNRows command from SSMS  ******/

select * from [dbo].[tTipoCaso]
SELECT  [id]
      ,[idTBDOAJ]
      ,[idTTipoCaso]
  FROM [dbo].[tTiposCasosFraude]
select * from [dbo].[tBDOAJ] where TIPO_CASO is not null and replace(TIPO_CASO, ' ', '') <> ''

select bd.id, bd.TIPO_CASO, tcf.idTTipoCaso, tc.tipo from tBDOAJ bd 
	inner join tTiposCasosFraude tcf on tcf.idTBDOAJ = bd.id
	inner join tTipoCaso tc on tc.id = tcf.idTTipoCaso