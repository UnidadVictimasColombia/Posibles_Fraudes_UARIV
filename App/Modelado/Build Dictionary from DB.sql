use [sqldb-uvictimas-fraudes]

--Crear Diccionario
insert into dbo.ddic_tDataTableDic ([Schema_Name],[Table_Name],[Created],[Last_Modified],[Table_Desc],[Num_Rows],[Comments])
select schema_name(tab.schema_id) as schema_name,
       tab.name as table_name, 
       tab.create_date as created,  
       tab.modify_date as last_modified,
	   convert(varchar(max),isnull(td.value, '')) AS [table_desc],
       p.rows as num_rows, 
       convert(varchar(max),isnull(ep.value, '')) as comments    
  from sys.tables tab
       inner join (select distinct 
                          p.object_id,
                          sum(p.rows) rows
                     from sys.tables t
                          inner join sys.partitions p 
                              on p.object_id = t.object_id 
                    group by p.object_id,
                          p.index_id) p
            on p.object_id = tab.object_id
        left join sys.extended_properties ep 
            on tab.object_id = ep.major_id
           and ep.name = '[sqldb-uvictimas-fraudes]'
           and ep.minor_id = 0
           and ep.class_desc = 'OBJECT_OR_COLUMN'
		LEFT OUTER JOIN sys.extended_properties td
			ON      td.major_id = tab.object_id
			AND     td.minor_id = 0
			AND     td.name = 'MS_Description'
	where tab.name <> 'sysdiagrams' and substring(tab.name, 1, 3) <> 'ddi'
  order by schema_name,
        table_name

insert into dbo.ddic_tDataColumsDic ([schema_name],[idTable],[table_name],[column_name],[data_type],[data_type_length],[nullable],[default_value],[primary_key],[foreign_key],[unique_key],[check_contraint],[comments])
select schema_name(tab.schema_id) as schema_name,
	   ddT.id idTable,
       tab.name as table_name, 
       col.name as column_name, 
       t.name as data_type,    
       case when t.is_user_defined = 0 then 
                 isnull(
                 case when t.name in ('binary', 'char', 'nchar', 
                           'varchar', 'nvarchar', 'varbinary') then
                           case col.max_length 
                                when -1 then 'MAX' 
                                else 
                                     case when t.name in ('nchar', 
                                               'nvarchar') then
                                               cast(col.max_length/2 
                                               as varchar(4)) 
                                          else cast(col.max_length 
                                               as varchar(4)) 
                                     end
                           end
                      when t.name in ('datetime2', 'datetimeoffset', 
                           'time') then 
                           cast(col.scale as varchar(4))
                      when t.name in ('decimal', 'numeric') then
                            cast(col.precision as varchar(4)) + ', ' +
                            cast(col.scale as varchar(4))
                 end , '')        
            else ':' + 
                 (select c_t.name + 
                         isnull(
                         case when c_t.name in ('binary', 'char', 
                                   'nchar', 'varchar', 'nvarchar', 
                                   'varbinary') then 
                                    case c.max_length 
                                         when -1 then 'MAX' 
                                         else   
                                              case when t.name in 
                                                        ('nchar', 
                                                        'nvarchar') then 
                                                        cast(c.max_length/2
                                                        as varchar(4))
                                                   else cast(c.max_length
                                                        as varchar(4))
                                              end
                                    end
                              when c_t.name in ('datetime2', 
                                   'datetimeoffset', 'time') then 
                                   cast(c.scale as varchar(4))
                              when c_t.name in ('decimal', 'numeric') then
                                   cast(c.precision as varchar(4)) + ', ' 
                                   + cast(c.scale as varchar(4))
                         end, '') 
                    from sys.columns as c
                         inner join sys.types as c_t 
                             on c.system_type_id = c_t.user_type_id
                   where c.object_id = col.object_id
                     and c.column_id = col.column_id
                     and c.user_type_id = col.user_type_id
                 )
        end as data_type_length,
        case when col.is_nullable = 0 then 'N' 
             else 'Y' end as nullable,
        case when def.definition is not null then def.definition 
             else '' end as default_value,
        case when pk.column_id is not null then 'PK' 
             else '' end as primary_key, 
        case when fk.parent_column_id is not null then 'FK' 
             else '' end as foreign_key, 
        case when uk.column_id is not null then 'UK' 
             else '' end as unique_key,
        case when ch.check_const is not null then ch.check_const 
             else '' end as check_contraint,
        --isnull(cc.definition, '') as computed_column_definition,
        convert(varchar(MAX),isnull(ep.value, '')) as comments
   from sys.tables as tab
        left join sys.columns as col
            on tab.object_id = col.object_id
        left join sys.types as t
            on col.user_type_id = t.user_type_id
        left join sys.default_constraints as def
            on def.object_id = col.default_object_id
        left join (
                  select index_columns.object_id, 
                         index_columns.column_id
                    from sys.index_columns
                         inner join sys.indexes 
                             on index_columns.object_id = indexes.object_id
                            and index_columns.index_id = indexes.index_id
                   where indexes.is_primary_key = 1
                  ) as pk 
            on col.object_id = pk.object_id 
           and col.column_id = pk.column_id
        left join (
                  select fc.parent_column_id, 
                         fc.parent_object_id
                    from sys.foreign_keys as f 
                         inner join sys.foreign_key_columns as fc 
                             on f.object_id = fc.constraint_object_id
                   group by fc.parent_column_id, fc.parent_object_id
                  ) as fk
            on fk.parent_object_id = col.object_id 
           and fk.parent_column_id = col.column_id    
        left join (
                  select c.parent_column_id, 
                         c.parent_object_id, 
                         'Check' check_const
                    from sys.check_constraints as c
                   group by c.parent_column_id,
                         c.parent_object_id
                  ) as ch
            on col.column_id = ch.parent_column_id
           and col.object_id = ch.parent_object_id
        left join (
                  select index_columns.object_id, 
                         index_columns.column_id
                    from sys.index_columns
                         inner join sys.indexes 
                             on indexes.index_id = index_columns.index_id
                            and indexes.object_id = index_columns.object_id
                    where indexes.is_unique_constraint = 1
                    group by index_columns.object_id, 
                          index_columns.column_id
                  ) as uk
            on col.column_id = uk.column_id 
           and col.object_id = uk.object_id
        left join sys.extended_properties as ep 
            on tab.object_id = ep.major_id
           and col.column_id = ep.minor_id
           and ep.name = 'MS_Description'
           and ep.class_desc = 'OBJECT_OR_COLUMN'
        left join sys.computed_columns as cc
            on tab.object_id = cc.object_id
           and col.column_id = cc.column_id
		inner join dbo.[ddic_tDataTableDic] ddT on upper(ddT.Table_Name) = upper(tab.name)
	where  tab.name <> 'sysdiagrams'
  order by schema_name,
        table_name, 
        column_name;   

