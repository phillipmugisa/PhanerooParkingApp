-- +goose Up
CREATE TABLE IF NOT EXISTS jwk_token (
    id SERIAL PRIMARY KEY,
    token VARCHAR(256) NOT NULL,
    team_member_id INTEGER REFERENCES team_member(id) ON DELETE CASCADE NOT NULL,
    is_valid BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- +goose Down
DROP TABLE jwk_token;