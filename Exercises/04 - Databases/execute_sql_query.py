import os
import random

import mysql.connector
import pyodbc
from azure.identity import AzureCliCredential
from azure.mgmt.rdbms.mysql import MySQLManagementClient
from azure.mgmt.rdbms.mysql.models import (ServerForCreate,
                                           ServerPropertiesForDefaultCreate,
                                           ServerVersion)
from azure.mgmt.resource import ResourceManagementClient


# https://learn.microsoft.com/en-us/azure/developer/python/sdk/examples/azure-sdk-example-database?tabs=cmd
# Acquire a credential object using CLI-based authentication.
credential = AzureCliCredential()

# Retrieve subscription ID from environment variable
subscription_id = os.environ["AZURE_SUBSCRIPTION_ID"]

# Constants we need in multiple places: the resource group name and the region
# in which we provision resources. You can change these values however you want.
RESOURCE_GROUP_NAME = 'PythonAzureExample-DB-rg'
LOCATION = "westus"

# Step 1: Provision the resource group.
resource_client = ResourceManagementClient(credential, subscription_id)

rg_result = resource_client.resource_groups.create_or_update(RESOURCE_GROUP_NAME,
    { "location": LOCATION })

print(f"Provisioned resource group {rg_result.name}")

# For details on the previous code, see Example: Provision a resource group
# at https://docs.microsoft.com/azure/developer/python/azure-sdk-example-resource-group


# Step 2: Provision the database server

# We use a random number to create a reasonably unique database server name.
# If you've already provisioned a database and need to re-run the script, set
# the DB_SERVER_NAME environment variable to that name instead.
#
# Also set DB_USER_NAME and DB_USER_PASSWORD variables to avoid using the defaults.

db_server_name = os.environ.get("DB_SERVER_NAME", f"PythonAzureExample-MySQL-{random.randint(1,100000):05}")
db_admin_name = os.environ.get("DB_ADMIN_NAME", "azureuser")
db_admin_password = os.environ.get("DB_ADMIN_PASSWORD", "ChangePa$$w0rd24")

# Obtain the management client object
mysql_client = MySQLManagementClient(credential, subscription_id)

# Provision the server and wait for the result
poller = mysql_client.servers.begin_create(RESOURCE_GROUP_NAME,
    db_server_name, 
    ServerForCreate(
        location=LOCATION,
        properties=ServerPropertiesForDefaultCreate(
            administrator_login=db_admin_name,
            administrator_login_password=db_admin_password,
            version=ServerVersion.FIVE7
        )
    )
)

server = poller.result()

print(f"Provisioned MySQL server {server.name}")

# Step 3: Provision a firewall rule to allow the local workstation to connect

RULE_NAME = "allow_ip"
ip_address = os.environ["PUBLIC_IP_ADDRESS"]

# For the above code, create an environment variable named PUBLIC_IP_ADDRESS that
# contains your workstation's public IP address as reported by a site like
# https://whatismyipaddress.com/.

# Provision the rule and wait for completion
poller = mysql_client.firewall_rules.begin_create_or_update(RESOURCE_GROUP_NAME,
    db_server_name, RULE_NAME, 
    { "start_ip_address": ip_address, "end_ip_address": ip_address }  
)

firewall_rule = poller.result()

print(f"Provisioned firewall rule {firewall_rule.name}")


# Step 4: Provision a database on the server

db_name = os.environ.get("DB_NAME", "example-db1")
 
poller = mysql_client.databases.begin_create_or_update(RESOURCE_GROUP_NAME,
    db_server_name, db_name, {})

db_result = poller.result()

print(f"Provisioned MySQL database {db_result.name} with ID {db_result.id}")


db_server_name = os.environ["DB_SERVER_NAME"]
db_admin_name = os.getenv("DB_ADMIN_NAME", "azureuser")
db_admin_password = os.getenv("DB_ADMIN_PASSWORD", "ChangePa$$w0rd24")

db_name = os.getenv("DB_NAME", "example-db1")
db_port = os.getenv("DB_PORT", 3306)

connection = mysql.connector.connect(user=f"{db_admin_name}@{db_server_name}",
    password=db_admin_password, host=f"{db_server_name}.mysql.database.azure.com",
    port=db_port, database=db_name, ssl_ca='./BaltimoreCyberTrustRoot.crt.pem')

cursor = connection.cursor()

"""
# Alternate pyodbc connection; include pyodbc in requirements.txt
import pyodbc

driver = "{MySQL ODBC 5.3 UNICODE Driver}"

connect_string = f"DRIVER={driver};PORT=3306;SERVER={db_server_name}.mysql.database.azure.com;" \
                 f"DATABASE={DB_NAME};UID={db_admin_name};PWD={db_admin_password}"

connection = pyodbc.connect(connect_string)
"""

table_name = "ExampleTable1"

sql_create = f"CREATE TABLE {table_name} (name varchar(255), code int)"

cursor.execute(sql_create)
print(f"Successfully created table {table_name}")

sql_insert = f"INSERT INTO {table_name} (name, code) VALUES ('Azure', 1)"
insert_data = "('Azure', 1)"

cursor.execute(sql_insert)
print("Successfully inserted data into table")

sql_select_values= f"SELECT * FROM {table_name}"

cursor.execute(sql_select_values)
row = cursor.fetchone()

while row:
    print(str(row[0]) + " " + str(row[1]))
    row = cursor.fetchone()

connection.commit()

# REF https://learn.microsoft.com/en-us/answers/questions/651617/python-to-query-azure-syanpase-serverless-sql.html
# server = ""
# database = 'xxx'
# username = ""
# password = ""
# cnxn = pyodbc.connect('DRIVER={ODBC Driver 17 for SQL Server};SERVER='+server+';DATABASE='+database+';UID='+username+';PWD='+ password)
# df = pd.read_sql("SELECT TOP 10 * FROM dbo.startegy_level_report", cnxn)
# cnxn.close()