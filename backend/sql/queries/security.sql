-- name: CreateService :execresult
INSERT INTO service(name, date, created_at, updated_at)
VALUES($1, $2, $3, $4);

-- name: ListService :many
SELECT * FROM service ORDER BY ID DESC;

-- name: GetService :one
SELECT * FROM service WHERE id = $1;


-- name: CreateParkingStation :execresult
INSERT INTO parkingstation(name, codename, created_at, updated_at)
VALUES($1, $2, $3, $4);

-- name: ListParkingStation :many
SELECT * FROM parkingstation ORDER BY ID DESC;

-- name: GetParkingStation :one
SELECT * FROM parkingstation WHERE id = $1;



-- name: CreateParkingSession :execresult
INSERT INTO parkingsession(station_id, service_id, report, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: ListParkingSession :many
SELECT * FROM parkingsession ORDER BY ID DESC;

-- name: GetParkingSession :one
SELECT * FROM parkingsession WHERE id = $1;


-- name: CreateDepartment :execresult
INSERT INTO department(name, codename, created_at, updated_at)
VALUES($1, $2, $3, $4);

-- name: ListDepartment :many
SELECT * FROM department ORDER BY ID DESC;



-- name: CreateTeamMember :execresult
INSERT INTO team_member(fullname, codename, phone_number, email, is_team_leader, is_admin, department_id, created_at, updated_at)
VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9);

-- name: ListTeamMember :many
SELECT * FROM team_member ORDER BY ID DESC;



-- name: CreateAllocation :execresult
INSERT INTO allocation(team_member_id, parking_id, service_id, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: ListAllocation :many
SELECT * FROM allocation ORDER BY ID DESC;
