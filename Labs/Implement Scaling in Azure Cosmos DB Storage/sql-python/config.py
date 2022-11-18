import os

settings = {
    # Available @ Admin Console >> Cosmos DB Service >> Keys >> URI
    'host': os.environ.get('ACCOUNT_HOST', 'https://cosmosterraformdemoversion-zcw7.documents.azure.com:443/'),
    # Available @ Admin Console >> Cosmos DB Service >> Keys >> PRIMARY_KEY
    'master_key': os.environ.get('ACCOUNT_KEY', 'eq23JMHQWWWsmEe5P4kDmcjpeXsbjWwPZcenwqFBCxbulsBw5xs5iLcFJ6AlqLTHXGB2bO39fff5ACDbxhlMmw=='),

    # These are from the lab
    'database_id': os.environ.get('COSMOS_DATABASE', 'ToDoDatabase'),
    'container_id': os.environ.get('COSMOS_CONTAINER', 'ToDoList'),
}