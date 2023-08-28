 --Cree una vista que liste la fecha, la factura, el código y nombre del vendedor, el
--artículo, la cantidad e importe, para lo que va del año. Rotule como FECHA,
--NRO_FACTURA, CODIGO_VENDEDOR, NOMBRE_VENDEDOR, ARTICULO,
--CANTIDAD, IMPORTE.


alter view vista_facturas
as
select f.fecha 'FECHA',f.nro_factura'NRO_FACTURA',v.cod_vendedor'CODIGO_VENDEDOR',v.ape_vendedor+''+v.nom_vendedor'NOMBRE_VENDEDOR',a.descripcion'ARTICULO',df.cantidad'CANTIDAD',df.pre_unitario'IMPORTE'
from facturas f join detalle_facturas df on df.nro_factura=f.nro_factura join vendedores v on v.cod_vendedor=f.cod_vendedor join articulos a on a.cod_articulo=df.cod_articulo
where year(fecha)=year(getdate())-1

select * from vista_facturas


--3. Modifique la vista creada en el punto anterior, agréguele la condición de que
--solo tome el mes pasado (mes anterior al actual) y que también muestre la
--dirección del vendedor

alter view vista_facturas
as
select f.fecha 'FECHAs',f.nro_factura'NRO_FACTURAs',v.cod_vendedor'CODIGO_VENDEDORs',v.ape_vendedor+''+v.nom_vendedor'NOMBRE_VENDEDORs',a.descripcion'ARTICULOs',df.cantidad'CANTIDADs',df.pre_unitario'IMPORTEs', v.calle+'Nº'+str(v.altura)+'bº'+b.barrio 'Direccion'
	   
from facturas f join detalle_facturas df on df.nro_factura=f.nro_factura join vendedores v on v.cod_vendedor=f.cod_vendedor join articulos a on a.cod_articulo=df.cod_articulo join barrios b on b.cod_barrio=v.cod_barrio
where year(f.fecha)=year(getdate())-1 and DATEDIFF(month,f.fecha,getdate())=6

---4. Consulta las vistas según el siguiente detalle:
  --a. Llame a la vista creada en el punto anterior pero filtrando por importes
  --  inferiores a $120.

  select FECHAs,NRO_FACTURAs,CODIGO_VENDEDORs,NOMBRE_VENDEDORs,ARTICULOs,CANTIDADs,IMPORTEs,Direccion
  from vista_facturas vs
  where IMPORTEs<120
  -- b. Llame a la vista creada en el punto anterior filtrando para el vendedor
--Miranda.

  select FECHAs,NRO_FACTURAs,CODIGO_VENDEDORs,NOMBRE_VENDEDORs,v.ape_vendedor'Apellido',CANTIDADs,IMPORTEs,Direccion
   from vista_facturas vs join vendedores v on v.cod_vendedor=vs.CODIGO_VENDEDORs
  where v.ape_vendedor like '%Miranda%'

  --Crear un procedimiento almacenado que muestre la descripción de un
--artículo de código determinado (enviado como parámetro de entrada) y nos retorne
--el total facturado para ese artículo y el promedio ponderado de los precios de venta
--de ese artículo

create proc sp_articulos
@codigo int,
@totalFac decimal(10,2) output,
@promediopond decimal(10,2)output
as
select a.descripcion'Descripcion'
from articulos a 
where a.cod_articulo=@codigo
select @totalFac=sum(df.pre_unitario)
			   from detalle_facturas df
			   where df.cod_articulo=@codigo

select @promediopond=sum(df.pre_unitario)/sum(df.cantidad)
from detalle_facturas df
where df.cod_articulo=@codigo



declare @totfac decimal(10,2),@prome decimal(10,2)
execute sp_articulos 1,@totfac output,@prome output
select @totfac 'Total facturado',@prome 'Promedio ponderado'



-1.CREE LOS SIGUIENTES SP:

--a. Detalle_Ventas: liste la fecha, la factura, el vendedor, el cliente, el
--artículo, cantidad e importe. Este SP recibirá como parámetros de E un
--rango de fechas.

