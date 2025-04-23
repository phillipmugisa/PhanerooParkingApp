-- name: CreateService :execresult
INSERT INTO service(name, date, time, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: ListService :many
SELECT * FROM service ORDER BY ID DESC;

-- name: GetService :one
SELECT * FROM service WHERE id = $1;

-- name: DeleteService :execresult
DELETE FROM service where id = $1;

-- name: GetServiceWithName :one
SELECT * FROM service WHERE name LIKE '%' || $1 || '%';

-- name: GetCurrentService :many
SELECT * FROM service WHERE is_active = TRUE;

-- name: UpdateService :exec
UPDATE service 
SET name = $2, date = $3, is_active = $4 
WHERE id = $1;


-- name: CreateParkingStation :execresult
INSERT INTO parkingstation(name, codename, created_at, updated_at)
VALUES($1, $2, $3, $4);


-- name: ListServiceParkingStations :many
SELECT * FROM parkingsession
JOIN parkingstation ON station_id = parkingstation.id
WHERE service_id = $1;

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
INSERT INTO department(name, codename, accessCode, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: ListDepartment :many
SELECT * FROM department ORDER BY ID DESC;

-- name: GetDepartment :one
SELECT * FROM department WHERE id = $1;

-- name: GetDepartmentByCode :one
SELECT * FROM department WHERE codename = $1 OR accessCode = $1;


-- name: CreateTeamMember :execresult
INSERT INTO team_member(fullname, codename, phone_number, email, password, is_team_leader, is_admin, department_id, created_at, updated_at)
VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);

-- name: ListTeamMember :many
SELECT id, fullname, codename, phone_number, email, is_team_leader, is_admin, department_id FROM team_member ORDER BY ID DESC;

-- name: ListTeamMemberByDepartment :many
SELECT id, fullname, codename, phone_number, email, is_team_leader, is_admin, department_id
FROM team_member WHERE department_id = $1 ORDER BY ID DESC;

-- name: GetTeamMemberByID :one
SELECT team_member.id, fullname, team_member.codename, phone_number, email, is_team_leader, is_admin, department_id, department.codename, department.name
FROM team_member
JOIN department ON department_id = department.id
WHERE team_member.id = $1;

-- name: GetTeamMemberByCodeName :one
SELECT id, fullname, codename, phone_number, email, is_team_leader, is_admin, department_id FROM team_member WHERE codename = $1;

-- name: GetTeamMemberHashedPwd :one
SELECT password FROM team_member WHERE codename = $1;


-- name: CreateAllocation :execresult
INSERT INTO allocation(team_member_id, parking_id, service_id, created_at, updated_at)
VALUES($1, $2, $3, $4, $5);

-- name: ListAllocation :many
SELECT * FROM allocation 
JOIN parkingstation ON parking_id = parkingstation.id 
JOIN service ON service_id = service_id.id;


-- name: ListServiceAllocation :many
SELECT * FROM allocation 
JOIN parkingstation ON parking_id = parkingstation.id 
JOIN service ON allocation.service_id = service.id
JOIN team_member ON team_member.id = allocation.team_member_id
WHERE allocation.service_id = $1;


-- name: ListServiceParkingAllocation :many
SELECT allocation.id As allocationId, service.id As serviceId, service.name As serviceName, parkingstation.id As parkingId, parkingstation.codename As parkingCodeName, parkingstation.name as parkingName, team_member.id As teamMemberId, team_member.fullname As teamMemberName, team_member.codename As teamMemberCodeName  FROM allocation 
JOIN parkingstation ON parking_id = parkingstation.id 
JOIN service ON service_id = service.id 
JOIN team_member ON team_member_id = team_member.id 
WHERE service_id = $1 and parking_id = $2;

-- name: GetMemberAllocation :one
SELECT * FROM allocation JOIN parkingstation ON parking_id = parkingstation.id  WHERE team_member_id = $1 AND service_id = $2;

-- name: DeleteAllocation :execresult
DELETE FROM allocation WHERE id = $1;