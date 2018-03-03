DROP KEYSPACE IF EXISTS shop;
DESCRIBE keyspaces;
CREATE KEYSPACE shop with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
use shop;

CREATE COLUMNFAMILY items (
	category text, 
	name text, 
	price bigint, 
	producer text, 
	properties map<text, text>, 
	PRIMARY KEY((category), price, name));


CREATE INDEX name_idx on items(name);
CREATE INDEX producer_idx on items(producer);

insert into items (category, name, price, producer, properties) 
	values('TV', 'Sumsumg Smart TV', 1500, 'KNDR', {'diagonal': '65', 'test':'test'});

insert into items (category, name, price, producer, properties) 
	values('TV', 'Sumsumg Smart TV', 700, 'UA', {});

insert into items (category, name, price, producer, properties) 
	values('TV', 'Kineskop', 140, 'USSR',  {'diagonal': '35'});

insert into items (category, name, price, producer, properties) 
	values('Car', 'Zigule', 200, 'USSR', {});

insert into items (category, name, price, producer, properties) 
	values('Car', 'BMV', 1600, 'USA', {});

//TASK 1
DESCRIBE shop;

//TASK 2
select * from shop.items where category='TV' order by price DESC;

//TASK 3
select * from shop.items where category='TV' and name = 'Sumsumg Smart TV';
select * from shop.items where category='TV' and price >= 300 and price<=1600;
select * from shop.items where category='Car' and producer = 'USSR';

//TASK 4
select * from shop.items where category='TV' and properties contains key 'diagonal' ALLOW FILTERING;
select * from shop.items where category='TV' and properties contains key 'diagonal' 
											 and properties['diagonal'] = '65'  ALLOW FILTERING;

//TASK 5
select * from shop.items where category='TV' and price=1500 and name='Sumsumg Smart TV'; 

update shop.items set properties['diagonal'] = '66' 
						 where category='TV' and price=1500 and name='Sumsumg Smart TV';

update shop.items set properties = properties + {'color' : 'red'} 
						 where category='TV' and price=1500 and name='Sumsumg Smart TV';

update shop.items set properties = properties - {'test'} 
						 where category='TV' and price=1500 and name='Sumsumg Smart TV';

select * from shop.items where category='TV' and price=1500 and name='Sumsumg Smart TV'; 


//PART 2


CREATE COLUMNFAMILY orders (
	customer_name text,
	order_time timestamp,
	amount double,
	goods set<text>,
	PRIMARY KEY ((customer_name), order_time));


CREATE INDEX goods_idx on orders(goods);


insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy P', '2017-03-02', 666, {'plane', 'car', 'knife'});

insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy P', '2016-03-02', 555, {'knife'});

insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy P', unixTimestampOf(now()), 1666, {'car'});

// LONG OPERATION TO SEE TIME DIFFERENCE
CREATE KEYSPACE temp with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
DROP KEYSPACE temp;


insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy P', unixTimestampOf(now()), 200, {'knife'});

insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy K', unixTimestampOf(now()), 1000, {'coat'});

insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy K', unixTimestampOf(now()), 500, {'knife'});

//SOURCE '/home/yuriy/projects/distributed_db/task5_casandra/script.sql'

//TASK 1
DESCRIBE orders;

//TASK 2
select * from shop.orders where customer_name='Yuriy P' order by order_time DESC;

//TASK 3
select * from shop.orders where customer_name='Yuriy P' and goods contains 'knife';

//TASK 4
select customer_name, count(order_time) from shop.orders where customer_name='Yuriy P' 
										                 and order_time < '2018-01-01' group by customer_name;

//TASK 5
select customer_name, avg(amount) from shop.orders group by customer_name;

//TASK 6
select customer_name, sum(amount) from shop.orders group by customer_name;

//TASK 7
select customer_name, max(amount) from shop.orders group by customer_name;

//TASK 8
select * from shop.orders where customer_name='Yuriy P' and order_time = '2016-03-02';
update shop.orders set goods = goods + {'pc'}, amount = 556
						 where customer_name='Yuriy P' and order_time = '2016-03-02';

select * from shop.orders where customer_name='Yuriy P' and order_time = '2016-03-02';

//TASK 9
select customer_name, goods, writetime(amount) from shop.orders group by customer_name, order_time;

//TASK 10
insert into orders (customer_name, order_time, amount, goods) 
	values('Yuriy K', unixTimestampOf(now()), 500, {'key'}) using TTL 1;

select * from shop.orders where customer_name='Yuriy K';
// LONG OPERATION TO SEE TIME DIFFERENCE
CREATE KEYSPACE temp with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
DROP KEYSPACE temp;
// LONG OPERATION TO SEE TIME DIFFERENCE
CREATE KEYSPACE temp with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
DROP KEYSPACE temp;
// LONG OPERATION TO SEE TIME DIFFERENCE
CREATE KEYSPACE temp with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
DROP KEYSPACE temp;
// LONG OPERATION TO SEE TIME DIFFERENCE
CREATE KEYSPACE temp with replication = {'class' : 'SimpleStrategy', 'replication_factor':1};
DROP KEYSPACE temp;
select * from shop.orders where customer_name='Yuriy K';

//TASK 11
select json * from shop.orders;

//TASK 12
select * from shop.orders where customer_name='Yuriy K';
insert into orders JSON 
	'{"customer_name": "Yuriy K", "order_time": "2017-03-02 09:04:44.658Z", "amount": 1005.0, "goods": ["1", "2"]}';

select * from shop.orders where customer_name='Yuriy K';