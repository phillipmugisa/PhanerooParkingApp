-- name: CreateDriver :one
INSERT INTO driver (fullname, phone_number, email, created_at, updated_at)
VALUES($1, $2, $3, $4, $5) RETURNING id;

-- name: ListDriver :many
SELECT * FROM driver ORDER BY ID DESC;

-- name: GetDriverById :one
SELECT * FROM driver WHERE id = $1;

-- name: GetDriverByName :one
SELECT * FROM driver WHERE fullname LIKE $1;

-- name: DeleteDriverById :exec
DELETE FROM driver WHERE id = $1;

-- name: UpdateDriver :exec
UPDATE driver
SET fullname = $2, phone_number = $3,
    email = $4, updated_at = $5
WHERE id = $1;

-- name: CreateVehicle :execresult
INSERT INTO vehicle(driver_id, license_number, card_number, vehicle_type, occupants, model, security_notes, parking_id, service_id, checked_in_by, is_checked_out, check_in_time, created_at, updated_at)
VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14);

-- name: DeleteVehicleById :exec
DELETE FROM vehicle WHERE id = $1;

-- name: ListVehicle :many
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id ORDER BY vehicle.ID DESC;

-- name: GetVehicleById :one
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id  WHERE vehicle.id = $1;

-- name: GetVehiclesByService :many
SELECT
  vehicle.*,                                -- All vehicle fields
  driver.*,                                 -- All driver fields
  checkin_member.codename AS checked_in_by_codename,     -- Codename of check-in team member
  checkout_member.codename AS checked_out_by_codename,   -- Codename of check-out team member
  parkingstation.codename AS parked_at     -- Codename of the parking station
FROM vehicle
JOIN driver ON vehicle.driver_id = driver.id
JOIN team_member AS checkin_member ON checkin_member.id = vehicle.checked_in_by
JOIN team_member AS checkout_member ON checkout_member.id = vehicle.checked_out_by
JOIN parkingstation ON parkingstation.id = vehicle.parking_id
WHERE vehicle.service_id = $1;



-- name: GetVehiclesByParking :many
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id  WHERE vehicle.parking_id = $1;


-- name: GroupVehiclesByParking :many
SELECT COUNT(vehicle.ID), parkingstation.name, parkingstation.codename
FROM vehicle
JOIN driver ON vehicle.driver_id = driver.id
JOIN parkingstation ON vehicle.parking_id = parkingstation.id
GROUP BY(parkingstation.id);

-- name: GroupVehiclesByParkingAndService :many
SELECT COUNT(vehicle.ID), parkingstation.name, parkingstation.codename
FROM vehicle
JOIN driver ON vehicle.driver_id = driver.id
JOIN parkingstation ON vehicle.parking_id = parkingstation.id
WHERE vehicle.service_id = $1
GROUP BY parkingstation.id;

-- name: GetVehiclesByDriver :many
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id  WHERE vehicle.driver_id = $1;

-- name: CheckoutVehicle :exec
UPDATE vehicle
SET check_out_time = $2,
    is_checked_out = $3,
    checked_out_by = $4
WHERE id = $1;

-- name: GetVehiclesByLicense :many
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id  WHERE vehicle.license_number = $1;

-- name: UpdateVehicle :exec
UPDATE vehicle
SET driver_id = $2, license_number = $3,
    model = $4, security_notes = $5,
    updated_at = $6
WHERE id = $1;

-- name: GetVehiclesExisting :many
SELECT * FROM vehicle WHERE license_number = $1 AND service_id = $2;

-- name: SearchVehicle :many
SELECT * FROM vehicle JOIN driver ON vehicle.driver_id = driver.id
WHERE vehicle.license_number LIKE '%'||$1||'%' OR driver.fullname LIKE '%'||$1||'%' OR vehicle.card_number LIKE '%'||$1||'%'
ORDER BY vehicle.created_at DESC;
