-- name: CreateToken :exec
INSERT INTO jwt_token (access_token, refresh_token, team_member_id, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: GetUserToken :one
SELECT * FROM jwt_token WHERE team_member_id = $1;

-- name: CancelToken :exec
UPDATE jwt_token
SET is_valid = FALSE
WHERE team_member_id = $1;


-- name: GetUserTokenByRefreshToken :one
SELECT * FROM jwt_token WHERE refresh_token = $1;