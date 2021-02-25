select distinct * from [dbo].[tBDOAJ] order by IDENTIFICACION, NombreCompleto

SET IDENTITY_INSERT [dbo].[tBDOAJ] ON
GO
SET IDENTITY_INSERT [dbo].[tBDOAJ] OFF
GO


select * from [dbo].[tAsesoresAbogadosOAJ]

/*
delete dbo.tEstadosFraudes 
delete dbo.[tTiposCasosFraude]
DBCC CHECKIDENT ('tEstadosFraudes', RESEED, 0);
DBCC CHECKIDENT ('tTiposCasosFraude', RESEED, 0);*/
select * from dbo.tEstadosFraudes
select soundex(tipo) st, * from [dbo].[tTipoCaso] order by Tipo
select  *  from [dbo].tBDOAJ  order by id --TIPO_CASO
select * from [dbo].[tTiposCasosFraude]

/*delete [dbo].tBDOAJ
DBCC CHECKIDENT ('tBDOAJ', RESEED, 0);*/
Select * from [dbo].[tEstadosFraudes]
29/07/2019 SE REMITIO OFICIO SOLICITANDO IMPULSO PROCESAL 20191128296151 // 20/11/2018 VIGILANCIA (ETAPA INDAGACION). LA FISCALIA ELABORO ORDEN DE POLICIA JUDICIAL PARA IDENTIFICAR E INDIVIDUALZIAR A LOS PRESUNTOS AUTORES O PARTICIPES DE LOS HECHOS.

Select * into tTipoCasoOrigenBDOAJ from tTipoCaso

SET IDENTITY_INSERT [dbo].[tAsesoresAbogadosOAJ] ON
GO
SET IDENTITY_INSERT [dbo].[tAsesoresAbogadosOAJ] OFF
GO

/*
1. Determinar el número de palabras que componen el dato maestro, no se tienen en cuenta palabras como "el", "la", "y", "en", etc
2. Buscar una a una en el registro a evaluar
2.1 Si todas las palabras se encuentran en el registro a evaluar se inserta el Id del datomaestro con el ID del caso fraude en la tablatTiposCasosFraudes. Aplica en caso que el dato maestro es solo una palabra
2.2 Si no está la palabra a buscar o no coinciden las demás palabras el dato maestro, se sigue con el siguiente dato maestro, persisitiendo el id con el id del DM "SinDefinir".
2.3 Una vez se terminan todas las palabras del registro a evaluar, se toma el siguiente registro a evaluar si existe, sino termina el proceso.
*/
--Declaraciones de variables
-- Se persiste solo el Id y el tipoCaso del registro de la BDOAJ
declare @tTipoCasos table (
	id int,
	tipo varchar(200)
)
declare @tTiposCasosFraude table(
	id int,
	idDM int,
	idRegEval int
)
declare @tTipoCasoBDOAJ table (
	id int,
	tipoCaso varchar(max)
)
-- Se copian los casosDM de la tabla TiposCasos
declare @tPalabrasDM table(
	palabra varchar(100)
)
declare @idDM int, @numPalabrasDM int, @cantDM int, @caso varchar(200), @palabraABuscar varchar(50), @cantPalabrasEncontradas int
declare @idRegEval int, @numPalabrasRegEval int, @cantRegEval int, @registroEval varchar(max)

--Copia de datos de las tablas a las varTables
insert into @tTipoCasos (id, tipo) 
	(select id, Tipo  from tTipoCaso)
insert into @tTipoCasoBDOAJ (id, tipoCaso)
	(select id, TIPO_CASO from tBDOAJ)

-- Se calcula el número de registros de las tablas @TipoCasos, @tTiposCasosFraude

set @cantRegEval = (select count(*) from @tTiposCasosFraude)

--Loop para comparar la información y persistir los cambios en la tabla tTiposCasosFraude
while (@cantRegEval > 0)
	select top 1 @idRegEval = id, @registroEval = replace(replace(tipoCaso, ',', ' '), '.', ' ')  from @tTipoCasoBDOAJ
	set @cantDM = (select count(*) from @tTipoCasos)

	--while que evalua cada uno de los casosDM en el regEvaluar para en caso que se encuentre, se persiste en la tabla tTiposCasosFraude
	while (@cantDM > 0) 
		select top 1 @idDM = id, @caso = tipo from @tTipoCasos
		--se consulta cada uno de los registros del DM para realizar el respectivo split y buscar cada una de las palabras en el regEvaluar:
		insert into @tPalabrasDM (palabra) (select * from string_split(@caso, ' '))
		--elimina parabras cortas como "de", "en", "y", etc, o de una lista de palabras específicas como 'PARA'
		delete @tPalabrasDM where (len(palabra) <= 2) OR upper(palabra) in ('PARA' )

		-- Recorre cada una de las palabras del caso y realiza la búsqueda dentro de cada registroEvaluar
		set @cantPalabrasEncontradas = 0
		set @numPalabrasDM = (select count(*) from @tPalabrasDM)
		while (select count(*) from @tPalabrasDM) > 0
			select top 1 @palabraABuscar = palabra from @tPalabrasDM
			if (select count(*) from (select * from string_split(@registroEval, ' ') where upper(value) like upper('%ESTAFA%')) as tT) > 0
				--persite el registro
				set @numPalabrasDM = @numPalabrasDM + 1
			end

			--Elimina la palabra de la tabla para buscar la siguiente
			delete from @tPalabrasDM where palabra = @palabraABuscar
		end

		--Limpia la tabla @palabrasDM
		delete from @tPalabrasDM
	end
	--Borra el registro actual de la tabla @tTiposCasosFraude
	delete @TipoCasoBDOAJ where id = @idRegEval
	set @cantRegEval = (select count(*) from @tTiposCasosFraude)
end --while


