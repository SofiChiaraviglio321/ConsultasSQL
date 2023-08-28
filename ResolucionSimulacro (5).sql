use [VETERINARIA 113857]

--1. Emitir un reporte del total cobrado por mes por cada médico en sus consultas. 
--Además, la cantidad de consultas realizadas, siempre que el promedio de importe 
--cobrado por mes sea
--mayor a $2.000.
--verificar joins 
select year(fecha), month(fecha),c.id_medico, apellido,sum(importe)Total,
		count(*)'Cant consultas'
from consultas c join medicos m on m.id_medico=c.id_medico
group by year(fecha), month(fecha),c.id_medico, apellido
having avg(importe)>2000

--Listar las consultas del mes pasado cuyo importe superaron el promedio 
--cobrado por consulta este mes.
--verificar joins 
select apellido medico, fecha, importe, detalle_consulta
from consultas c join medicos m on m.id_medico=c.id_medico
where datediff(month,fecha,getdate())=1
and importe > (select avg(importe)
				from consultas
				where datediff(month,fecha,getdate())=0)


--¿Cuánto fue el importe total cobrado por consultas el año pasado? 
--¿Cuánto fue el importe de la consulta más cara y la más barata --y cuánto fue el importe promedio por consulta?--verificar joins select sum(importe) as 'total', max(importe) as 'Mas cara',min(importe) as 'mas barata',		avg(importe) as 'promedio'from consultaswhere year(fecha)=year(getdate())-1--Mostrar en una misma tabla de resultados las mascotas que no vinieron nunca este año (en
--primer lugar) y las que viniero 10 veces este año en segundo lugar, ordenados en
--forma alfabética por nombre de mascota.--verificar joins select id_mascota nro,nombre mascota,  'No vino este año' Observacionesfrom mascotaswhere id_mascota not in (select id_mascota						from consultas						where year(fecha)=year(getdate())						)unionselect m.id_mascota,nombre, 'Vino mas de 10 veces este año'from mascotas m join consultas c on c.id_mascota=m.id_mascotawhere year(fecha)=year(getdate())group by m.id_mascota,nombrehaving count(*)>10order by 3,2--otra opcionselect nombre mascota, fec_nac nacimiento,'No vino este año' Observacionesfrom mascotas mwhere  not exists (select id_mascota						from consultas						where year(fecha)=year(getdate())						and id_mascota=m.id_mascota)unionselect nombre, fec_nac,'Vino màs de 10 veces este año'from mascotas mwhere 10<(select count(*)		from consultas 		where year(fecha)=year(getdate())		and m.id_mascota=id_mascota)order by 3,1--¿Cuánto pagó en total cada dueño por la atención de sus mascotas por año? 
--¿Cuándo fue el importe promedio y la fecha de la primera y última consulta? 
--Siempre y cuando el ese promedio pagado haya sido superior al promedio --de ese mismo año.--verificar joins select d.id_dueño, apellido ,year(fecha)año, sum(importe) total, 	avg(importe) promedio, min(fecha) '1erConsulta',max(fecha)'ultima consulta'from dueños d join mascotas m on m.id_dueño=d.id_dueño     join consultas c on c.id_mascota=m.id_mascotagroup by d.id_dueño, apellido,year(c.fecha)having avg(importe)>(select avg(importe) 					from consultas					where year(fecha)=year(c.fecha)					)--TEMA 2--Emitir un listado de todos los dueños incluyendo el nombre del barrio que 
--pagaron más de $1000 en consultas en los últimos 3 meses.--verificar joins select * --incluir todos los campos necesariosfrom dueños d--joinear con barrioswhere  1000 < (select sum(importe)				from consultas c join mascotas m on c.id_mascota=m.id_mascota				where datediff(month,fecha,getdate())<=3				and m.id_dueño=d.id_dueño)--otra solucionselect d.id_dueño,d.nombre, barrio, sum(importe) 'importe total'from dueños d join barrios b on d.id_barrio=b.id_barriojoin mascotas m on d.id_dueño=m.id_dueñojoin consultas c on m.id_mascota=c.id_mascotawhere datediff(month,fecha,getdate())<=3group by d.id_dueño,d.nombre, barriohaving sum(importe)>1000--Listar los dueños que vinieron más de 3 veces el año pasado--verificar joins select d.id_dueño,d.nombre, count(*) 'veces que vino'from dueños d join mascotas m on d.id_dueño=m.id_dueñojoin consultas c on c.id_mascota=m.id_mascotawhere year(fecha)=year(getdate())-1group by d.id_dueño,d.nombrehaving count(*)>3--otraselect * --incluir todos los campos necesariosfrom dueños dwhere  3 < (select count(*)				from consultas c join mascotas m on c.id_mascota=m.id_mascota				where datediff(year,fecha,getdate())=1				and m.id_dueño=d.id_dueño)--¿Cuáles es el médico que atendió más consultas este año?--verificar joins select top 1 c.id_medico,apellido,nombre,count(*) 'Cant.consultas'from consultas c join medicos m on c.id_medico=m.id_medicowhere datediff(year,fecha,getdate())=0group by c.id_medico,apellido,nombreorder by 4 desc--Preguntas 4 y 5 son iguales que tema 1 