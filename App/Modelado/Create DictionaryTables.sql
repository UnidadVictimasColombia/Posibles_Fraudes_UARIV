/****** Object:  Table [ddic].[tDataTableDic]    Script Date: 26/01/2021 12:18:32 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ddic_tDataTableDic](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Schema_Name] [varchar](50) NOT NULL,
	[Table_Name] [varchar](50) NOT NULL,
	[Created] [datetime] NULL,
	[Last_Modified] [datetime] NULL,
	[Table_Desc] [varchar](max) NULL,
	[Num_Rows] [int] NOT NULL,
	[Comments] [varchar](max) NULL,
 CONSTRAINT [PK_tDataTableDic] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO



/****** Object:  Table [ddic].[tDataColumsDic]    Script Date: 26/01/2021 12:18:16 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ddic_tDataColumsDic](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[schema_name] [varchar](50) NOT NULL,
	[table_name] [varchar](50) NOT NULL,
	[column_name] [varchar](50) NOT NULL,
	[data_type] [varchar](50) NOT NULL,
	[data_type_length] [varchar](10) NOT NULL,
	[nullable] [nchar](1) NOT NULL,
	[default_value] [varchar](50) NOT NULL,
	[primary_key] [nchar](2) NOT NULL,
	[foreign_key] [nchar](2) NOT NULL,
	[unique_key] [nchar](2) NOT NULL,
	[check_contraint] [varchar](50) NOT NULL,
	[comments] [varchar](max) NOT NULL,
 CONSTRAINT [PK_tDataColumsDic] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


