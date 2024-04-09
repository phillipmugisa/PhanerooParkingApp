-- +goose Up
ALTER TABLE team_member ADD password VARCHAR(256);