/*
Consulta #1
Desplegar para cada elección el país y el partido político que obtuvo mayor
porcentaje de votos en su país. Debe desplegar el nombre de la elección, el
año de la elección, el país, el nombre del partido político y el porcentaje que
obtuvo de votos en su país.
*/
select l.nombre as EleccionNombre,l.anio as AnioEleccion,p.nombre as PartidoNombre, pa.nombre as Pais, sum(c.universitarios)+ sum(c.alfabeto)+ sum(c.analfabeto)+ sum(c.primaria)+ sum(c.nivel_medio) as total, round(((sum(c.universitarios)+ sum(c.alfabeto)+ sum(c.analfabeto)+ sum(c.primaria)+ sum(c.nivel_medio))*100)/temp.total,2) as Promedio
from eleccionpartido el , eleccion l , partido p, pais pa, conteoVoto c, municipio m, departamento d, region r,
(
    select l.nombre as EleccionNombre,l.anio as AnioEleccion, pa.nombre as Pais, sum(c.universitarios)+ sum(c.alfabeto)+ sum(c.analfabeto)+ sum(c.primaria)+ sum(c.nivel_medio) as total
    from eleccionpartido el , eleccion l , partido p, pais pa, conteoVoto c, municipio m, departamento d, region r
    where el.ideleccion = l.ideleccion and el.idpartido = p.idpartido and c.idpartido = p.idpartido
    and c.idmunicipio = m.idmunicipio and m.iddepartamento = d.iddepartamento and d.idregion = r.idregion and r.idpais = pa.idpais 
    group by l.nombre, l.anio, pa.nombre
    order by  pa.nombre
)  temp
where el.ideleccion = l.ideleccion and el.idpartido = p.idpartido and c.idpartido = p.idpartido
and c.idmunicipio = m.idmunicipio and m.iddepartamento = d.iddepartamento and d.idregion = r.idregion and r.idpais = pa.idpais 
and temp.pais = pa.nombre
group by l.nombre, l.anio, p.nombre, pa.nombre,temp.total
order by  pa.nombre asc
;

