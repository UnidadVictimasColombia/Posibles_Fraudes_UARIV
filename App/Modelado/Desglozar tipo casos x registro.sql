use [sqldb-uvictimas-fraudes]
/*
1. Determinar el número de palabras que componen el dato maestro, no se tienen en cuenta palabras como "el", "la", "y", "en", etc
2. Buscar una a una en el registro a evaluar
2.1 Si todas las palabras se encuentran en el registro a evaluar se inserta el Id del datomaestro con el ID del caso fraude en la tablatTiposCasosFraudes. Aplica en caso que el dato maestro es solo una palabra
2.2 Si no está la palabra a buscar o no coinciden las demás palabras el dato maestro, se sigue con el siguiente dato maestro, persisitiendo el id con el id del DM "SinDefinir".
2.3 Una vez se terminan todas las palabras del registro a evaluar, se toma el siguiente registro a evaluar si existe, sino termina el proceso.
*/
--Limpia la tabla de destino
delete [dbo].[tTiposCasosFraude]
DBCC CHECKIDENT ('tTiposCasosFraude', RESEED, 0);

--Declaraciones de variables
-- Se persiste solo el Id y el tipoCaso del registro de la BDOAJ
declare @tTipoCasos table (
	id int,
	tipo varchar(200)
)
declare @tTiposCasosFraude table(
	id int identity(1,1),
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

--Se crea la tabla temporal de palabras
select * into #tmpTipoCasoBDOAJ from @tTipoCasoBDOAJ
select * into #tmpPalabrasDM from @tPalabrasDM
select * into #tmpTipoCasos from @tTipoCasos
--Copia de datos de las tablas a las varTables
insert into #tmpTipoCasoBDOAJ (id, tipoCaso)
	(select id, TIPO_CASO from tBDOAJ where TIPO_CASO is not null OR TIPO_CASO <> ' ')

-- Se calcula el número de registros de las tablas @TipoCasos, @tTiposCasosFraude
set @cantRegEval = (select count(*) from #tmpTipoCasoBDOAJ)

--Loop para comparar la información y persistir los cambios en la tabla tTiposCasosFraude
while (@cantRegEval > 0)
begin
	insert into #tmpTipoCasos (id, tipo) 
		(select id, Tipo  from tTipoCaso)
	--Lee el primer registro de la tabla #tmpTipoCasoBDOAJ para realizar el proceso de análisis, comparación y relación. Posterior elimina el registro de esta tabla y toma el siguiente si existe.
	select top 1 @idRegEval = id, @registroEval = replace(replace(replace(tipoCaso, ',', ' '), '.', ' '), '-', ' ')  from #tmpTipoCasoBDOAJ
	--select @idRegEval as idRegEval, @registroEval
	set @cantDM = (select count(*) from #tmpTipoCasos)
	--while que evalua cada uno de los casosDM en el regEvaluar para en caso que se encuentre, se persiste en la tabla tTiposCasosFraude
	while (@cantDM > 0) 
	begin
		select top 1 @idDM = id, @caso = tipo from #tmpTipoCasos
		--se consulta cada uno de los registros del DM para realizar el respectivo split y buscar cada una de las palabras en el regEvaluar:
		insert into #tmpPalabrasDM (palabra) (select * from string_split(@caso, ' '))
		--elimina parabras cortas como "de", "en", "y", etc, o de una lista de palabras específicas como 'PARA'
		delete #tmpPalabrasDM where (len(palabra) <= 2) OR upper(palabra) in ('PARA' )

		-- Recorre cada una de las palabras del caso y realiza la búsqueda dentro de cada registroEvaluar
		set @cantPalabrasEncontradas = 0
		-- Determina el número total de palabras para comparar y validar 
		set @numPalabrasDM = (select count(*) from #tmpPalabrasDM)
		--While para buscar cada una de las palabras en el regEvaluar.
		--select '@numPalabrasDM', * from #tmpPalabrasDM
		while (select count(*) from #tmpPalabrasDM) > 0
		begin
			
			select top 1 @palabraABuscar = palabra from #tmpPalabrasDM
			--if (select count(*) from (select * from string_split(@registroEval, ' ') where upper(value) like upper('%''' + @palabraABuscar + '''%')) as tT) > 0
			--select soundex(@palabraABuscar) pb, soundex(value), * from string_split(@registroEval, ' ')
			--select * from string_split(@registroEval, ' ') where soundex(value) = soundex(@palabraABuscar)
			--select count(*) from (select * from string_split(@registroEval, ' ') where soundex(value) = soundex(@palabraABuscar)) as tT
			if (select count(*) from (select * from string_split(@registroEval, ' ') where soundex(value) = soundex(@palabraABuscar)) as tT) > 0
			begin		
				set @cantPalabrasEncontradas = @cantPalabrasEncontradas + 1
			end 
			if (@numPalabrasDM = @cantPalabrasEncontradas)
			begin
				--persite el registro si la cantidad de palabras del DM fueron encontradas en regEvaluar
				insert into [dbo].[tTiposCasosFraude] ([idTTipoCaso], [idTBDOAJ]) values (@idDM, @idRegEval)
				set @cantPalabrasEncontradas = 0
				--select '[tTiposCasosFraude]', * from [tTiposCasosFraude]
			end
			--Elimina la palabra de la tabla para buscar la siguiente
			delete #tmpPalabrasDM where palabra = @palabraABuscar
			--select * from #tmpPalabrasDM
		end
		--Siguiente tipoCaso
		delete from #tmpTipoCasos where id = @idDM
		set @cantDM = (select count(*) from #tmpTipoCasos)
		--Limpia la tabla @#tmpPalabrasDM
		delete from #tmpPalabrasDM
	end
	--Borra el registro actual de la tabla @#tmpTipoCasoBDOAJ
	delete from #tmpTipoCasoBDOAJ where id = @idRegEval
	set @cantRegEval = (select count(*) from #tmpTipoCasoBDOAJ)
	print @cantRegEval
end --while

select  'Finalizó'
  
drop table #tmpPalabrasDM
drop table #tmpTipoCasos
drop table #tmpTipoCasoBDOAJ

