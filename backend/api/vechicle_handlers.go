package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/phillipmugisa/PhanerooParkingApp/database"
)

func (a *AppServer) ListDriversHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListDriver(ctx)
	if err != nil {
		return NewApiError(err.Error(), http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

func (a *AppServer) GetDriversHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	driver_id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	driver, fetch_err := a.db.GetDriverById(ctx, int32(driver_id))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, driver)
}

func (a *AppServer) ListVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	// fetch all vehicles
	results, err := a.db.ListVehicle(ctx)
	if err != nil {
		return NewApiError(err.Error(), http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

func (a *AppServer) GetVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	vehicle_id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	vehicle, fetch_err := a.db.GetVehicleById(ctx, int32(vehicle_id))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, vehicle)
}

func (a *AppServer) UpdateVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	vehicle_id, e := strconv.Atoi(chi.URLParam(r, "id"))
	if e != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	var vehicleData VehicleData
	err := json.NewDecoder(r.Body).Decode(&vehicleData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// get vehicle driver data
	vehicle, f_err := a.db.GetVehicleById(ctx, int32(vehicle_id))
	if f_err != nil {
		return NewApiError("Unable to access record", http.StatusBadRequest)
	}

	location, err := time.LoadLocation("Africa/Kampala")
	if err != nil {
		// Handle error loading timezone
		return NewApiError("Unable to get time zone", http.StatusBadRequest)
	}

	// update driver details
	update_err := a.db.UpdateDriver(ctx, database.UpdateDriverParams{
		ID:          vehicle.DriverID,
		Fullname:    vehicleData.DriverName,
		PhoneNumber: vehicleData.DriverTelNo,
		Email:       sql.NullString{String: vehicleData.DriverEmail, Valid: true},
		UpdatedAt:   time.Now().In(location),
	})
	if update_err != nil {
		return NewApiError("Unable to update data", http.StatusInternalServerError)
	}

	// update vehicle details
	u_err := a.db.UpdateVehicle(ctx, database.UpdateVehicleParams{
		ID:            int32(vehicle_id),
		DriverID:      vehicle.DriverID,
		LicenseNumber: vehicleData.LicenseNo,
		Model:         sql.NullString{String: vehicleData.CarModel, Valid: true},
		SecurityNotes: sql.NullString{String: vehicleData.SecurityNote, Valid: true},
		UpdatedAt:     time.Now().In(location),
	})
	if u_err != nil {
		return NewApiError("Unable to update data", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, struct{}{})
}

func (a *AppServer) RegisterVehicleHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var vehicleData VehicleData
	err := json.NewDecoder(r.Body).Decode(&vehicleData)
	if err != nil {
		fmt.Println(err)
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// confirm that the parking and service id exists
	service, err := a.db.GetService(ctx, int32(vehicleData.ServiceId))
	if err != nil {
		return NewApiError("Unable to found specified service ", http.StatusBadRequest)
	}

	location, err := time.LoadLocation("Africa/Kampala")
	if err != nil {
		// Handle error loading timezone
		return NewApiError("Unable to get time zone", http.StatusBadRequest)
	}

	// check if this vehicle has has already been registered in this service
	// arguments: license plate, date
	vehicles, f_err := a.db.GetVehiclesExisting(ctx, database.GetVehiclesExistingParams{
		LicenseNumber: vehicleData.LicenseNo,
		CreatedAt:     time.Now().In(location).Add(-(24 * time.Hour)), // day before
		CreatedAt_2:   time.Now().In(location),
		ServiceID:     service.ID,
	})
	if f_err != nil {
		return NewApiError("Unable to process data", http.StatusBadRequest)
	}
	if len(vehicles) > 0 {
		return NewApiError("Vehicle Already Registered for this service", http.StatusConflict)
	}

	// create driver
	driver_id, err := a.db.CreateDriver(ctx, database.CreateDriverParams{
		Fullname:    vehicleData.DriverName,
		PhoneNumber: vehicleData.DriverTelNo,
		Email:       sql.NullString{String: vehicleData.DriverEmail},
		CreatedAt:   time.Now().In(location),
		UpdatedAt:   time.Now().In(location),
	})
	if err != nil {
		return NewApiError("Unable to store driver data", http.StatusBadRequest)
	}

	// confirm that the parking and service id exists
	parking, err := a.db.GetParkingStation(ctx, int32(vehicleData.ParkingId))
	if err != nil {
		return NewApiError("Error fetching record", http.StatusBadRequest)
	}

	// register vehicle
	_, v_write_err := a.db.CreateVehicle(ctx, database.CreateVehicleParams{
		DriverID:      int32(driver_id),
		LicenseNumber: vehicleData.LicenseNo,
		CardNumber:    sql.NullString{String: vehicleData.CardNumber, Valid: true},
		Model:         sql.NullString{String: vehicleData.CarModel, Valid: true},
		ServiceID:     int32(service.ID),
		ParkingID:     int32(parking.ID),
		IsCheckedOut:  sql.NullBool{Bool: false, Valid: true},
		SecurityNotes: sql.NullString{String: vehicleData.SecurityNote, Valid: true},
		CheckInTime:   sql.NullTime{Time: time.Now().In(location), Valid: true},
		CreatedAt:     time.Now().In(location),
		UpdatedAt:     time.Now().In(location),
	})
	if v_write_err != nil {
		return NewApiError("Unable to store vehicle data", http.StatusBadRequest)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) CheckoutVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	vehicle_id, e := strconv.Atoi(chi.URLParam(r, "id"))
	if e != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	// get vehicle driver data
	vehicle, f_err := a.db.GetVehicleById(ctx, int32(vehicle_id))
	if f_err != nil {
		return NewApiError("Unable to access record", http.StatusBadRequest)
	}

	location, err := time.LoadLocation("Africa/Kampala")
	if err != nil {
		// Handle error loading timezone
		return NewApiError("Unable to get time zone", http.StatusBadRequest)
	}

	update_err := a.db.CheckoutVehicle(ctx, database.CheckoutVehicleParams{
		ID:           vehicle.ID,
		CheckOutTime: sql.NullTime{Time: time.Now().In(location), Valid: true},
		IsCheckedOut: sql.NullBool{Bool: true, Valid: true},
	})
	if update_err != nil {
		return NewApiError("Unable to update record", http.StatusBadRequest)
	}

	return RespondWithJSON(w, http.StatusOK, struct{}{})
}

func (a *AppServer) SearchVehicleHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {

	keyword := r.URL.Query().Get("q")
	if len(keyword) < 2 {
		return NewApiError("Provide appropriate keyword", http.StatusBadRequest)
	}

	results, err := a.db.SearchVehicle(ctx, sql.NullString{String: keyword, Valid: true})
	if err != nil {
		return NewApiError("Unable to retrieve record", http.StatusBadRequest)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

// func (a *AppServer) GetVehicleParkingSessionHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
// 	// Parse query parameters
// 	v_id := r.URL.Query().Get("vehicleId")
// 	if v_id != "" {
// 		vehicle_id, err := strconv.Atoi(v_id)
// 		if err != nil {
// 			return NewApiError("Invalid data", http.StatusBadRequest)
// 		}

// 		// fetch vehicle with this id
// 		vehicle, err := a.db.GetVehicleById(ctx, int32(vehicle_id))
// 		if err != nil {
// 			return NewApiError("Record not found", http.StatusNotFound)
// 		}

// 		// the vehicle exist, fetch the parking session
// 		session, err := a.db.GetParkingSession(ctx, int32(vehicle.SessionID))
// 		if err != nil {
// 			return NewApiError("Error fetching record", http.StatusBadRequest)
// 		}

// 		return RespondWithJSON(w, http.StatusCreated, session)
// 	}

// 	// no vehicle id supplied, return the last created
// 	sessions, err := a.db.ListParkingSession(ctx)
// 	if err != nil {
// 		return NewApiError("Error fetching record", http.StatusBadRequest)
// 	}

// 	if len(sessions) == 0 {
// 		return RespondWithJSON(w, http.StatusCreated, sessions)
// 	}

// 	return RespondWithJSON(w, http.StatusCreated, sessions[0])
// }
