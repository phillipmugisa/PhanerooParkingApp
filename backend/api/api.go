package api

import (
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	"github.com/go-chi/cors"
)

func (a *AppServer) Run() *http.Server {

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	r.Use(cors.Handler(cors.Options{
		// AllowedOrigins:   []string{"https://foo.com"}, // Use this to allow specific origin hosts
		AllowedOrigins: []string{"https://*", "http://*"},
		// AllowOriginFunc:  func(r *http.Request, origin string) bool { return true },
		AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
		ExposedHeaders:   []string{"Link"},
		AllowCredentials: false,
		MaxAge:           300, // Maximum value not ignored by any of major browsers
	}))

	a.registerRoutes(r)

	return &http.Server{
		Addr:           fmt.Sprintf(":%s", a.port),
		Handler:        r,
		ReadTimeout:    10 & time.Second,
		WriteTimeout:   10 & time.Second,
		MaxHeaderBytes: 1 << 20,
	}
}

func (a *AppServer) registerRoutes(r *chi.Mux) {
	r.Get("/vehicles", a.AuthedHandler(a.ListVehiclesHandler))
	r.Get("/vehicles/{id}", a.AuthedHandler(a.GetVehiclesHandler))
	r.Patch("/vehicles/{id}/update", a.AuthedHandler(a.UpdateVehiclesHandler))
	r.Patch("/vehicles/{id}/checkout", a.AuthedHandler(a.CheckoutVehiclesHandler))
	r.Post("/vehicles/register", a.AuthedHandler(a.RegisterVehicleHandler))
	r.Get("/vehicles/search", a.AuthedHandler(a.SearchVehicleHandler))
	// r.Get("/parkingsessions/details", a.AuthedHandler(a.GetVehicleParkingSessionHandler))

	r.Get("/drivers", a.AuthedHandler(a.ListDriversHandler))
	r.Get("/drivers/{id}", a.AuthedHandler(a.GetDriversHandler))

	// security
	r.Get("/parkingsessions", a.AuthedHandler(a.ListParkingSessionHandler))
	r.Post("/parkingsessions/register", a.AuthedHandler(a.CreateParkingSessionHandler))
	r.Get("/parkingsessions/details/{id}", a.AuthedHandler(a.GetParkingSessionHandler))

	r.Get("/parkingstations", a.AuthedHandler(a.ListParkingStationHandler))
	r.Post("/parkingstations/register", a.AuthedHandler(a.CreateParkingStationHandler))
	r.Get("/parkingstations/details/{id}", a.AuthedHandler(a.GetParkingStationHandler))
	r.Get("/parkingstations/{id}/vehicles", a.AuthedHandler(a.GetParkingStationVehiclesHandler))

	r.Get("/parkingstations/groups", a.AuthedHandler(a.ListParkingSectionGroupsHandler))
	r.Get("/parkingstations/groups/service/{id}", a.AuthedHandler(a.ListParkingSectionAndServiceGroupsHandler))

	r.Get("/services", a.AuthedHandler(a.ListServicerHandler))
	r.Get("/services/current", a.AuthedHandler(a.GetCurrentServicerHandler))
	r.Post("/services/register", a.AuthedHandler(a.CreateServicerHandler))
	r.Get("/services/details/{id}", a.AuthedHandler(a.GetServicerHandler))
	r.Get("/service/{id}/vehicles", a.AuthedHandler(a.GetServiceVehicleHandler))

	r.Get("/departments", a.AuthedHandler(a.ListDepartmentsHandler))
	r.Get("/departments/{id}", a.AuthedHandler(a.GetDepartmentHandler))
	r.Get("/departments/{id}/team", a.AuthedHandler(a.ListDepartmentTeamHandler))
	r.Post("/departments/create", MakeApiHandler(a.CreateDepartmentHandler))
	// r.Post("/departments/create", a.AuthedHandler(a.CreateDepartmentHandler))

	// auth
	r.Get("/users", a.AuthedHandler(a.ListUserHandler))
	r.Get("/users/{id}", a.AuthedHandler(a.GetUserHandler))
	r.Get("/users/current", a.AuthedHandler(a.GetAuthedUserHandler))
	r.Post("/register", MakeApiHandler(a.RegisterUserHandler))
	r.Post("/login", MakeApiHandler(a.LoginHandler))
	r.Get("/logout", MakeApiHandler(a.LogoutHandler))
	r.Post("/refresh/token", MakeApiHandler(a.RefreshTokenHandler))

}