create proc facturacionFechas
@fecha1 datetime,
@fecha2 datetime
as
select f.fecha 'Fecha',df.nro_factura'Factura',ape_vendedor+''+nom_vendedor'vendedor',ape_cliente+''+nom_cliente'Cliente',ar.descripcion'Articulo',cantidad'Cnatidad',df.pre_unitario'Importe'
from facturas f join detalle_facturas df on df.nro_factura=f.nro_factura
     join articulos ar on ar.cod_articulo=df.cod_articulo 
	 join clientes c on c.cod_cliente=f.cod_cliente 
	 join vendedores v on v .cod_vendedor=f.cod_vendedor
	 where f.fecha between @fecha1 and @fecha2

	 execute facturacionFechas '01/02/2020','01/02/2021'

--b. CantidadArt_Cli : este SP me debe devolver la cantidad de artículos o
--clientes (según se pida) que existen en la empresa.


create proc articulosoclientes
@tipo varchar(50)
as

if @tipo='cliente'
begin 
select count(*)
from clientes c
end
if @tipo='vendedor'
begin
select count(*)
from vendedores
end

execute articulosoclientes 'Cliente'

 --Dia_Habil: función que devuelve si un día es o no hábil (considere
--como días no hábiles los sábados y domingos). Debe devolver 1
--(hábil), 0 (no hábil)


create function f_diaHabilNo
(@fecha datetime)
returns int
as
begin 
declare @salida int ,@nombre varchar(50)
set @nombre= datename(WEEKDAY,@fecha)
if @nombre='sabado' or @nombre='domingo'
set @salida=0
else
set @salida =1

return @salida
end


--4)Crear una función que calcule la edad de una persona. Emita un listado donde muestre  los  datos  de  los  vendedores  y  la  edad  utilizando  la  función  creada, además muestra a qué clientes de este año.

create function f_edadpersona
(@fecha datetime )
returns int
as
begin
declare @edad int
set @edad=datediff(year,@fecha,getdate())
return @edad
end

select v.ape_vendedor+''+v.nom_vendedor'Vendedor',dbo.f_edadpersona(v.fec_nac)'Edad',c.cod_cliente'Cliente'
from vendedores v join facturas f on f.cod_vendedor=v.cod_vendedor join clientes c on c.cod_cliente=f.cod_cliente

--5)Cree  una  función  que  devuelva  un  número  aumentado  o  disminuido  en  un porcentaje dado. Utilice la función para actualizar los precios de los artículos en un 3,5%

create function f_numeroaumento
(@precio decimal(10,2),
 @porcentaje decimal(10,2))

returns decimal(10,2)
as
begin 

return @precio+@precio*@porcentaje/100
end


update articulos set pre_unitario=dbo.f_numeroaumento(pre_unitario,3.5)




																				--Guardar errores en un tabla--


	create table #ERRORES
	( error_linee int,
	  error_messagee varchar(200),
	  error_numberr int,
	  error_severityy int,
	  erorr_satee int)

	  begin try
	  insert into barrios values (1,'Holaa')
	  end try
	  begin catch
	  print str(error_number())+''+'El codigo de barrio ya existe'

	  insert into #ERRORES values(error_line(),error_message(),error_number(),error_severity(),error_state())
	  end catch

	  select * from #ERRORES


--1. Declarar 3 variables que se llamen codigo, stock y stockMinimo
--respectivamente. A la variable codigo setearle un valor. Las variables stock y
--stockMinimo almacenarán el resultado de las columnas de la tabla artículos
--stock y stockMinimo respectivamente filtradas por el código que se
--corresponda con la variable codigo.


declare @codigo int,@stock int,@stockminimo int

set @codigo=1

set @stock=(select a.stock
			from articulos a
			where a.cod_articulo=@codigo)
set @stockminimo=(select a.stock_minimo
					from articulos a
					where cod_articulo=@codigo)