/*
Consulta #2
Desplegar total de votos y porcentaje de votos de mujeres por
departamento y país. El ciento por ciento es el total de votos de mujeres por
país. (Tip: Todos los porcentajes por departamento de un país deben sumar
el 100%)
*/
select p.nombre, d.nombre as Departamento,sum(cot.alfabeto)+ sum(cot.analfabeto) as totalVotos, round(((sum(cot.alfabeto)+ sum(cot.analfabeto))*100)/temp.total,2) as Porcentaje
from conteoVoto cot,departamento d, region r, pais p, municipio m,
(
    select pais.nombre as pais, (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as total
    from conteoVoto ,departamento , region , pais , municipio 
    where conteoVoto.idSexo = 22 and conteoVoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and departamento.idregion = region.idregion and region.idpais = pais.idpais
    group by pais.nombre
    order by pais.nombre asc
) temp
where cot.idSexo = 22 and cot.idmunicipio = m.idmunicipio and m.iddepartamento = d.iddepartamento and d.idregion = r.idregion and r.idpais = p.idpais
and p.nombre = temp.pais
group by p.nombre, d.nombre, temp.total
order by p.nombre asc;

/*
Consulta #3
Desplegar el nombre del país, nombre del partido político y número de
alcaldías de los partidos políticos que ganaron más alcaldías por país.
*/
select tempt.pais,tempt.partido,tempt.total as Alcaldias_Ganadas from (
    select  ROW_NUMBER() OVER (
                PARTITION BY tempglobal.pais
                ORDER BY tempglobal.total DESC) row_num, tempglobal.pais,tempglobal.partido,tempglobal.total from(
    select temp3.pais,temp3.partido,count(temp3.partido)  as Total from(
    select temp1.pais,temp1.municipio,max(temp1.total) as Total from(
    select pais.nombre as Pais, partido.nombre as Partido,municipio.nombre as Municipio,(sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteovoto,municipio,departamento,region,pais, partido
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and region.idpais = pais.idpais and conteovoto.idpartido = partido.idpartido
    group by pais.nombre,partido.nombre, municipio.nombre
    )temp1
    group by temp1.municipio,temp1.pais
    )temp2,(
        select pais.nombre as Pais, partido.nombre as Partido,municipio.nombre as Municipio,(sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
        from conteovoto,municipio,departamento,region,pais, partido
        where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
        and departamento.idregion = region.idregion and region.idpais = pais.idpais and conteovoto.idpartido = partido.idpartido
        group by pais.nombre,partido.nombre, municipio.nombre
    )temp3
    where temp2.pais  = temp3.pais and temp2.municipio = temp3.municipio and temp2.total = temp3.total
    group by temp3.pais,temp3.partido
    order by pais desc
)tempglobal
)tempt
where row_num = 1
order by total desc
;

/*
Consulta #4
Desplegar todas las regiones por país en las que predomina la raza indígena.
Es decir, hay más votos que las otras razas.
*/
select tempx.pais,tempx.region,tempx.total,tempz.raza from(
    select pais,region,max(total) as Total from(
    select pais.nombre as Pais, raza.nombre as Raza,region.nombre as Region,sum(conteovoto.alfabeto)+ sum(conteovoto.analfabeto) as total
    from conteovoto,municipio,departamento,region,pais,raza
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and
    departamento.idregion = region.idregion and region.idpais = pais.idpais and raza.idraza = conteovoto.idraza
    group by pais.nombre,raza.nombre,region.nombre
    order by pais
)temp1
group by pais,region
)tempx,(
    select pais,region,raza,(total) as Total from(
    select pais.nombre as Pais, raza.nombre as Raza,region.nombre as Region,sum(conteovoto.alfabeto)+ sum(conteovoto.analfabeto) as total
    from conteovoto,municipio,departamento,region,pais,raza
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and
    departamento.idregion = region.idregion and region.idpais = pais.idpais and raza.idraza = conteovoto.idraza
    group by pais.nombre,raza.nombre,region.nombre
    order by pais
)temp1
where raza = 'INDIGENAS'
group by pais,region,raza,total
)tempz
where tempx.pais = tempz.pais
and tempx.region = tempz.region
and tempx.total = tempz.total;
/*
Consulta #5
Desplegar el porcentaje de mujeres universitarias y hombres universitarios
que votaron por departamento, donde las mujeres universitarias que
votaron fueron más que los hombres universitarios que votaron.
*/

select mujeres2.depto, mujeres2.porcentaje as Mujeres, hombres2.porcentaje as Hombres from (
    select mujeres.depto as depto,round((mujeres.total*100)/total.total,2) as Porcentaje from(
    select pais.nombre as Pais,departamento.nombre as Depto,(sum(conteovoto.universitarios)) as Total
    from conteovoto,municipio,departamento,region,pais
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and
    departamento.idregion = region.idregion and region.idpais = pais.idpais    
    and conteovoto.idsexo = 22
    group by pais.nombre,departamento.nombre
)mujeres,(
    select pais, depto,sum(total) as Total from(
        select pais.nombre as Pais,departamento.nombre as depto,(sum(conteovoto.alfabeto)+sum(conteovoto.analfabeto)) as Total
        from conteovoto,municipio,departamento,region,pais
        where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and
        departamento.idregion = region.idregion and region.idpais = pais.idpais
        group by pais.nombre,departamento.nombre
    )
    group by pais,depto
)total
where mujeres.pais = total.pais and mujeres.depto = total.depto
)mujeres2,(
    select hombres.depto depto,round((hombres.total*100)/total.total,2) as Porcentaje from(
    select pais.nombre as Pais,departamento.nombre as Depto,(sum(conteovoto.universitarios)) as Total
    from conteovoto,municipio,departamento,region,pais
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento and
    departamento.idregion = region.idregion and region.idpais = pais.idpais    
    and conteovoto.idsexo = 21
    group by pais.nombre,departamento.nombre
)hombres,(
    select pais, depto,sum(total) as Total from(
        select pais.nombre as Pais,departamento.nombre as depto,(sum(conteovoto.alfabeto)+sum(conteovoto.analfabeto)) as Total
        from conteovoto
        inner join municipio on conteovoto.idmunicipio = municipio.idmunicipio
        inner join departamento on departamento.iddepartamento = municipio.iddepartamento      
        inner join region on departamento.idregion  = region.idregion
        inner join pais on pais.idpais = region.idpais
        group by pais.nombre,departamento.nombre
    )
    group by pais,depto
)total
where hombres.pais = total.pais and hombres.depto = total.depto
)hombres2
where mujeres2.porcentaje > hombres2.porcentaje
and mujeres2.depto = hombres2.depto;
/*
Consulta #6
Desplegar el nombre del país, la región y el promedio de votos por
departamento. Por ejemplo: Si la región tiene tres departamentos, se debe
sumar todos los votos de la región y dividirlo dentro de tres (número de
departamentos de la región).
*/
select temp1.pais,temp1.region, round(sum(temp1.total)/ count(temp1.region),3) as Promedio from(
    select pais.nombre as Pais ,region.nombre AS Region ,departamento.nombre as Departamento , sum (conteovoto.alfabeto) as Total
    from conteovoto,municipio,departamento,region,pais
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and region.idpais = pais.idpais
    group by pais.nombre,region.nombre,departamento.nombre
)temp1
group by temp1.pais,temp1.region;
/*
Consulta #7
Desplegar el nombre del municipio y el nombre de los dos partidos políticos
con más votos en el municipio, ordenados por país.
*/
select pais,municipio,partido,total from(
select temp1.pais,temp1.municipio,temp1.partido,temp1.total, ROW_NUMBER() OVER (
            PARTITION BY temp1.municipio
            ORDER BY temp1.total DESC) row_num   from(
select pais.nombre as Pais,municipio.nombre as Municipio,partido.nombre as Partido,(sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteovoto,municipio,departamento,region,pais , partido
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and region.idpais = pais.idpais
    and conteovoto.idpartido = partido.idpartido
    group by pais.nombre,municipio.nombre,partido.nombre,pais.nombre,departamento.nombre
    order by total desc
)temp1
)tempz
where tempz.row_num = 1 or tempz.row_num = 2
order by municipio, pais;

/*
Consulta #8
Desplegar el total de votos de cada nivel de escolaridad (primario, medio,
universitario) por país, sin importar raza o sexo.
*/
select pais.nombre as Pais, sum(conteovoto.primaria) as Primaria, sum(conteovoto.nivel_medio) as NivelMedio, sum(conteovoto.universitarios) as Universitarios 
from conteoVoto, municipio,departamento,region,pais
where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
and departamento.idregion = region.idregion and pais.idpais = region.idpais
group by pais.nombre;
/*
Consulta #9
Desplegar el nombre del país y el porcentaje de votos por raza
*/
select temp1.pais, temp1.raza , round((temp1.total*100)/temp2.total,2) AS Porcentaje from (
    select pais.nombre as Pais,raza.nombre as Raza, (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais,raza
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
    and conteoVoto.idraza = raza.idraza
    group by pais.nombre,raza.nombre
    order by pais.nombre
)temp1,(
    select pais.nombre as Pais, (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais
    where conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
    group by pais.nombre
)temp2
where temp1.pais = temp2.pais
;
/*
Consulta #10
Desplegar el nombre del país en el cual las elecciones han sido más
peleadas. Para determinar esto se debe calcular la diferencia de porcentajes
de votos entre el partido que obtuvo más votos y el partido que obtuvo
menos votos. (La diferencia más pequeña).
*/
select * from(
    select mayor.pais, mayor.total - menor.total as Total from(
    select pais as Pais,partido as Partido,total as Total from (
        select pais,partido, total, ROW_NUMBER() OVER (
                    PARTITION BY temp.pais
                    ORDER BY temp.total DESC) row_num
        from(
            select pais.nombre as Pais,partido.nombre as Partido,sum(conteovoto.alfabeto)+sum(conteovoto.analfabeto) as Total
            from conteoVoto, municipio,departamento,region,pais,partido
            where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
            and departamento.idregion = region.idregion and pais.idpais = region.idpais and conteovoto.idpartido = partido.idpartido
            GROUP BY pais.nombre,partido.nombre
        )temp
)
where row_num = 1
)mayor,(
        select pais as Pais,partido as Partido,total as total from (
        select pais,partido, total, ROW_NUMBER() OVER (
                    PARTITION BY temp.pais
                    ORDER BY temp.total ASC) row_num
        from(
            select pais.nombre as Pais,partido.nombre as Partido,sum(conteovoto.alfabeto)+sum(conteovoto.analfabeto) as Total
            from conteoVoto, municipio,departamento,region,pais,partido
            where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
            and departamento.idregion = region.idregion and pais.idpais = region.idpais and conteovoto.idpartido = partido.idpartido
            GROUP BY pais.nombre,partido.nombre
        )temp
    )
    where row_num = 1
)menor
where mayor.pais = menor.pais
order by total asc
)
where ROWNUM = 1

;
/*
Consulta #11
Desplegar el total de votos y el porcentaje de votos emitidos por mujeres
indígenas alfabetas.
*/
select temp1.total as TotalVotos,round((temp1.total * 100)/temp2.total,3) As Porcentaje from(
    select sum(conteovoto.alfabeto) AS Total
    from conteoVoto, municipio,departamento,region,pais,partido, raza,sexo
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais and conteovoto.idpartido = partido.idpartido
    and conteovoto.idraza = raza.idraza and conteovoto.idsexo = sexo.idsexo
    and raza.idraza= 21 and sexo.idsexo = 22
)temp1,(
    select  (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
)temp2
;
/*
Consulta #12
Desplegar el nombre del país, el porcentaje de votos de ese país en el que
han votado mayor porcentaje de analfabetas. (tip: solo desplegar un nombre
de país, el de mayor porcentaje).
*/
select temp1.pais, temp1.total,round((temp1.total * 100)/temp2.total,3) As Porcentaje from(
    select pais.nombre as Pais,sum(conteovoto.analfabeto) AS Total
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
    group by pais.nombre
)temp1,(
    select  (sum(conteoVoto.analfabeto)+ sum(conteovoto.alfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
)temp2
order by Porcentaje desc
;
/*
Consulta #13
Desplegar la lista de departamentos de Guatemala y número de votos
obtenidos, para los departamentos que obtuvieron más votos que el
departamento de Guatemala.
*/
select temp1.pais,temp1.departamento,temp1.total from(
    select pais.nombre as Pais,departamento.nombre as Departamento, (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
    and pais.nombre = 'GUATEMALA'
    group by pais.nombre,departamento.nombre
    order by total desc
)temp1,(
select pais.nombre as Pais,departamento.nombre as Departamento, (sum(conteoVoto.alfabeto)+ sum(conteoVoto.analfabeto)) as Total
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
    and pais.nombre = 'GUATEMALA' and departamento.nombre = 'Guatemala'
    group by pais.nombre,departamento.nombre
)temp2
where temp1.total > temp2.total;
/*
Consulta #14
Desplegar el total de votos de los municipios agrupados por su letra inicial.
Es decir, agrupar todos los municipios con letra A y calcular su número de
votos, lo mismo para los de letra inicial B, y así sucesivamente hasta la Z.
*/
select temp1.letra, (sum(temp1.alfabeto)+ sum(temp1.analfabeto)) as Total from(
    select municipio.nombre,SUBSTR(municipio.nombre,1,1) As letra,conteovoto.alfabeto as alfabeto,conteovoto.analfabeto as analfabeto, conteovoto.nivel_medio as nivel_medio, conteovoto.primaria as primaria, conteovoto.universitarios as universitarios
    from conteoVoto, municipio,departamento,region,pais
    where  conteovoto.idmunicipio = municipio.idmunicipio and municipio.iddepartamento = departamento.iddepartamento
    and departamento.idregion = region.idregion and pais.idpais = region.idpais
)temp1
group by temp1.letra
order by temp1.letra;