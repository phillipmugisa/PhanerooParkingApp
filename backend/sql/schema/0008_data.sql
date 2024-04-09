-- +goose Up
ALTER TABLE jwt_token ADD refresh_token VARCHAR(256);

ALTER TABLE jwt_token RENAME COLUMN token TO access_token;
