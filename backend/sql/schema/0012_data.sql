-- +goose Up
ALTER TABLE vehicle ADD occupants VARCHAR(50) DEFAULT '1';
