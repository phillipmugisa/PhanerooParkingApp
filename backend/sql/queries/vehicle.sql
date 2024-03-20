-- name: CreateDriver :one
INSERT INTO driver (fullname, phone_number, email, created_at, updated_at)
VALUES($1, $2, $3, $4, $5) RETURNING id;


-- name: ListDriver :many
SELECT * FROM driver ORDER BY ID DESC;


-- name: CreateVehicle :execresult
INSERT INTO vehicle(driver_id, license_number, model, security_notes, session_id, is_checked_out, check_in_time, check_out_time, created_at, updated_at)
VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10);

-- name: ListVehicle :many
SELECT * FROM vehicle ORDER BY ID DESC;

-- name: GetVehicleById :one
SELECT * FROM vehicle WHERE id = $1;

-- name: GetVehiclesByDriver :many
SELECT * FROM vehicle WHERE driver_id = $1;

-- name: GetVehiclesByLicense :many
SELECT * FROM vehicle WHERE license_number = $1;