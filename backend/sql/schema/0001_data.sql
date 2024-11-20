-- +goose Up
CREATE TABLE IF NOT EXISTS service (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS parkingstation (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    codename VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS parkingsession (
    id SERIAL PRIMARY KEY,
    station_id INTEGER REFERENCES parkingstation(id) ON DELETE CASCADE NOT NULL,
    service_id INTEGER REFERENCES service(id) ON DELETE CASCADE NOT NULL,

    report TEXT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    codename VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS team_member (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(50) NOT NULL,
    codename VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    email VARCHAR(50) NULL,
    is_team_leader BOOLEAN DEFAULT FALSE,
    is_admin BOOLEAN DEFAULT FALSE,
    department_id INTEGER REFERENCES department(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS allocation (
    id SERIAL PRIMARY KEY,
    team_member_id INTEGER REFERENCES team_member(id) ON DELETE CASCADE NOT NULL,
    parking_id INTEGER REFERENCES parkingstation(id) ON DELETE CASCADE NOT NULL,
    service_id INTEGER REFERENCES service(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS driver (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL,
    email VARCHAR(50) NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS vehicle (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER REFERENCES driver(id) ON DELETE CASCADE NOT NULL,
    license_number VARCHAR(10) NOT NULL,
    model VARCHAR(50),
    security_notes TEXT NULL,

    parking_id INTEGER REFERENCES parkingstation(id) ON DELETE CASCADE NOT NULL,
    service_id INTEGER REFERENCES service(id) ON DELETE CASCADE NOT NULL,

    is_checked_out BOOLEAN DEFAULT FALSE,
    check_in_time TIMESTAMP NULL,
    check_out_time TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

-- +goose Down
DROP TABLE service;
DROP TABLE parkingstation;
DROP TABLE parkingsession;
DROP TABLE department;
DROP TABLE team_member;
DROP TABLE allocation;
DROP TABLE driver;
DROP TABLE vehicle;