select @codigo,@stock,@stockminimo

---2. Utilizando el punto anterior, verificar si la variable stock o stockMinimo tienen
--algún valor. Mostrar un mensaje indicando si es necesario realizar reposición
--de artículos o no.

declare @codigo int,@stock int,@stockminimo int

set @codigo=1

set @stock=(select a.stock
			from articulos a
			where a.cod_articulo=@codigo)
set @stockminimo=(select a.stock_minimo
					from articulos a
					where cod_articulo=@codigo)
begin
select @codigo,@stock,@stockminimo
if @stock<@stockminimo

select 'Debe realizar reposicion del articulo codigo'+str(@codigo);

else 
if @stock is null or @stockminimo is null
select  'No hay datos suficientes del articulo codigo'+str(@codigo);
end


---3. Modificar el ejercicio 1 agregando una variable más donde se almacene el
--precio del artículo. En caso que el precio sea menor a $500, aplicarle un
--incremento del 10%. En caso de que el precio sea mayor a $500 notificar dicha
--situación y mostrar el precio del artículo.

declare @codigo int, @stock int,@stockminimo int,@precioart decimal(10,2)
set @codigo=2
select @stock=a.stock,@stockminimo=a.stock_minimo,@precioart=a.pre_unitario
from articulos a
begin

if @stock<@stockminimo

select 'Debe realizar reposicion del articulo codigo'+str(@codigo);

else
if @stock is null or @stockminimo is null
select  'No hay datos suficientes del articulo codigo'+str(@codigo);

if @precioart<500
update articulos set pre_unitario=@precioart+@precioart*10/100 where articulos.cod_articulo=@codigo
else
select 'El precio es mayor a 500:'+str(@precioart)
end



-- Modificar el punto 2 reemplazando el mensaje de que es necesario reponer
----artículos por una excepción.
declare @stocks smallint,@codigos int,@stockMinimos smallint
set @codigos=2
select @stocks=stock,@stockMinimos=stock_minimo from articulos where cod_articulo=@codigos
if @stocks is null or @stockMinimos is null
raiserror( 'No hay datos suficientes',16,1)
else if  @stocks<=@stockMinimos
raiserror( 'Falta reposición del articulo',16,1)
else raiserror ('Hay stock suficiente del articulo',16,1)

 --Modificar el ejercicio anterior agregando las cláusulas de try catch para
--manejo de errores, y mostrar el mensaje capturado en la excepción con print. 

declare @stock int,@codigo int,@stockminimo int
set @codigo=1
select @stock=stock,@stockminimo=stock_minimo
from articulos
where cod_articulo=@codigo

begin try
if @stock is null or @stockminimo is null
raiserror('Faltan datos para validar',16,1)
end try
begin catch
print 'error:'+error_message()
end catch
begin try
if @stock<=@stockminimo
raiserror('El stock es insuficiente',16,1)
end try

begin catch
print 'error:'+error_message()
end catch
begin try
if @stock>@stockminimo
print 'hay stock suficiente!'
end try
begin catch
print 'error'+error_message()
end catch

select * from articulos
 --Ingresar un artículo nuevo, verificando que la cantidad de stock que se
--pasa por parámetro sea un valor mayor a 30 unidades y menor que 100.
--Informar un error caso contrario.
create table #articulos
(stock smallint,
stockminimo smallint,
pre_unitario decimal(10,2),
descricpcion nvarchar(50),
observaciones nvarchar(50))


select * from #articulos

alter proc sp_ingreso_articulo
@stock smallint=null,
@stockminimo smallint=null,
@pre_unitario decimal(10,2)=null,
@descripcion nvarchar(50)=null,
@observaciones nvarchar(50)=null
as


if @stock>30 and @stock <100
insert into  #articulos values(@stock,@stockminimo,@pre_unitario,@descripcion,@observaciones)

else

print 'Debe ser un stock menor a 100 y mayor a 30'


exec sp_ingreso_articulo 10,20,12.5,'pepitos','paquete azul'

