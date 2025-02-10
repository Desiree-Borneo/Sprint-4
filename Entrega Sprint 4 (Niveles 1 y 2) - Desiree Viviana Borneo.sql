-- NIVEL 1

/* CREO BB, TABLAS Y CONSTRAINTS */
create database sprint_4;
show databases;
use sprint_4;

create table companies (
	company_id varchar(20) not null, 
    company_name varchar(255),
    phone varchar(20), 
    email varchar(100),
    country varchar(100),
    website varchar(50),
    primary key (company_id)
    
);
create table credit_cards (
	id varchar(20) not null,
    user_id int(11),
    iban varchar(50),
    pan varchar(50),
    pin varchar(50),
    cvv varchar(4), 
    track1 varchar(255),
    track2 varchar(255),
    expiring_date varchar(20), 
    primary key (id)
);
create table users (
	id int(11) not null, 
    name varchar(255),
    surname varchar(255), 
    phone varchar(255),
    email varchar(255),
    birth_date varchar(255),
    country varchar(255), 
    city varchar(255),
    postal_code varchar(255),
    adress varchar(255),
    primary key (id)
);
create table transactions (
	id varchar(255) not null,
	card_id varchar(20),
    business_id varchar(20),
    timestamp datetime not null default current_timestamp,
    amount decimal(10,2),
    declined tinyint(1),
	product_ids varchar(50),
    user_id int(11),
    lat float,
    longitude float,
	primary key (id)
);

alter table transactions
add constraint fk_card_id foreign key (card_id) REFERENCES credit_cards(id) on delete set null on update cascade; 

alter table transactions
add constraint fk_business_id foreign key (business_id) REFERENCES companies(company_id) on delete set null on update cascade; 

alter table transactions
add constraint fk_users_id foreign key (users_id) REFERENCES users(id) on delete set null on update cascade;  


/* INSERTO DATOS */ 


show variables like 'secure_file_priv';

-- 'secure_file_priv', 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\' 

/* Abro 

C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ 

y guardo los archivos csv ahí. */

use sprint_4; 

load data infile  "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv" into table companies 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile  "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv" into table credit_cards 
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_usa.csv" into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_uk.csv" into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\users_ca.csv" into table users
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv" into table transactions
fields terminated by ';'
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows;


-- Exercici 1
-- Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.


select u.name, count(t.id)
from transactions as t 
inner join users as u on u.id = t.user_id
group by u.name
having count(t.id) > 30;

-- Exercici 2
-- Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules. 

select cc.iban, round(avg(t.amount),2)
from transactions as t 
inner join credit_cards as cc on cc.id = t.card_id
inner join companies as c on c.company_id = t.business_id 
where c.company_name = 'Donec Ltd'
group by cc.iban;


-- NIVEL 2

/*
Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat 
en si les últimes tres transaccions van ser declinades i genera la següent consulta:
Quantes targetes estan actives?
*/

create table credit_cards_status_final as 
select card_id, 
	sum(declined) as count_declined, 
	case 
		when sum(declined) = 3 then "Tarjeta Inactiva"
		else "Tarjeta Activa" 
	end as card_status
from (
	select * 
	from (
		select card_id, declined, timestamp,  
			row_number() over(partition by card_id order by timestamp) as numbered_rows
		from transactions
		) as temp_table
    
	where numbered_rows <=3
    ) as temp_table_2

group by card_id;

-- y ahora sí puedo contar: 

select count(card_status)
from credit_cards_status_final
where card_status like "%Tarjeta Activa%";

select count(card_status)
from credit_cards_status_final
where card_status like "%Tarjeta Inactiva%";

-- Todas están activas.