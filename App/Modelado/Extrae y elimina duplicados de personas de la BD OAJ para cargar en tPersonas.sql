-- extraer las personas de la tBDOAJ para persistir un solo registro de cada uno en la tabla tPersonas. Es posible que la misma persona aparezca dos veces si el NoDocumento no coincide.
select * from tPersonas

--Limpia la tabla para evitar duplicados
if (select count(*) from tPersonas) > 0
begin
	delete dbo.tPersonas
	DBCC CHECKIDENT ('tPersonas', RESEED, 0);
end

Insert into tPersonas ([NoIdentificacion], [PrimerNombre], [SegundoNombre], [PrimerApellido], [SegundoApellido], [idTipoPersona], [idCalidadPersona], [idProceso])
select IDENTIFICACION, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, idTipoPersona, idCalidadPersona, idProceso  
from (
	select distinct [IDENTIFICACION],
			--'' [NombreCompletoGeneradorIrregularidad],
			--[NombreCompleto],
			isnull([PrimerNombre], '') PrimerNombre,
			[SegundoNombre],
			[PrimerApellido],
			[SegundoApellido],
			(case when ([SegundoNombre] is null and [PrimerApellido] is null and [SegundoApellido] is null) then 2 else 1 end) idTipoPersona,
			1 as  idCalidadPersona,
			null as idProceso
		from[dbo].[tBDOAJ] bdOrg
	union
	select distinct [IDENTIFICACION_QUEJOSO] as [IDENTIFICACION],
			--'' [NombreCompletoGeneradorIrregularidad],
			--[NombreCompleto],
			isnull([PrimerNombreQuejoso], '') as PrimerNombre,
			[SegundoNombreQuejoso] as SegundoNombre,
			[PrimerApellidoQuejoso] as PrimerApellido,
			[SegundoApellidoQuejoso] as SegundoApellido,
			(case when ([SegundoNombreQuejoso] is null and [PrimerApellidoQuejoso] is null and [SegundoApellidoQuejoso] is null) then 2 else 1 end) idTipoPersona,
			2 as  idCalidadPersona,
			null as idProceso
		from[dbo].[tBDOAJ] bdOrg
	) as qP
order by qP.PrimerNombre, qP.PrimerApellido, qP.IDENTIFICACION

