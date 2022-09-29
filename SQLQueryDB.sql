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