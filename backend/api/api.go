package api

import (
	"fmt"
	"net/http"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func (a *AppServer) Run() *http.Server {

	r := chi.NewRouter()
	r.Use(middleware.Logger)

	// r.Use(cors.Handler(cors.Options{
	// 	// AllowedOrigins:   []string{"https://foo.com"}, // Use this to allow specific origin hosts
	// 	AllowedOrigins: []string{"https://*", "http://*"},
	// 	// AllowOriginFunc:  func(r *http.Request, origin string) bool { return true },
	// 	AllowedMethods:   []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
	// 	AllowedHeaders:   []string{"Accept", "Authorization", "Content-Type", "X-CSRF-Token"},
	// 	ExposedHeaders:   []string{"Link"},
	// 	AllowCredentials: false,
	// 	MaxAge:           300, // Maximum value not ignored by any of major browsers
	// }))

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
	r.Get("/vehicles", MakeApiHandler(a.ListVehiclesHandler))
	r.Post("/vehicles/register", MakeApiHandler(a.RegisterVehicleHandler))

	r.Get("/parkingsessions", MakeApiHandler(a.ListParkingSessionHandler))
	r.Post("/parkingsessions/register", MakeApiHandler(a.CreateParkingSessionHandler))
	r.Get("/parkingsessions/details/{id}", MakeApiHandler(a.GetParkingSessionHandler))
	r.Get("/parkingsessions/details", MakeApiHandler(a.GetVehicleParkingSessionHandler))

	r.Get("/parkingstations", MakeApiHandler(a.ListParkingStationHandler))
	r.Post("/parkingstations/register", MakeApiHandler(a.CreateParkingStationHandler))
	r.Get("/parkingstations/details/{id}", MakeApiHandler(a.GetParkingStationHandler))
	r.Get("/parkingstations/details/{id}/vehicles", MakeApiHandler(a.GetParkingStationVehiclesHandler))

	r.Get("/services", MakeApiHandler(a.ListServicerHandler))
	r.Post("/services/register", MakeApiHandler(a.CreateServicerHandler))
	r.Get("/services/details/{id}", MakeApiHandler(a.GetServicerHandler))
	r.Get("/service/details/{id}/vehicles", MakeApiHandler(a.GetServiceVehicleHandler))
}
