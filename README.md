<p align="center" style="background-color:white">
 <a href="https://www.ravn.co/" rel="noopener">
 <img src="src/ravn_logo.png" alt="RAVN logo" width="150px"></a>
</p>
<p align="center">
 <a href="https://www.postgresql.org/" rel="noopener">
 <img src="https://www.postgresql.org/media/img/about/press/elephant.png" alt="Postgres logo" width="150px"></a>
</p>

---

<p align="center">A project to show off your skills on databases & SQL using a real database</p>

## 📝 Table of Contents

- [Case](#case)
- [Installation](#installation)
- [Data Recovery](#data_recovery)
- [Excersises](#excersises)

## 🤓 Case <a name = "case"></a>

As a developer and expert on SQL, you were contacted by a company that needs your help to manage their database which runs on PostgreSQL. The database provided contains four entities: Employee, Office, Countries and States. The company has different headquarters in various places around the world, in turn, each headquarters has a group of employees of which it is hierarchically organized and each employee may have a supervisor. You are also provided with the following Entity Relationship Diagram (ERD)

#### ERD - Diagram <br>

![Comparison](src/ERD.png) <br>

---

## 🛠️ Docker Installation <a name = "installation"></a>

1. Install [docker](https://docs.docker.com/engine/install/)

---

## 📚 Recover the data to your machine <a name = "data_recovery"></a>

Open your terminal and run the follows commands:

1. This will create a container for postgresql:

```
docker run --name nerdery-container -e POSTGRES_PASSWORD=password123 -p 5432:5432 -d --rm postgres:15.2
```

2. Now, we access the container:

```
docker exec -it -u postgres nerdery-container psql
```

3. Create the database:

```
create database nerdery_challenge;
```

5. Close the database connection:
```
\q
```

4. Restore de postgres backup file

```
cat /.../dump.sql | docker exec -i nerdery-container psql -U postgres -d nerdery_challenge
```

- Note: The `...` mean the location where the src folder is located on your computer
- Your data is now on your database to use for the challenge

---

## 📊 Excersises <a name = "excersises"></a>

Now it's your turn to write SQL queries to achieve the following results (You need to write the query in the section `Your query here` on each question):

1. Total money of all the accounts group by types.

```
SELECT type, SUM(mount) AS mount_per_type FROM accounts GROUP BY type;
```


2. How many users with at least 2 `CURRENT_ACCOUNT`.

```
WITH UsersGroupedBy AS
(SELECT users.name, 
COUNT(accounts.user_id)  as total_users_count FROM users LEFT JOIN accounts ON users.id = accounts.user_id 
WHERE accounts.type = 'CURRENT_ACCOUNT' GROUP BY users.name 
    HAVING COUNT(accounts.user_id) >= 2
)
SELECT COUNT(name) FROM UsersGroupedBy;
```


3. List the top five accounts with more money.

```
SELECT * FROM accounts ORDER BY mount DESC LIMIT 5;
```


4. Get the three users with the most money after making movements.

```
SELECT u.id, u.name, u.last_name, SUM(a.mount) + COALESCE(SUM(m_in.mount), 0) - COALESCE(SUM(m_out.mount), 0) AS total_money
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN movements m_in ON a.id = m_in.account_to
LEFT JOIN movements m_out ON a.id = m_out.account_from
GROUP BY u.id, u.name, u.last_name
ORDER BY total_money DESC
LIMIT 3;

```


5. In this part you need to create a transaction with the following steps:

    a. First, get the ammount for the account `3b79e403-c788-495a-a8ca-86ad7643afaf` and `fd244313-36e5-4a17-a27c-f8265bc46590` after all their movements.
    ```
    ```
    
    b. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` make a transfer to `fd244313-36e5-4a17-a27c-f8265bc46590`
        mount: 50.75
    ```
    ```

    c. Add a new movement with the information:
        from: `3b79e403-c788-495a-a8ca-86ad7643afaf` 
        type: OUT
        mount: 731823.56
    ```
    ```

        * Note: if the account does not have enough money you need to reject this insert and make a rollback for the entire transaction
    
    d. Put your answer here if the transaction fails(YES/NO):
    ```
    ```

    e. If the transaction fails, make the correction on step _c_ to avoid the failure:
    ```
   
    ```

    f. Once the transaction is correct, make a commit
    ```
    ```

    e. How much money the account `fd244313-36e5-4a17-a27c-f8265bc46590` have:
    ```

    ```


6. All the movements and the user information with the account `3b79e403-c788-495a-a8ca-86ad7643afaf`

```
SELECT u.id, u.name, u.last_name, u.email, m.id as movement_id, m.type as movement_type, m.account_from, m.account_to, m.mount, m.created_at as movement_created_at
FROM movements m
JOIN accounts a ON (a.id = m.account_from OR a.id = m.account_to)
JOIN users u ON u.id = a.user_id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';
```


7. The name and email of the user with the highest money in all his/her accounts

```
SELECT u.name, u.email, SUM(a.mount) + COALESCE(SUM(m_in.mount), 0) - COALESCE(SUM(m_out.mount), 0) AS total_money
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN movements m_in ON a.id = m_in.account_to
LEFT JOIN movements m_out ON a.id = m_out.account_from
GROUP BY u.id, u.name, u.email
ORDER BY total_money DESC
LIMIT 1;
```


8. Show all the movements for the user `Kaden.Gusikowski@gmail.com` order by account type and created_at on the movements table

```
Your query here
```