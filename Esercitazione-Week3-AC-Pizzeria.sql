create database Pizzeria

create table Pizza(
codice int identity(1,1) primary key,
nome varchar(20) not null,
prezzo float not null
check (prezzo>0)
)

create table Ingredienti(
codice int identity(1,1) primary key,
nome varchar(20) not null,
costo float not null
check (costo>0),
numScorte int not null
)

create table IngredientiPizza(
codicePizza int foreign key references Pizza(codice) not null,
codiceIngredienti int foreign key references Ingredienti(codice) not null,
quantita int not null
check (quantita>0)
)

create index IndexNomePizza on Pizza(nome);
create unique index IndexIngrediente on Ingredienti(codice); --superfluo perché sto usando codice come primary key
--__________________procedure______________________
create procedure PizzIngr @Pizza varchar(20), @Ingrediente varchar(20)
as
begin
begin try
declare @idP int
select @idP=codice
from Pizza
where nome like @Pizza
declare @idI int
select @idI=codice
from Ingredienti
where nome like @Ingrediente
insert into IngredientiPizza values(@idP, @idI, 1)
end try
begin catch
select ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
end catch
end

create procedure Ingredienti @Nome varchar(20), @costo float, @numScorte int
as
begin
begin try
insert into Ingredienti values (@Nome, @costo, @numScorte)
end try
begin catch
select ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
end catch
end

create procedure Pizza @Nome varchar(20), @costo float
as
begin
begin try
insert into Pizza values (@Nome, @costo)
end try
begin catch
select ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
end catch
end

create procedure TogliIngredientePizza @idP int, @idI int
as
begin
begin try
delete from IngredientiPizza where codicePizza=@idP and codiceIngredienti=@idI
end try
begin catch
select ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
end catch
end

create procedure IncrementoPrezzo @idI int
as
begin
begin try
update Pizza set prezzo=prezzo+prezzo*0.1 from IngredientiPizza where codicePizza=Pizza.codice and codiceIngredienti=@idI
end try
begin catch
select ERROR_LINE(), ERROR_MESSAGE(), ERROR_SEVERITY()
end catch
end

--__________________funcs______________
create function Elenco_Pizze_Ordinate()
returns table as
return select *
from Pizza
order by Nome

create function PizzaConIngrediente(@codiceIngrediente int)
returns table as
return select nome, Pizza.prezzo
from Pizza join IngredientiPizza on Pizza.codice=IngredientiPizza.codicePizza and IngredientiPizza.codiceIngredienti=@codiceIngrediente

create function PizzaSenzaIngrediente(@codiceIngrediente int)
returns table as
return select codice, nome, Pizza.prezzo
from Pizza 
except 
select codice, nome, Pizza.prezzo
from Pizza join IngredientiPizza on Pizza.codice=IngredientiPizza.codicePizza and IngredientiPizza.codiceIngredienti=@codiceIngrediente

create function ContoPizzaConIngrediente(@codiceIngrediente int)
returns table as
return select count(distinct nome)
from PizzaConIngrediente(@codiceIngrediente)

create function ContoPizzaSenzaIngrediente(@codiceIngrediente int)
returns table as
return select count(distinct nome)
from PizzaSenzaIngrediente(@codiceIngrediente)

create function ContoPizzaIngrediente(@codicePizza int)
returns table as
return select count(*)
from (select * from IngredientiPizza where codicePizza=@codicePizza) as res
join Ingredienti on res.codiceIngredienti=codice

--_______________________insert vals______________________
insert into Pizza values ( 'Margherita', 5)
insert into Pizza values ( 'Bufala', 7)
insert into Pizza values ( 'Diavola', 6)
insert into Pizza values ( 'Quattro Stagioni', 6,5)
insert into Pizza values ( 'Porcini', 7)
insert into Pizza values ( 'Dionisio', 8)
insert into Pizza values ( 'Ortolana', 8)
insert into Pizza values ( 'Patate e Salsiccia', 6)
insert into Pizza values ( 'Pomodorini', 6)
insert into Pizza values ( 'Quattro Formaggi', 7,5)
insert into Pizza values ( 'Caprese', 7.5)
insert into Pizza values ( 'Zeus', 7.5)

