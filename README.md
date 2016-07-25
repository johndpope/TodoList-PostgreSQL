# TodoList PostgreSQL

[![Build Status](https://travis-ci.com/IBM-Swift/todolist-postgresql.svg?branch=master&token=NtWCrCZmgqfHWpaxg7qx)](https://travis-ci.com/IBM-Swift/todolist-postgresql)

[![Swift 3 6-06](https://img.shields.io/badge/Swift%203-6/20 SNAPSHOT-blue.svg)](https://swift.org/download/#snapshots)

Implements the [TodoListAPI](https://github.com/IBM-Swift/todolist-api) for TodoList.

## Quick start:

1. Download the [Swift DEVELOPMENT 06-20 snapshot](https://swift.org/download/#snapshots)

2. Download PostgreSQL
  You can use `brew install postgresql`

3. Clone the TodoList PostgreSQL repository
  `git clone https://github.com/IBM-Swift/todolist-postgresql`

4. Fetch the test cases by running:
  `git clone https://github.com/IBM-Swift/todolist-tests Tests`

5. Compile the library with `swift build -Xcc -I/usr/local/include` or create an XCode project with `swift package generate-xcodeproj`

6. Run the test cases with `swift test` or directly from XCode

## Deploying to Bluemix:

1. Get an account for Bluemix

2. Select the PostgreSQL by Compose Service

3. Set the Service name as todolist-postgresql2 then initialize the Host, Port, Username, and Password to the values instantiated

4. Upon creation, you should see your unbound service on the dashboard page

5. SSH to the server and enter your password credentials (i.e)

```sql
psql "sslmode=require host=INSERT_HOST_NAME port=INSERT_PORT_NUM dbname=compose user=admin"
```

6. Once in the server, create a database called "todolist"

```sql
create database todolist;
```

7. Then create the table called "todos"

```sql
create table todos(tid BIGSERIAL PRIMARY KEY, user_id varchar(128) NOT NULL, title varchar(256) NOT NULL, completed boolean NOT NULL, ordering INTEGER NOT NULL);
```

8. To confirm if you have the table created, you can ```\d todos```

9. Dowload and install the Cloud Foundry tools:

```
cf login
bluemix api https://api.ng.bluemix.net
bluemix login -u username -o org_name -s space_name
```

```
Be sure to change the directory to the todolist-postgresql directory where the manifest.yml file is located.
```

10. Run ```cf push```

11. It should take several minutes, roughly 4-6 minutes. If it works correctly, it should state

```
2 of 2 instances running
App started
```
