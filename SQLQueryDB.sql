CREATE TABLE city(
	id int PRIMARY KEY IDENTITY NOT NULL,
	name varchar(50) NOT NULL
)

CREATE TABLE bank(
	id int PRIMARY KEY IDENTITY NOT NULL,
	name varchar(50) NOT NULL
)

CREATE TABLE branch(
	id int PRIMARY KEY IDENTITY NOT NULL,
	adress varchar(100) NOT NULL,
	id_city int NOT NULL,
	id_bank int NOT NULL,
	FOREIGN KEY (id_bank) REFERENCES bank (id),
	FOREIGN KEY (id_city) REFERENCES city (id)
)

CREATE TABLE status(
	id int PRIMARY KEY IDENTITY NOT NULL,
	name varchar(30) NOT NULL
)

CREATE TABLE client(
	id int PRIMARY KEY IDENTITY NOT NULL,
	firstName varchar(30) NOT NULL,
	lastName varchar(30) NOT NULL,
	passport varchar(9) NOT NULL,
	email varchar(30) NULL,
	phone varchar(11) NULL,
	id_status int NOT NULL,
	FOREIGN KEY (id_status) REFERENCES status (id)
)

CREATE TABLE account(
	id int PRIMARY KEY IDENTITY NOT NULL,
	balance money NOT NULL,
	payslip varchar(10) NOT NULL,
	id_bank int NOT NULL,
	id_client int NOT NULL,
	FOREIGN KEY (id_bank) REFERENCES bank (id),
	FOREIGN KEY (id_client) REFERENCES client (id)
)

CREATE TABLE card(
	id int PRIMARY KEY IDENTITY NOT NULL,
	number varchar(16) NOT NULL,
	balance money NOT NULL,
	id_account int NOT NULL,
	FOREIGN KEY (id_account) REFERENCES account (id)
)

INSERT INTO city
VALUES
('Homel'),
('Zhlobin'),
('Minsk'),
('Vitebsk'),
('Hrodno')

INSERT INTO bank
VALUES
('BelarusBank'),
('Alfa-Bank'),
('Priorbank'),
('SberBank'),
('Belinvestbank')

INSERT INTO branch
VALUES
('st. Kozhara 1',	1,	1),
('st. Pervomaiskaya 34',	2,	1),
('st. Zhokova 119', 	3,	2),
('st. Molodezhnaya 45',	3,	2),
('st. Sovetskaya 203',	1,	2),
('st. Ulianova 93',	4,	3),
('st. Kirova 19',	5,	4),
('st. Lenina 34',	5,	5)

INSERT INTO status
VALUES
('default'),
('disabled'),
('veteran'),
('orphan'),
('pensioner')

INSERT INTO client
VALUES
('Ruslan',	'Drozdov',	'HB3051253',	'rdrozdov@gmail.com',	'80291385643',	1),
('Ivan',	'Petrov',	'HB2981376',	'ipetrov@gmail.com',	NULL,	2),
('Kirill',	'Avramov',	'HB3921365',	'kr.avromov98@gmail.com',	'80335673421',	3),
('Petr',	'Vasilenko',	'HB2991351',	NULL,	'80447168745',	4),
('Dmitriy',	'Molochko',	'HB3003412',	'dima.molochko03@gmail.com',	'80335331212',	5),
('Artem',	'Lutskin',	'HB3044512',	'alutskin@mail.ru',	'80447041234',	1),
('Evgeniy',	'Yakovtsev',	'HB3451212',	'yakovtesv72@gmail.com',	'80291914576',	3)

INSERT INTO account
VALUES
(10000.0000,	'1235612213',	1,	1),
(9110.0000,	'1432351354',	1,	2),
(4510.0000,	'1435234268',	2,	2),
(3130.0000,	'1568123564',	3,	3),
(6710.0000,	'1534643473',	4,	4),
(3680.0000,	'1645743463',	5,	5),
(4210.0000,	'1524523455',	3,	6),
(6230.0000,	'1352453234',	4,	7),
(4330.0000,	'1639420503',	4,	3)

INSERT INTO card
VALUES
('4109567434532345',	509.0000,	1),
('4109587347853853',	6709.0000,	1),
('4853945938495393',	3500.0000,	2),
('4984568939654958',	4500.0000,	3),
('4938692934598334',	3100.0000,	4),
('4293429898489282',	4400.0000,	5),
('4108243583939843',	2100.0000,	5),
('4004387453874583',	3400.0000,	6),
('6493952034298542',	4200.0000,	7),
('2278314821384732',	3100.0000,	8),
('1287319848239203',	3000.0000,	8),
('3451343453984583',	4200.0000,	9)