exec Ingredienti @Nome='pomodoro', @costo=0.7, @numScorte=300
exec Ingredienti @Nome='mozzarella', @costo=1.5, @numScorte=250
exec Ingredienti @Nome='mozzarella di bufala', @costo=2, @numScorte=15
exec Ingredienti @Nome='spianata piccante', @costo=4, @numScorte=50
exec Ingredienti @Nome='funghi', @costo=2.3, @numScorte=34
exec Ingredienti @Nome='carciofi', @costo=0.9, @numScorte=60
exec Ingredienti @Nome='cotto', @costo=7, @numScorte=40
exec Ingredienti @Nome='olive', @costo=1, @numScorte=67
exec Ingredienti @Nome='funghi porcini', @costo=2.7, @numScorte=37
exec Ingredienti @Nome='stracchino', @costo=4.3, @numScorte=25
exec Ingredienti @Nome='speck', @costo=8, @numScorte=98
exec Ingredienti @Nome='rucola', @costo=1.2, @numScorte=45
exec Ingredienti @Nome='grana', @costo=10, @numScorte=56
exec Ingredienti @Nome='verdure di stagione', @costo=0.9, @numScorte=150
exec Ingredienti @Nome='patate', @costo=2.7, @numScorte=80
exec Ingredienti @Nome='salsiccia', @costo=9.7, @numScorte=100
exec Ingredienti @Nome='ricotta', @costo=5, @numScorte=52
exec Ingredienti @Nome='provola', @costo=4.2, @numScorte=89
exec Ingredienti @Nome='gorgonzola', @costo=6, @numScorte=34
exec Ingredienti @Nome='pomodoro fresco', @costo=0.4, @numScorte=400
exec Ingredienti @Nome='basilico', @costo=0.3, @numScorte=500
exec Ingredienti @Nome='bresaola', @costo=7, @numScorte=30

exec [dbo].[PizzIngr] @Pizza='Margherita', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Marghertia', @Ingrediente='mozzarella'

exec [dbo].[PizzIngr] @Pizza='Bufala', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Bufala', @Ingrediente='mozzarella di bufala'

exec [dbo].[PizzIngr] @Pizza='Diavola', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Diavola', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Diavola', @Ingrediente='spianata piccante'

exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='funghi'
exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='carciofi'
exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='cotto'
exec [dbo].[PizzIngr] @Pizza='Quattro Stagioni', @Ingrediente='olive'

exec [dbo].[PizzIngr] @Pizza='Porcini', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Porcini', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Porcini', @Ingrediente='funghi porcini'

exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='stracchino'
exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='speck'
exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='rucola'
exec [dbo].[PizzIngr] @Pizza='Dioniso', @Ingrediente='grana'

exec [dbo].[PizzIngr] @Pizza='Ortolana', @Ingrediente='pomodoro'
exec [dbo].[PizzIngr] @Pizza='Ortolana', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Ortolana', @Ingrediente='verdure di stagione'

exec [dbo].[PizzIngr] @Pizza='Patate e Salsiccia', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Patate e Salsiccia', @Ingrediente='patate'
exec [dbo].[PizzIngr] @Pizza='Patate e Salsiccia', @Ingrediente='salsiccia'

exec [dbo].[PizzIngr] @Pizza='Pomodorini', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Pomodorini', @Ingrediente='pomodorini'
exec [dbo].[PizzIngr] @Pizza='Pomodorini', @Ingrediente='ricotta'

exec [dbo].[PizzIngr] @Pizza='Quattro formaggi', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Quattro formaggi', @Ingrediente='provola'
exec [dbo].[PizzIngr] @Pizza='Quattro formaggi', @Ingrediente='gorgonzola'
exec [dbo].[PizzIngr] @Pizza='Quattro formaggi', @Ingrediente='grana'

exec [dbo].[PizzIngr] @Pizza='Caprese', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Caprese', @Ingrediente='pomodoro fresco'
exec [dbo].[PizzIngr] @Pizza='Caprese', @Ingrediente='basilico'

exec [dbo].[PizzIngr] @Pizza='Zeus', @Ingrediente='mozzarella'
exec [dbo].[PizzIngr] @Pizza='Zeus', @Ingrediente='bresaola'
exec [dbo].[PizzIngr] @Pizza='Zeus', @Ingrediente='rucola'

--____________view______________
create view Menu as (
--select pizza.nome, pizza.prezzo, Ingredienti.nome
--from Pizza join IngredientiPizza on Pizza.codice=IngredientiPizza.codicePizza join Ingredienti on IngredientiPizza.codiceIngredienti=Ingredienti.codice

select *
from Pizza join (
	select codicePizza, Ingredienti.nome 
	from IngredientiPizza join Ingredienti 
	on IngredientiPizza.codiceIngredienti=codice
	)
as res on codice=res.codicePizza
) 