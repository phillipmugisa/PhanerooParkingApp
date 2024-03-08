-- name: createService :execresult
INSERT INTO service(name, date, created_at, updated_at)
VALUES(?, ?, ?, ?);

-- name: ListService :many
SELECT * FROM service ORDER BY ID DESC;



-- name: createParkingStation :execresult
INSERT INTO parkingstation(name, codename, created_at, updated_at)
VALUES(?, ?, ?, ?);

-- name: ListParkingStation :many
SELECT * FROM parkingstation ORDER BY ID DESC;



-- name: createParkingSession :execresult
INSERT INTO parkingsession(station_id, service_id, report, created_at, updated_at)
VALUES(?, ?, ?, ?, ?);

-- name: ListParkingSession :many
SELECT * FROM parkingsession ORDER BY ID DESC;



-- name: createDepartment :execresult
INSERT INTO department(name, codename, created_at, updated_at)
VALUES(?, ?, ?, ?);

-- name: ListDepartment :many
SELECT * FROM department ORDER BY ID DESC;



-- name: createTeamMember :execresult
INSERT INTO team_member(fullname, codename, phone_number, email, is_team_leader, is_admin, department_id, created_at, updated_at)
VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?);

-- name: ListTeamMember :many
SELECT * FROM team_member ORDER BY ID DESC;



-- name: createAllocation :execresult
INSERT INTO allocation(team_member_id, parking_id, service_id, created_at, updated_at)
VALUES(?, ?, ?, ?, ?);

-- name: ListAllocation :many
SELECT * FROM allocation ORDER BY ID DESC;
