,SplitOperators AS (
    SELECT 
        uid,
        TRIM(IFNULL(NULLIF(SUBSTR(operator, 1, INSTR(operator, ',') - 1), ''), operator)) AS operator,
        CASE 
            WHEN INSTR(operator, ',') THEN TRIM(SUBSTR(operator, INSTR(operator, ',') + 1))
            ELSE NULL
        END AS rest,
        past,
        plannedFuture,
        future
    FROM counted
    WHERE (:username IS NULL OR username = :username) AND future = 0
    
    UNION ALL

    SELECT
        uid,
        TRIM(IFNULL(NULLIF(SUBSTR(rest, 1, INSTR(rest, ',') - 1), ''), rest)),
        CASE 
            WHEN INSTR(rest, ',') THEN TRIM(SUBSTR(rest, INSTR(rest, ',') + 1))
            ELSE NULL
        END,
        past,
        plannedFuture,
        future
    FROM SplitOperators
    WHERE rest IS NOT NULL AND TRIM(rest) <> ''
),

-- Step 4: Calculate the top 10
top_10 AS (
    SELECT 
        operator,
        SUM(past) as 'past',
        SUM(plannedFuture) as 'plannedFuture',
        (SUM(past) + SUM(plannedFuture)) as 'count'
    FROM SplitOperators
    GROUP BY operator
    ORDER BY count DESC
    LIMIT 10
), 

-- Step 5: Calculate the 'Others'
bottom AS (
    SELECT 
        'Others' as operator,
        SUM(past) as 'past',
        SUM(plannedFuture) as 'plannedFuture',
        (SUM(past) + SUM(plannedFuture)) as 'count'
    FROM SplitOperators
    WHERE operator NOT IN (SELECT operator FROM top_10)
)

-- Step 6: Combine top_10 and 'Others' into final result
SELECT operator, past, plannedFuture, count FROM top_10
UNION ALL
SELECT operator, past, plannedFuture, count FROM bottom