-- Create the list of relations between tables
insert into [dbo].[ddic_tRelations] (idPrimaryTable, idPrimaryCol, idTable, idColTable, constraint_name, join_condition, complex_fk)
select ddTP.id idPrimaryTable, ddCP.id idPrimaryCol, ddT.id idTable, ddC.id idColTable, 
		rel.constraint_name, rel.join_condition , rel.complex_fk
	from 
	(select schema_name(tab.schema_id) as table_schema_name,
		   tab.name as table_name,
		   col.name as column_name,
		   convert(varchar,fk.name) as constraint_name,
		   schema_name(tab_prim.schema_id) as primary_table_schema_name,
		   tab_prim.name as primary_table_name,
		   col_prim.name as primary_table_column, 
		   schema_name(tab.schema_id) + '.' + tab.name + '.' + 
				col.name + ' = ' + schema_name(tab_prim.schema_id) + '.' + 
				tab_prim.name + '.' + col_prim.name as join_condition,
		   case
				when count(*) over (partition by fk.name) > 1 then 'Y'
				else 'N'
		   end as complex_fk,
		   fkc.constraint_column_id as fk_part
	  from sys.tables as tab
		   inner join sys.foreign_keys as fk
			   on tab.object_id = fk.parent_object_id
		   inner join sys.foreign_key_columns as fkc
			   on fk.object_id = fkc.constraint_object_id
		   inner join sys.columns as col
			   on fkc.parent_object_id = col.object_id
			  and fkc.parent_column_id = col.column_id
		   inner join sys.columns as col_prim
			   on fkc.referenced_object_id = col_prim.object_id
			  and fkc.referenced_column_id = col_prim.column_id
		   inner join sys.tables as tab_prim
			   on fk.referenced_object_id = tab_prim.object_id
	 --order by table_schema_name, table_name, primary_table_name, fk_part
	) as rel
	inner join dbo.[ddic_tDataTableDic] ddT on upper(ddT.Table_Name) = upper(rel.table_name)
	inner join dbo.[ddic_tDataTableDic] ddTP on upper(ddTP.Table_Name) = upper(rel.primary_table_name)
	inner join [dbo].[ddic_tDataColumsDic] ddC on upper(ddC.column_name) = upper(rel.column_name) and upper(ddC.table_name) = upper(ddT.Table_Name)
	inner join [dbo].[ddic_tDataColumsDic] ddCP on upper(ddCP.column_name) = upper(rel.primary_table_column) and upper(ddCP.table_name) = upper(ddTP.Table_Name)

