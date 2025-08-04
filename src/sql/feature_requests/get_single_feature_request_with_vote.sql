SELECT 
    fr.id,
    fr.title,
    fr.description,
    fr.username,
    fr.status,
    fr.created,
    fr.upvotes,
    fr.downvotes,
    fr.score,
    CASE 
        WHEN frv.vote_type = 'upvote' THEN 1
        WHEN frv.vote_type = 'downvote' THEN -1
        ELSE 0
    END as user_vote
FROM feature_requests fr
LEFT JOIN feature_request_votes frv ON fr.id = frv.feature_request_id 
    AND frv.username = :username
WHERE fr.id = :request_id