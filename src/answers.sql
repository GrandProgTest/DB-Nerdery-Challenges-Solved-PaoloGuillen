-- Your answers here:
-- 1
SELECT type, SUM(mount) AS mount_per_type FROM accounts GROUP BY type;
-- 2
WITH UsersGroupedBy AS
(SELECT users.name, 
COUNT(accounts.user_id)  as total_users_count FROM users LEFT JOIN accounts ON users.id = accounts.user_id 
WHERE accounts.type = 'CURRENT_ACCOUNT' GROUP BY users.name 
    HAVING COUNT(accounts.user_id) >= 2
)
SELECT COUNT(name) FROM UsersGroupedBy;

-- 3
SELECT * FROM accounts ORDER BY mount DESC LIMIT 5;

-- 4
WITH total_mount_in AS (
  SELECT
    a.id,
    a.user_id,
    a.mount + COALESCE(SUM(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END), 0) + COALESCE(SUM(CASE WHEN m.account_from = a.id AND m.type = 'IN' THEN m.mount ELSE 0 END), 0) AS mount_account
  FROM accounts a
  LEFT JOIN movements m
    ON m.account_to = a.id OR m.account_from = a.id
  GROUP BY a.id, a.user_id, a.mount
),
total_real_mount AS(
 select tot.id, tot.user_id,   
 tot.mount_account - COALESCE(SUM(CASE WHEN m.account_from = tot.id AND m.type IN ('OUT', 'OTHER') THEN m.mount ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN m.account_from = tot.id AND m.account_to IS NOT NULL THEN m.mount ELSE 0 END), 0) AS mount_account_real
 from total_mount_in tot
 LEFT JOIN movements m ON m.account_from = tot.id
 GROUP BY tot.id, tot.user_id, tot.mount_account
)
select users.name, users.last_name, users.email, SUM(total_real_mount.mount_account_real),users.id FROM total_real_mount 
LEFT JOIN users ON total_real_mount.user_id = users.id
GROUP BY users.name, users.last_name, users.email, users.id ORDER BY SUM(total_real_mount.mount_account_real) DESC LIMIT 3;



-- 5

BEGIN;

DROP FUNCTION IF EXISTS get_total_money(UUID);
CREATE OR REPLACE FUNCTION get_total_money(s_account_id UUID) 
RETURNS DOUBLE PRECISION 
LANGUAGE plpgsql
AS
$$
DECLARE
    final_amount DOUBLE PRECISION;
BEGIN
    WITH total_mount_in AS (
        SELECT
            a.id,
            a.mount + COALESCE(SUM(CASE WHEN m.account_to = a.id THEN m.mount ELSE 0 END), 0) + COALESCE(SUM(CASE WHEN m.account_from = a.id AND m.type = 'IN' THEN m.mount ELSE 0 END), 0) AS mount_account
        FROM accounts a
        LEFT JOIN movements m ON m.account_to = a.id OR m.account_from = a.id
        WHERE a.id = s_account_id
        GROUP BY a.id, a.mount
    ),
    total_real_mount AS (
        SELECT 
            tot.mount_account - COALESCE(SUM(CASE WHEN m.account_from = tot.id AND m.type IN ('OUT', 'OTHER') THEN m.mount ELSE 0 END), 0) - COALESCE(SUM(CASE WHEN m.account_from = tot.id AND m.account_to IS NOT NULL THEN m.mount ELSE 0 END), 0) AS mount_account_real
        FROM total_mount_in tot
        LEFT JOIN movements m ON m.account_from = tot.id
        GROUP BY tot.mount_account
    )
    SELECT mount_account_real INTO final_amount
    FROM total_real_mount;

    RETURN final_amount;
END;
$$;

SELECT 
    u.name, 
    u.last_name, 
    u.email, 
    get_total_money(a.id) AS account_balance
FROM accounts a
LEFT JOIN users u ON a.user_id = u.id
WHERE a.id IN ('3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590');

INSERT INTO movements(id, type, account_from, account_to, mount, created_at, updated_at)
VALUES('426647b2-9abd-4b9a-a987-624022b37437', 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 50.75, NOW(), NOW());

INSERT INTO movements(id, type, account_from, account_to, mount, created_at, updated_at)
VALUES('61b11806-d674-44e3-97db-2aaba41f5784', 'TRANSFER', '3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590', 731823.56, NOW(), NOW());

SELECT 
    u.name, 
    u.last_name, 
    u.email, 
    get_total_money(a.id) AS account_balance
FROM accounts a
LEFT JOIN users u ON a.user_id = u.id
WHERE a.id IN ('3b79e403-c788-495a-a8ca-86ad7643afaf', 'fd244313-36e5-4a17-a27c-f8265bc46590');

SELECT CASE 
    WHEN get_total_money('3b79e403-c788-495a-a8ca-86ad7643afaf') < 0 
    THEN 1/0 
    ELSE 1 
END AS transaction_status;

COMMIT;

-- 6
SELECT u.id, u.name, u.last_name, u.email, m.id as movement_id, m.type as movement_type, m.account_from, m.account_to, m.mount, m.created_at as movement_created_at
FROM movements m
JOIN accounts a ON (a.id = m.account_from OR a.id = m.account_to)
JOIN users u ON u.id = a.user_id
WHERE a.id = '3b79e403-c788-495a-a8ca-86ad7643afaf';

-- 7
SELECT u.name, u.email, SUM(a.mount) + COALESCE(SUM(m_in.mount), 0) - COALESCE(SUM(m_out.mount), 0) AS total_money
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN movements m_in ON a.id = m_in.account_to
LEFT JOIN movements m_out ON a.id = m_out.account_from
GROUP BY u.id, u.name, u.email
ORDER BY total_money DESC
LIMIT 1;

-- 8
SELECT m.*, a.type as account_type
FROM movements m
JOIN accounts a ON (a.id = m.account_from OR a.id = m.account_to)
JOIN users u ON u.id = a.user_id
WHERE u.email = 'Kaden.Gusikowski@gmail.com'
ORDER BY a.type, m.created_at;
