use [VETERINARIA 113857]

--1. Emitir un reporte del total cobrado por mes por cada m�dico en sus consultas. 
--Adem�s, la cantidad de consultas realizadas, siempre que el promedio de importe 
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


--�Cu�nto fue el importe total cobrado por consultas el a�o pasado? 
--�Cu�nto fue el importe de la consulta m�s cara y la m�s barata 
--primer lugar) y las que viniero 10 veces este a�o en segundo lugar, ordenados en
--forma alfab�tica por nombre de mascota.
--�Cu�ndo fue el importe promedio y la fecha de la primera y �ltima consulta? 
--Siempre y cuando el ese promedio pagado haya sido superior al promedio 
--pagaron m�s de $1000 en consultas en los �ltimos 3 meses.