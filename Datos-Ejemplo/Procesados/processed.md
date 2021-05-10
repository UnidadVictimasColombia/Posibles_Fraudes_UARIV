## Lista de datasets procesados
Los dataset Usados en Ms Azure DataFactory para el proyecto fueron:
a. dsAzTAsesoresAbogadosOAJ: Extracción de la información de los abogados que gestionan los posibles casos de hechos irregulares
b. dsAztCruceSIPOD: Extracción de la información base de las vícitmas reportadas por la Oficina Asesora Jurídica(OAJ) de la Unidad contra SIPOD, Sistema Infomración de la Población Desplazada
c. dsAzEstadoFraudes: Separación y catalogación de los tipos de noticias judiciales reportadas en la base de datos de excel de la OAJ, relacionada con cada uno de los demandados.
d. dsAzTTipoCaso: Extracción de las categorías de noticias judiciales
e. dsAzTtipoCasosXFraude: extracción de datos para el cruce entre las categorías de noticias judiciales y los posibles casos de fraude o hechos irregulares
f. dsOAJ: Importación de datos de la base de datos de Excel a la BD de SQL Azure
g. dstBDOAJ: Base de datos origen ajustada por dataset dsPersonasAjustadas, con separación de nombres y apellidos en campos diferentes
