-- +goose Up
ALTER TABLE vehicle ADD occupants VARCHAR(10) DEFAULT '1';

ALTER TABLE vehicle ADD vehicle_type VARCHAR(10) DEFAULT 'CAR';

-- +goose Down
ALTER TABLE vehicle
DROP COLUMN occupants;

ALTER TABLE vehicle
DROP COLUMN vehicleType;
