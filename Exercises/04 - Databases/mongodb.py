import pymongo
import datetime

# Ref: https://www.w3schools.com/python/python_mongodb_getstarted.asp

#
# Open Azure Data Studio and import sample data
#
myclient = pymongo.MongoClient("mongodb://cosmosdb-account-f13a15:Q5oymxSiN7BxJasjwL1A5qH4tKAnOYVyhtyvtRTIEYomPCYPaBVQPC9FwEh1ccAfWFNi8PVJADfHACDbRAEfyA==@cosmosdb-account-f13a15.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@cosmosdb-account-f13a15@")

# dblist = myclient.list_database_names()
# if "database-f13a15" in dblist:
#    print("The database exists.")

# create db and collection if they haven't been created yet
mydb = myclient["database-f13a15"]
mycol = mydb["Customer Data"]

# # insert a record
# mydict = {"name": "John", "address": "Highway 37"}
# x = mycol.insert_one(mydict)

# print (f"Customer {x.inserted_id} inserted.")

# # find one or many
# x = mycol.find_one()
# print(x)

# for x in mycol.find():
#     print(x["type"])

# only return name and address
# for x in mycol.find({}, {"_id": 0, "title": 1, "firstName": 1, "lastName": 1}):
#     print(x)

# query for one specific element
for x in mycol.find({"type": "salesOrder"}).limit(5):
    customer_id = x['customerId']
    order_date = x['orderDate']
    c = mycol.find_one({"id": customer_id})
    print(f"{c['title']} {c['firstName']} {c['lastName']} \t| {order_date}")

# for x in mycol.find({"type": "customer"}):
#     print(f"{x['title']} {x['firstName']} {x['lastName']}")

# # Advanced query
# myquery = {"address": {"$gt": "S"}}
# mydoc = mycol.find(myquery)
# for x in mydoc:
#     print(x)

# # or with regexp
# myquery = {"address": {"$regex": "^S"}}
# mydoc = mycol.find(myquery)
# for x in mydoc:
#     print(x)
