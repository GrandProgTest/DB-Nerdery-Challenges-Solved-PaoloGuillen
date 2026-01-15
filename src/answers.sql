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
SELECT u.id, u.name, u.last_name, SUM(a.mount) + COALESCE(SUM(m_in.mount), 0) - COALESCE(SUM(m_out.mount), 0) AS total_money
FROM users u
JOIN accounts a ON u.id = a.user_id
LEFT JOIN movements m_in ON a.id = m_in.account_to
LEFT JOIN movements m_out ON a.id = m_out.account_from
GROUP BY u.id, u.name, u.last_name
ORDER BY total_money DESC
LIMIT 3;

-- 5

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
