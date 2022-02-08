# ----- Gestao de Estoque de Supermercado ------
create schema gestaoEstoque;
use gestaoEstoque;

# Apaga o esquema
DROP SCHEMA gestaoEstoque;

# Visualizar esquema e tabelas
show tables;
describe Deposito;
select * from Deposito;
select * from Corredor;
select * from Fornecedor;
select * from Gerente;
select * from Operacao;
select * from Prateleira;
select * from Produto;

# ---- Criando as tabelas -----
#     e instanciando valores

create table Deposito(codDeposito int not null,
 supermercado varchar(100) not null,
 endereco varchar(200) not null,
 primary key(codDeposito));
 
insert into Deposito values (20210001, 'Treichel', 'Av. Fernando Osorio, 1500');
 
create table Corredor(numCorredor int not null,
 setor varchar(100) not null,
 codDeposito int not null,
 foreign key (codDeposito) references Deposito(codDeposito) on delete cascade on update cascade,
 primary key(numCorredor));

insert into Corredor values 
(3, 'Bebidas', 20210001),
(5, 'Hortifruti', 20210001),
(7, 'Biscoitos', 20210001);

create table Prateleira(numPrateleira int not null,
 numCorredor int not null,
 foreign key (numCorredor) references Corredor(numCorredor) on delete cascade on update cascade,
 primary key(numPrateleira));
 
insert into Prateleira values
(13, 3),
(14, 3),
(25, 5),
(26, 5),
(32, 7),
(33, 7);
 
create table Fornecedor(codFornecedor int not null,
 endereco varchar(200) ,
 nome varchar(100) not null,
 telefone char(12) not null,
 primary key(codFornecedor));
 
insert into Fornecedor values
(12345532, 'Areal, 536', 'Biscoitos Zéze', '05332222222'),
(33345678, 'Monte Bonito, 43', 'Agricult', '053981116611'),
(55544433, 'Fragata, 9500', 'Ambev', '05332556776'),
(16516616, 'Av. Fernando Osorio, 6042', 'Biri', '053981202030'),
(43743715, 'Bachinni', 'Beskows', '05332272730');

create table Produto(sku varchar(30) not null,
 descricao varchar(100) not null,
 unidadeDeMedida varchar(2) not null,
 preco float not null,
 quantidade int not null default 1,
 codFornecedor int,
 numPrateleira int not null,
 foreign key (codFornecedor) references Fornecedor(codFornecedor) on delete set null on update cascade,
 foreign key (numPrateleira) references Prateleira(numPrateleira) on update cascade,
 primary key(sku));
 
 insert into Produto values
 ('bisczeze-cx-190','Biscoito Zezé 1x40', 'g', 120.30, 15, 12345532, 32),
 ('bolzeze-cx-300','Bolacha Zezé 1x30', 'g', 135.50, 9, 12345532, 33),
 ('coca-far-350','Coca-cola 1x12', 'ml', 40.0, 7, 55544433, 13),
 ('guar-far-2','Guaraná 1x6', 'l', 50.0, 10, 55544433, 14),
 ('tom-cx-20','Tomate', 'kg', 65.0, 4, 33345678, 25),
 ('bat-cx-30','Batata', 'kg', 64.50, 3, 33345678, 26),
 ('birlim-far-2','Biri Limão 1x6', 'l', 43.50, 11, 16516616, 14),
 ('ceb-cx-10','Cebola', 'kg', 36.20, 5, 43743715, 25);
 
create table Gerente(cpfGer char(11) not null,
 nome varchar(100) not null,
 codDeposito int not null,
 primary key(cpfGer),
 foreign key (codDeposito) references Deposito(codDeposito)  on delete cascade on update cascade);
 
insert into Gerente values('10020030040', 'Sérgio Fonseca', 20210001),
('33344455566', 'Cláudia Martins', 20210001),
('22277788899', 'Paulo Rodrigues', 20210001);
 
create table Operacao(codOperacao int not null,
 data date not null,
 tipoSuba boolean not null,
 cpfGer char(11) not null,
 codDeposito int not null,
 sku varchar(30) not null,
 quantidade int not null,
 preco float not null,
 primary key(codOperacao),
 foreign key (cpfGer) references Gerente(cpfGer) on update cascade,
 foreign key (codDeposito) references Deposito(codDeposito) on delete cascade on update cascade,
 foreign key (sku) references Produto(sku) on update cascade);

insert into Operacao values
(305306307, '2021-09-15', true, 10020030040, 20210001, 'bisczeze-cx-190', 5, 601.50),
(101102103, '2021-09-19', false, 33344455566, 20210001, 'tom-cx-20', 2, 110),
(500501503, '2021-09-17', true, 22277788899, 20210001, 'birlim-far-2', 5, 217.50),
(441442443, '2021-09-25', true, 33344455566, 20210001, 'coca-far-350', 3, 120);

# -------- Consultas ----------
# 1. Recuperar o nome do gerente, descrição do produto e código da operação
# realizada no dia 15-09-2021
select G.nome, P.descricao, O.codOperacao
from Gerente as G, Produto as P, Operacao as O
where O.data = '2021-09-15' and O.cpfGer=G.cpfGer and O.sku=P.sku;

# 2. Retornar a quantidade total (caixas/fardos) de produtos do setor ‘Bebidas’
select sum(quantidade)
from Produto, Corredor, Prateleira
where Produto.numPrateleira=Prateleira.numPrateleira and 
Prateleira.numCorredor=Corredor.numCorredor and Corredor.setor='Bebidas';

# 3. Retornar a descrição e quantidade dos produtos em estoque do fornecedor ‘Biri’.
select P.descricao, P.quantidade
from Produto as P join Fornecedor as F on P.codFornecedor=F.codFornecedor
where F.nome='Biri';

# 4. Para cada produto retornar a sua descrição e o seu setor
select P.descricao, C.setor
from Produto as P, Corredor as C, Prateleira as Pr
where P.numPrateleira=Pr.numPrateleira and C.numCorredor= Pr.numCorredor;

# 5. Retornar o nome do gerente responsável, a data, e o código todas as operações de suba 
# realizadas depois do dia 16-09-2021
select G.nome, O.codOperacao, O.data
from Gerente as G join Operacao as O on O.cpfGer=G.cpfGer and O.tipoSuba=true
where O.data > '2021-09-16';

# 6. Retornar a descrição do produto, o nome e telefone do fornecedor,
# cuja quantidade (caixas/fardos) dos produtos em estoque for menor que 6
select P.descricao, F.nome
from Produto as P join Fornecedor as F on P.codFornecedor = F.codFornecedor
where P.quantidade < 6;

# 7. Retornar a descrição do produto, quantidade e o nome do gerente responsável
# por todas as operações cujo preço seja maior que R$ 200,00
select P.descricao, G.nome, O.quantidade
from Produto as P, Gerente as G, Operacao as O
where O.preco>200.0 and O.cpfGer=G.cpfGer and O.sku=P.sku;