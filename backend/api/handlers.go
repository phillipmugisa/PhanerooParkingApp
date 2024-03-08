package api

import (
	"context"
	"net/http"
)

func ListVehiclesHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	// type response struct {

	// }
	return RespondWithJSON(w, http.StatusOK, struct {
		Name string `json:"name"`
	}{Name: "phillip mugisa"})
}
