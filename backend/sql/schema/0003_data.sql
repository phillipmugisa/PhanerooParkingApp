-- +goose Up
ALTER TABLE department ADD accessCode VARCHAR(5);