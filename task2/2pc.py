import psycopg2
import datetime

from psycopg2._psycopg import ProgrammingError

db1 = "FlyBooking"
db2 = "HotelBooking"
db3 = "Account"
user = "postgres"
password = "postgres"
host = "127.0.0.1"
port = "5432"

# flyTable = "fly_booking"
# hotelTable = "hotel_booking"

"""
CREATE TABLE fly_booking
(
    id serial primary key,
    client_name text,
    fly_number text,
    place_from text,
    place_to text,
    fly_date date
);

CREATE TABLE hotel_booking
(
    id serial primary key,
    client_name text,
    hotel_name text,
    arrival date,
    departure date
);

CREATE TABLE account
(
    id serial primary key,
    client_name text,       
    ammount int CHECK (ammount >= 0)
);

"""

def insert_records_2pc(client_name, place_from, place_to, hotel):
    tran_id = "homework2"
    fly_conn = psycopg2.connect(database=db1, user=user, password=password, host=host, port=port)
    hotel_conn = psycopg2.connect(database=db2, user=user, password=password, host=host, port=port)
    account_conn = psycopg2.connect(database=db3, user=user, password=password, host=host, port=port)
    print("Opened databases successfully")
    """
    a format ID (non-negative 32 bit integer)
    a global transaction ID (string not longer than 64 bytes)
    a branch qualifier (string not longer than 64 bytes)
    """
    method_global_id = 10
    fly_xid = fly_conn.xid(method_global_id, tran_id, 'conn1')
    hotel_xid = hotel_conn.xid(method_global_id, tran_id, 'conn2')
    account_xid = hotel_conn.xid(method_global_id, tran_id, 'conn3')

    fly_conn.tpc_begin(fly_xid)
    hotel_conn.tpc_begin(hotel_xid)
    account_conn.tpc_begin(account_xid)

    hotel_cur = hotel_conn.cursor()
    fly_cur = fly_conn.cursor()
    account_cur = account_conn.cursor()

    try:
        fly_cur.execute(
                "INSERT INTO fly_booking (client_name, fly_number, place_from, place_to, fly_date) "
                "VALUES ( %s, 32, %s, %s, now() )", (client_name, place_from, place_to))

        hotel_cur.execute(
                "INSERT INTO hotel_booking (client_name, hotel_name, arrival, departure) "
                "VALUES (%s, %s, now(), now() )", (client_name, hotel))

        account_cur.execute( "UPDATE account SET ammount = ammount - 1 WHERE client_name='%s'" % client_name)
    except:
        print("rollback")  
        fly_conn.close()
        hotel_conn.close()
        account_conn.close()
        return 
    fly_cur.close()
    hotel_cur.close()
    account_cur.close();

    try:
        print("before prepare")
        fly_conn.tpc_prepare()
        hotel_conn.tpc_prepare()
        account_conn.tpc_prepare()
        print("All prepared")
    except ProgrammingError as e:
        print(e)
        fly_conn.tpc_rollback() 
        hotel_conn.tpc_rollback()
        account_conn.tpc_rollback()
        print("All rollbacked")
    else:
        fly_conn.tpc_commit()
        hotel_conn.tpc_commit()
        #account_conn.tpc_commit()
        print("All commited")

    fly_conn.close()
    hotel_conn.close()
    account_conn.close()


i = datetime.datetime.now()
date = "'%s/%s/%s" % (i.day, i.month, i.year) + "'"

insert_records_2pc('Yuriy', 'Kiev', 'Lviv', 'Hotel Lviv')