
-- Ubicación reporte fraude
select * from (
	select distinct
		P.idPersona,
		oaj.DEPARTAMENTO_dondesepresento_irregularidad,
		oaj.MUNICIPIO_dondesepresento_irregularidad,
		oaj.LUGARDEATENCION,
		oaj.FECHA_INGRESO,
		oaj.FECHA_RADICACION_ACCION,
		oaj.IDENTIFICACION_QUEJOSO
	from tpersonas p
		inner join tBDOAJ oaj on oaj.IDENTIFICACION = p.NoIdentificacion and oaj.PrimerNombre = p.PrimerNombre and oaj.PrimerApellido=p.PrimerApellido
) x
ORDER BY idPersona



select * 
from tpersonas p
	inner join [dbo].[tCruceSGVCasos] sgv on trim(sgv.identificacion) = trim(p.NoIdentificacion)

select * from [dbo].[tCruceSGVCasos]

Insert into [dbo].[tCruceSIPOD]   (select * from [dbo].[tmpSIPOD])