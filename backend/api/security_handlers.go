package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/phillipmugisa/PhanerooParkingApp/database"
)

func (a *AppServer) ListDepartmentsHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListDepartment(ctx)
	if err != nil {
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

func (a *AppServer) ListDepartmentTeamHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, err := a.db.ListTeamMemberByDepartment(ctx, int32(id))
	if err != nil {
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

func (a *AppServer) GetDepartmentHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	department, f_err := a.db.GetDepartment(ctx, int32(id))
	if f_err != nil {
		if errors.Is(f_err, sql.ErrNoRows) {
			return RespondWithJSON(w, http.StatusNotFound, struct{}{})
		}
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, department)
}

func (a *AppServer) CreateDepartmentHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var departmentData DepartmentData

	err := json.NewDecoder(r.Body).Decode(&departmentData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// generate code
	// accessCode := uuid.New().String()[:5]
	// _, f_err := a.db.GetDepartmentByCode(ctx, accessCode)
	// if f_err != nil {
	// 	if errors.Is(f_err, sql.ErrNoRows) {
	// 		accessCode = uuid.New().String()[:5]
	// 	} else {
	// 		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	// 	}
	// }
	accessCode := "00000"

	a.db.CreateDepartment(ctx, database.CreateDepartmentParams{
		Name:       departmentData.Name,
		Codename:   departmentData.Codename,
		Accesscode: sql.NullString{String: accessCode, Valid: true},
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	})

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) GetParkingSessionHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	sessionId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	session, fetch_err := a.db.GetParkingSession(ctx, int32(sessionId))
	if fetch_err != nil {
		return NewApiError("Unable to access record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, session)
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

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListParkingStationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListParkingStation(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
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

	results, err := a.db.ListParkingStation(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	// send last created
	return RespondWithJSON(w, http.StatusCreated, results[0])
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

	return RespondWithJSON(w, http.StatusOK, station)
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

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListParkingSectionGroupsHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {

	groups, err := a.db.GroupVehiclesByParking(ctx)
	if err != nil {
		return NewApiError("Error fetching records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, groups)
}
func (a *AppServer) ListParkingSectionAndServiceGroupsHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	service_id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.GroupVehiclesByParkingAndService(ctx, int32(service_id))
	if fetch_err != nil {
		return NewApiError("Error fetching records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListServicerHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListService(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) GetCurrentServicerHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListService(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	if len(results) < 1 {
		return RespondWithJSON(w, http.StatusCreated, struct{}{})
	}
	return RespondWithJSON(w, http.StatusOK, results[0])
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
		Time:      sql.NullTime{Time: serviceData.Time, Valid: true},
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	})
	if write_err != nil {
		return NewApiError("Unable to store data", http.StatusInternalServerError)
	}

	results, err := a.db.ListService(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, results[0])
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

	return RespondWithJSON(w, http.StatusOK, service)
}

func (a *AppServer) UpdateServiceHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, e := strconv.Atoi(chi.URLParam(r, "id"))
	if e != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	var serviceData ServiceData
	err := json.NewDecoder(r.Body).Decode(&serviceData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// update details
	u_err := a.db.UpdateService(ctx, database.UpdateServiceParams{
		ID:   int32(serviceId),
		Name: serviceData.Name,
		Date: serviceData.Date,
	})
	if u_err != nil {
		return NewApiError("Unable to update data", http.StatusInternalServerError)
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

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) GetServiceParkingStationsHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.ListServiceParkingStations(ctx, int32(serviceId))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) ListAllocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListAllocation(ctx)
	if err != nil {
		return NewApiError("Error fetching record", http.StatusInternalServerError)
	}
	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) CreateAllocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var allocationData AllocationData

	err := json.NewDecoder(r.Body).Decode(&allocationData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	_, write_err := a.db.CreateAllocation(ctx, database.CreateAllocationParams{
		TeamMemberID: int32(allocationData.TeamMemberId),
		ParkingID:    int32(allocationData.ParkingId),
		ServiceID:    int32(allocationData.ServiceId),
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	})
	if write_err != nil {
		return NewApiError("Unable to store data", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) ListServiceAllocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.ListServiceAllocation(ctx, int32(serviceId))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}

func (a *AppServer) GetTeamMemberServiceallocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	teamMemberId, err := strconv.Atoi(chi.URLParam(r, "tid"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	serviceId, err := strconv.Atoi(chi.URLParam(r, "sid"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	result, fetch_err := a.db.GetMemberAllocation(ctx, database.GetMemberAllocationParams{
		TeamMemberID: int32(teamMemberId),
		ServiceID:    int32(serviceId),
	})
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, result)
}

func (a *AppServer) DeleteAllocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	allocationId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	_, fetch_err := a.db.DeleteAllocation(ctx, int32(allocationId))
	if fetch_err != nil {
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, struct{}{})
}

func (a *AppServer) ListServiceParkingAllocationHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	serviceId, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	parking_id, err := strconv.Atoi(chi.URLParam(r, "pid"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	results, fetch_err := a.db.ListServiceParkingAllocation(ctx, database.ListServiceParkingAllocationParams{
		ServiceID: int32(serviceId),
		ParkingID: int32(parking_id),
	})
	if fetch_err != nil {
		fmt.Printf("\n\n %v \n\n", fetch_err)
		return NewApiError("Unable to access records", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{Count: len(results), Results: results})
}
