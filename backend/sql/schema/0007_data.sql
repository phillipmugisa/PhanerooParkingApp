-- +goose Up
ALTER TABLE jwk_token RENAME TO jwt_token;