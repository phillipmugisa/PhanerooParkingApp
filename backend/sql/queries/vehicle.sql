-- name: createDriver :execresult
INSERT INTO driver(fullname, phone_number, email, created_at, updated_at)
VALUES(?, ?, ?, ?, ?);

-- name: ListDriver :many
SELECT * FROM driver ORDER BY ID DESC;


-- name: createVehicle :execresult
INSERT INTO vehicle(driver_id, license_number, model, security_notes, session_id, is_checked_out, check_in_time, check_out_time, created_at, updated_at)
VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);

-- name: ListVehicle :many
SELECT * FROM vehicle ORDER BY ID DESC;

-- name: getVehicle :one
SELECT * FROM vehicle WHERE id = ? OR driver_id = ? OR license_number = ?;
