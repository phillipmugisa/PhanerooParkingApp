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

	// update driver details
	update_err := a.db.UpdateDriver(ctx, database.UpdateDriverParams{
		ID:          vehicle.DriverID,
		Fullname:    vehicleData.DriverName,
		PhoneNumber: vehicleData.DriverTelNo,
		Email:       sql.NullString{String: vehicleData.DriverEmail, Valid: true},
		UpdatedAt:   time.Now(),
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
		UpdatedAt:     time.Now(),
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
		return NewApiError("Error fetching record", http.StatusBadRequest)
	}

	// check if this vehicle has has already been registered in this service
	// arguments: license plate, date
	vehicles, f_err := a.db.GetVehiclesExisting(ctx, database.GetVehiclesExistingParams{
		LicenseNumber: vehicleData.LicenseNo,
		CreatedAt:     time.Now().Add(-(24 * time.Hour)), // day before
		CreatedAt_2:   time.Now(),
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
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
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
		Model:         sql.NullString{String: vehicleData.CarModel, Valid: true},
		ServiceID:     int32(service.ID),
		ParkingID:     int32(parking.ID),
		IsCheckedOut:  sql.NullBool{Bool: false, Valid: true},
		SecurityNotes: sql.NullString{String: vehicleData.SecurityNote, Valid: true},
		CheckInTime:   sql.NullTime{Time: time.Now(), Valid: true},
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
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

	update_err := a.db.CheckoutVehicle(ctx, database.CheckoutVehicleParams{
		ID:           vehicle.ID,
		CheckOutTime: sql.NullTime{Time: time.Now(), Valid: true},
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

func (a *AppServer) GetParkingSessionHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	sessionId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	session, fetch_err := a.db.GetParkingSession(ctx, int32(sessionId))
	if fetch_err != nil {
		return NewApiError("Unable to access record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, session)
}

func (a *AppServer) CreateParkingSessionHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var parkingSessionData ParkingSessionData

	err := json.NewDecoder(r.Body).Decode(&parkingSessionData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// does the provided station and service exist
	station, fetch_err := a.db.GetParkingStation(ctx, int32(parkingSessionData.StationId))
	if fetch_err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	service, fetch_err := a.db.GetService(ctx, int32(parkingSessionData.ServiceId))
	if fetch_err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	_, write_err := a.db.CreateParkingSession(ctx, database.CreateParkingSessionParams{
		StationID: station.ID,
		ServiceID: service.ID,
		Report:    sql.NullString{String: parkingSessionData.Report, Valid: true},
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	})
	if write_err != nil {
		return NewApiError("Unable to store data", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) ListParkingSessionHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListParkingSession(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListParkingStationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListParkingStation(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) CreateParkingStationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var parkingStationData ParkingStationData

	err := json.NewDecoder(r.Body).Decode(&parkingStationData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	_, write_err := a.db.CreateParkingStation(ctx, database.CreateParkingStationParams{
		Name:      parkingStationData.Name,
		Codename:  parkingStationData.Codename,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	})
	if write_err != nil {
		return NewApiError("Unable to store data", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) GetParkingStationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	stationId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	station, fetch_err := a.db.GetParkingStation(ctx, int32(stationId))
	if fetch_err != nil {
		return NewApiError("Unable to access record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, station)
}

func (a *AppServer) GetParkingStationVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	parking_Id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.GetVehiclesByParking(ctx, int32(parking_Id))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListServicerHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListService(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) CreateServicerHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var serviceData ServiceData

	err := json.NewDecoder(r.Body).Decode(&serviceData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	_, write_err := a.db.CreateService(ctx, database.CreateServiceParams{
		Name:      serviceData.Name,
		Date:      serviceData.Date,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	})
	if write_err != nil {
		return NewApiError("Unable to store data", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) GetServicerHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	service, fetch_err := a.db.GetService(ctx, int32(serviceId))
	if fetch_err != nil {
		return NewApiError("Unable to access record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, service)
}

func (a *AppServer) GetServiceVehicleHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.GetVehiclesByService(ctx, int32(serviceId))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, HandlerResponse{Count: len(results), Results: results})
}
