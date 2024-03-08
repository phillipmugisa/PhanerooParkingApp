-- +goose Up
CREATE TABLE service (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20),
    date TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE parkingstation (
    id SERIAL PRIMARY KEY,
    name VARCHAR(20),
    codename VARCHAR(20),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE parkingsession (
    id SERIAL PRIMARY KEY,
    station_id INTEGER REFERENCES parkingstation(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service(id) ON DELETE CASCADE,

    report TEXT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE department (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    codename VARCHAR(15),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE team_member (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(50),
    codename VARCHAR(50),
    phone_number VARCHAR(15),
    email VARCHAR(50) NULL,
    is_team_leader BOOLEAN NULL,
    is_admin BOOLEAN NULL,
    department_id INTEGER REFERENCES department(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE allocation (
    id SERIAL PRIMARY KEY,
    team_member_id INTEGER REFERENCES team_member(id) ON DELETE CASCADE,
    parking_id INTEGER REFERENCES parkingstation(id) ON DELETE CASCADE,
    service_id INTEGER REFERENCES service(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE driver (
    id SERIAL PRIMARY KEY,
    fullname VARCHAR(50),
    phone_number VARCHAR(15),
    email VARCHAR(50) NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE vehicle (
    id SERIAL PRIMARY KEY,
    driver_id INTEGER REFERENCES driver(id) ON DELETE CASCADE,
    license_number VARCHAR(10),
    model VARCHAR(20),
    security_notes TEXT NULL,

    session_id INTEGER REFERENCES parkingsession(id) ON DELETE CASCADE,

    is_checked_out BOOLEAN NULL,
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