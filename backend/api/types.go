package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/golang-jwt/jwt"
	"github.com/phillipmugisa/PhanerooParkingApp/database"
)

type AppServer struct {
	port string
	db   *database.Queries
}

func NewAppServer(p string, db *sql.DB) *AppServer {
	return &AppServer{
		port: p,
		db:   database.New(db),
	}
}

func (a *AppServer) StartServer() {
	fmt.Printf("Starting server on port %s...\n", a.port)
	server := a.Run()

	go func() {
		err := server.ListenAndServe()
		if err != nil {
			log.Fatal("Unable to start server: ", err)
		}
	}()

	killServer := make(chan os.Signal, 1)
	signal.Notify(killServer, os.Interrupt, syscall.SIGINT, syscall.SIGTERM)

	<-killServer
	fmt.Printf("Shutting down server...\n")

	ctx, _ := context.WithTimeout(context.Background(), 30*time.Second)
	server.Shutdown(ctx)
}

type ApiError struct {
	Message string
	Status  int
}

func NewApiError(msg string, status int) *ApiError {
	return &ApiError{
		Message: msg,
		Status:  status,
	}
}

func (a ApiError) Error() string {
	return a.Message
}

type ApiHandler func(context.Context, http.ResponseWriter, *http.Request) *ApiError

type HandlerResponse struct {
	Count   int `json:"count"`
	Results any `json:"results"`
}

type VehicleData struct {
	LicenseNo    string    `json:"licenseNo"`
	CardNumber   string    `json:"cardNumber"`
	CarModel     string    `json:"carModel"`
	CheckInTime  time.Time `json:"checkInTime"`
	CheckOutTime time.Time `json:"checkOutTime"`
	DriverName   string    `json:"driverName"`
	DriverTelNo  string    `json:"driverTelNo"`
	DriverEmail  string    `json:"driverEmail"`
	SecurityNote string    `json:"securityNote"`
	ServiceId    int       `json:"serviceId"`
	ParkingId    int       `json:"parkingId"`
}

// Implement custom UnmarshalJSON method for time.Time
func (t *VehicleData) UnmarshalJSON(b []byte) error {
	type Alias VehicleData // Create an alias to avoid infinite recursion
	aux := &struct {
		CheckInTime  string `json:"checkInTime"`
		CheckOutTime string `json:"checkOutTime"`
		*Alias
	}{
		Alias: (*Alias)(t),
	}

	// Unmarshal into the temporary struct to avoid recursion
	if err := json.Unmarshal(b, &aux); err != nil {
		return err
	}

	// Parse time strings into time.Time fields
	var err error
	if aux.CheckInTime != "" {
		t.CheckInTime, err = time.Parse("2006-01-02T15:04:05.999", aux.CheckInTime)
		if err != nil {
			return err
		}
	}
	if aux.CheckOutTime != "" {
		t.CheckOutTime, err = time.Parse("2006-01-02T15:04:05.999", aux.CheckOutTime)
		if err != nil {
			return err
		}
	}

	return nil
}

type ParkingSessionData struct {
	StationId int    `json:"stationId"`
	ServiceId int    `json:"serviceId"`
	Report    string `json:"report"`
}

type ParkingStationData struct {
	Name     string `json:"name"`
	Codename string `json:"codename"`
}

type ServiceData struct {
	Name               string    `json:"name"`
	Date               time.Time `json:"date"`
	Time               time.Time `json:"time"`
	IsActive           bool      `json:"is_active"`
	AllocationAsBefore bool      `json:"allocation_as_before"`
}

type AllocationData struct {
	TeamMemberId int `json:"teamMemberId"`
	ParkingId    int `json:"parkingId"`
	ServiceId    int `json:"serviceId"`
}

type DepartmentData struct {
	Name       string `json:"name"`
	Codename   string `json:"codename"`
	AccessCode string `json:"accessCode"`
}

type UserData struct {
	Fullname        string `json:"fullname"`
	Codename        string `json:"codename"`
	Phone_number    string `json:"phone_number"`
	Email           string `json:"email"`
	Is_team_leader  bool   `json:"is_team_leader"`
	Is_admin        bool   `json:"is_admin"`
	Department_ID   int    `json:"department_id"`
	AccessCode      string `json:"accessCode,omitempty"`
	Password        string `json:"password,omitempty"`
	ConfirmPassword string `json:"confirm_password,omitempty"`
}

type UserClaims struct {
	ID       int32  `json:"id,omitempty"`
	Codename string `json:"codename,omitempty"`
	jwt.StandardClaims
}

type TokenResponse struct {
	AccessToken  string `json:"access_token,omitempty"`
	RefreshToken string `json:"refresh_token,omitempty"`
}
