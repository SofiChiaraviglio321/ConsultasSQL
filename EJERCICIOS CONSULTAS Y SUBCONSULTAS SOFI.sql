select f.cod_cliente'Cliente',f.cod_vendedor 'Vendedor',f.fecha'Fecha',a.descripcion'Articulo',a.pre_unitario'Precio',df.cantidad'Cantidad'
from facturas f join detalle_facturas df on df.nro_factura=f.nro_factura join articulos a on a.cod_articulo=df.cod_articulo
where 1500<(select sum(dfe.pre_unitario*dfe.cantidad)
				from facturas fa join detalle_facturas dfe on fa.nro_factura=dfe.nro_factura where fa.nro_factura=f.nro_factura)


--Se quiere saber qué vendedores nunca atendieron a estos clientes: 1 y 6.
--Muestre solamente el nombre del vendedor. 

select v.ape_vendedor+''+v.nom_vendedor'Vendedor'
from vendedores v
where not exists(select * from vendedores ve join facturas f on f.cod_vendedor=ve.cod_vendedor where f.cod_vendedor=v.cod_vendedor and f.cod_cliente in(1,6))


--¿Qué artículos nunca se vendieron? Tenga además en cuenta que su
--nombre comience con letras que van de la “d” a la “p”. Muestre solamente
--la descripción del artículo.

select a.descripcion'Articulo',a.cod_articulo'Codigo'
from articulos a
where not exists(select * from detalle_facturas df where a.cod_articulo=df.cod_articulo )
and a.descripcion like '[d-p%]'

--Listar número de factura, fecha y cliente para los casos en que ese cliente
--haya sido atendido alguna vez por el vendedor de código 3. 

select c.ape_cliente+''+c.nom_cliente'Cliente',f.nro_factura'nroFactu',F.fecha'Fecha'
from facturas f join clientes c on c.cod_cliente=f.cod_cliente
where 3=any(select fa.cod_vendedor
			from facturas fa where fa.cod_cliente=f.cod_cliente)
-------------------------------------------------------------------------------------Having---------------------------------------------------------------------------------------------------------------------
-----Por cada artículo que se tiene a la venta, se quiere saber el importe
------promedio vendido, la cantidad total vendida por artículo, para los casos
--en que los números de factura no sean uno de los siguientes: 2, 10, 7, 13,
--22 y que ese importe promedio sea inferior al importe promedio de ese
--artículo.


select a.cod_articulo,sum(cantidad*d.pre_unitario)/count(distinct d.nro_factura)
promedio,
sum(cantidad) 'cant. total'
from facturas f join detalle_facturas d on f.nro_factura=d.nro_factura
join articulos a on a.cod_articulo=d.cod_articulo
where f.nro_factura not In (2, 10, 7, 13,22)
group by a.cod_articulo
having sum(d.cantidad*d.pre_unitario)/count(distinct d.nro_factura)<
(select sum(d1.cantidad*d1.pre_unitario)/count(distinct d1.nro_factura)
from detalle_facturas d1
where d1.cod_articulo=a.cod_articulo)


--5-Se quiere saber el promedio del importe vendido y la fecha de la primer
--venta por fecha y artículo para los casos en que las cantidades vendidas
--oscilen entre 5 y 20 y que el importe total (por fecha y articulo)
-- sea superior al importe promedio
--de ese artículo

select df.cod_articulo'Arituclo', avg(df.nro_factura*df.cantidad)'Prom IMp Vend',min(f.fecha)'Primer venta'
from  facturas f join detalle_facturas df on f.nro_factura=df.nro_factura
where df.cantidad between 5 and 20 
group by f.fecha,df.cod_articulo

having 
sum(df.pre_unitario*df.cantidad)>(select avg(dfa.pre_unitario*dfa.cantidad)
									from detalle_facturas dfa 
									where dfa.cod_articulo=df.cod_articulo)



select fecha,d.cod_articulo,sum(cantidad*d.pre_unitario)/count(distinct d.nro_factura) promedio,min(fecha) '1er.vta'

from detalle_facturas d join facturas f on f.nro_factura=d.nro_factura

where cantidad between 5 and 20

group by fecha,d.cod_articulo

having sum(cantidad*d.pre_unitario)>(select sum(cantidad*d1.pre_unitario)/count(distinct d1.nro_factura)
										from detalle_facturas d1
										where d1.cod_articulo=d.cod_articulo)