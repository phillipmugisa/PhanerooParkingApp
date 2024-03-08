package api

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func MakeApiHandler(h ApiHandler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {

		ctx := context.Background()
		err := h(ctx, w, r)
		if err != nil {
			HandleApiError(w, err)
		}
	}
}

func RespondWithJSON(w http.ResponseWriter, code int, payload interface{}) *ApiError {
	data, err := json.Marshal(payload)
	if err != nil {
		return &ApiError{
			Message: fmt.Sprintf("failed to marshal json response: %v\n", payload),
			Status:  http.StatusInternalServerError,
		}
	}
	w.Header().Add("Content-Type", "application/json")
	w.WriteHeader(200)
	w.Write(data)
	return nil
}

func HandleApiError(w http.ResponseWriter, err *ApiError) {
	if err.Status > 499 {
		log.Println("Responding with error: ", err.Message)
	}

	type errResponse struct {
		Error string `json:"error"`
	}

	RespondWithJSON(w, err.Status, errResponse{
		Error: err.Message,
	})
}
