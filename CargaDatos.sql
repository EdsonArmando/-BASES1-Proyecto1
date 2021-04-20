/*Carga de paises*/
insert into Pais(nombre)
select carga.pais
from carga
group by carga.pais;
/*
Carga de Regiones
*/
insert into Region(idPais,nombre)
select pais.idpais,carga.region
from carga, pais 
where carga.pais = pais.nombre
group by pais.idpais,carga.region;
/*
Carga de Departamentos
*/
insert into Departamento(idRegion,nombre)
select region.idregion,carga.depto
from carga, region, pais
where carga.pais = pais.nombre and carga.region = region.nombre and region.idpais = pais.idpais
group by  region.idregion,carga.depto;
/*
Carga de Municipio
*/
insert into Municipio(idDepartamento,nombre)
select departamento.iddepartamento,carga.municipio
from carga,departamento
where carga.depto = departamento.nombre
group by departamento.iddepartamento,carga.municipio;
/*
Carga de Elecciones
*/
insert into Eleccion(nombre,anio)
select carga.nombre_eleccion, carga.anio_eleccion
from carga
group by  carga.nombre_eleccion, carga.anio_eleccion;
/*
Carga de Partido
*/
insert into Partido(partido,nombre)
select carga.partido, carga.nombre_partido
from carga
group by carga.partido, carga.nombre_partido;
/*
Carga de EleccionPartido
*/
insert into EleccionPartido(idEleccion,idPartido)
select (select eleccion.ideleccion from eleccion where carga.nombre_eleccion = eleccion.nombre and carga.anio_eleccion = eleccion.anio) as EleccionI , (select partido.idpartido from partido where carga.partido = partido.partido and carga.nombre_partido = partido.nombre ) as PartidoI
from carga
group by carga.nombre_eleccion, carga.anio_eleccion, carga.partido, carga.nombre_partido;
/*
Carga de Sexo
*/
insert into Sexo(nombre)
select carga.sexo
from carga
group by carga.sexo;
/*
Carga de Raza
*/
insert into Raza(nombre)
select carga.raza
from carga
group by carga.raza;
/*
Carga de ConteoVotos
*/
insert into conteoVoto(alfabeto,analfabeto,primaria,nivel_medio,universitarios,idraza,idsexo,idmunicipio,idpartido)
select carga.alfabetos, carga.analfabetos, carga.primaria, carga.nivel_medio, carga.universitarios, raza.idraza, sexo.idsexo, municipio.idmunicipio,partido.idpartido
from raza, carga, sexo,departamento, municipio, partido
where carga.raza = raza.nombre and carga.sexo = sexo.nombre and carga.depto = departamento.nombre and carga.municipio = municipio.nombre and 
departamento.iddepartamento = municipio.iddepartamento
and carga.nombre_partido = partido.nombre and carga.partido = partido.partido
