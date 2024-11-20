-- +goose Up
ALTER TABLE vehicle ALTER COLUMN card_number SET DATA TYPE VARCHAR(50);