--e. Mostrar el nombre del cliente al que se le realizó la primer venta en un
--parámetro de salida.
create proc sp_primerventacleinte
@nombre varchar(50) output,
@apellido varchar(50) output
as


select top 1 @nombre=c.nom_cliente,@apellido=c.ape_cliente
from facturas f join clientes c on c.cod_cliente=f.cod_cliente
order by f.fecha

declare @n varchar(50),@a varchar(50)
execute sp_primerventacleinte @n output,@a output
select @n+''+@a 'Cliente'
 ---FUNCIONES----
--a. Devolver una cadena de caracteres compuesto por los siguientes
--datos: Apellido, Nombre, Telefono, Calle, Altura y Nombre del Barrio,
--de un determinado cliente, que se puede informar por codigo de cliente
--o email.
 alter function f_cadena_cliente
 (@codigo int=null ,@mail varchar(100)=null)
 returns varchar(100)
 as
 begin
 declare @cadena varchar(100)
 set @cadena=(select 'Cliente:  '+ape_cliente+''+nom_cliente+'  telefono:  '+STR(c.nro_tel)+'  CALLE:  '+calle+'  Altura:'+STR(altura)+'  barrio:'+b.barrio
				from clientes c join barrios b on c.cod_barrio=b.cod_barrio
				where cod_cliente=@codigo or [e-mail]=@mail)
return @cadena
end

select dbo.f_cadena_cliente(3,default)

--c. Crear una función que devuelva el precio al que quedaría un artículo en
--caso de aplicar un porcentaje de aumento pasado por parámetro.


create function f_preciosartss
(@porcentaje int,
@codigo int )
returns @precioarticulos table (descripcion varchar(100),precio_articulo decimal(10,2))
as
begin
insert @precioarticulos select descripcion,pre_unitario+pre_unitario*@porcentaje/100
						from articulos
						where cod_articulo=@codigo
return
end

select * from dbo.f_preciosartss(10,1)
select* from articulos

--1. Crear un desencadenador para las siguientes acciones:
--a. Restar stock DESPUES de INSERTAR una VENTA

drop trigger t_stockdetallesfac
on detalle_facturas
for insert
as
declare @stock int
set @stock=(select stock
				from articulos a join inserted i on i.cod_articulo=a.cod_articulo)
if @stock>=(select cantidad from inserted)
update articulos set stock=stock-i.cantidad from articulos a join inserted i on i.cod_articulo=a.cod_articulo

else
begin
raiserror('El articulo tiene stock insuficiente',16,1)
rollback transaction
end


insert into detalle_facturas values(3,1,123,300)	
select * from detalle_facturas where cod_articulo=1

select * from articulos

----cada vez que se
--elimine un registro de detalles_facturas, se actualice el campo "stock" de la tabla
--artículos:

drop trigger des_deletedetalles
on detalle_facturas
for delete
as
update articulos set stock=stock+deleted.cantidad	
					from deleted join articulos on deleted.cod_articulo=articulos.cod_articulo


--b. Para no poder modificar el nombre de algún artículo

drop trigger des_nombrearticulo
on articulos
for update
as
begin
if update (descripcion)
raiserror('No puede modificar la descripcion de los artículos',16,1)
rollback transaction
end

update articulos set descripcion='pepitosdff' where cod_articulo=1
--c. Insertar en la tabla HistorialPrecio el precio anterior de un artículo si el
--mismo ha cambiado
drop trigger des_insertar_historial
on articulos
instead of update
as
begin
if update(pre_unitario)
declare @precioviejo decimal(10,2),@codigo int

set @codigo=(select deleted.cod_articulo from articulos join deleted on deleted.cod_articulo=articulos.cod_articulo)

set @precioviejo=(select articulos.pre_unitario
					from articulos where cod_articulo=@codigo)
insert into historial_precios (cod_articulo,precio) values (@codigo,@precioviejo)
end

update articulos set pre_unitario=5555 where cod_articulo=1

select * from articulos
select * from historial_precios



