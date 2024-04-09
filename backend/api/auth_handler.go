package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"net/http"
	"os"
	"strconv"
	"strings"
	"time"

	"github.com/go-chi/chi/v5"
	"github.com/golang-jwt/jwt"
	"github.com/phillipmugisa/PhanerooParkingApp/database"
	"golang.org/x/crypto/bcrypt"
)

func (a *AppServer) ListUserHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	results, err := a.db.ListTeamMember(ctx)
	if err != nil {
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, HandlerResponse{
		Count:   len(results),
		Results: results,
	})
}

func (a *AppServer) GetAuthedUserHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {

	auth_header := r.Header.Get("Authorization")

	// verify if right format
	parts := strings.Split(auth_header, " ")

	claims, parse_err := ParseToken(parts[1])
	if parse_err != nil {
		return NewApiError("access denied", http.StatusForbidden)
	}
	if claims.Valid() != nil {
		// refresh token expired
		return NewApiError("access denied", http.StatusForbidden)
	}

	department, f_err := a.db.GetTeamMemberByID(ctx, claims.ID)
	if f_err != nil {
		if errors.Is(f_err, sql.ErrNoRows) {
			return RespondWithJSON(w, http.StatusNotFound, struct{}{})
		}
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, department)
}

func (a *AppServer) GetUserHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	id, err := strconv.Atoi(chi.URLParam(r, "id"))
	if err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	department, f_err := a.db.GetTeamMemberByID(ctx, int32(id))
	if f_err != nil {
		if errors.Is(f_err, sql.ErrNoRows) {
			return RespondWithJSON(w, http.StatusNotFound, struct{}{})
		}
		return NewApiError("Operation was unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusOK, department)
}

func (a *AppServer) RegisterUserHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var userData UserData

	err := json.NewDecoder(r.Body).Decode(&userData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	// check if passwords match
	if userData.Password != userData.ConfirmPassword {
		return NewApiError("Password mismatch", http.StatusConflict)
	}

	// check if code Name exists
	team_member, f_err := a.db.GetTeamMemberByCodeName(ctx, userData.Codename)
	if f_err != nil {
		if !errors.Is(f_err, sql.ErrNoRows) {
			return NewApiError("operation unsuccessful", http.StatusInternalServerError)
		}
	}
	if team_member.Codename != "" {
		return NewApiError("Code name not available", http.StatusConflict)
	}

	// get department by code name
	department, fetch_err := a.db.GetDepartmentByCode(ctx, userData.AccessCode)
	if fetch_err != nil {
		if errors.Is(f_err, sql.ErrNoRows) {
			return NewApiError("Invalid access code provided", http.StatusConflict)
		}
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	// hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(userData.Password), bcrypt.DefaultCost)
	if err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	_, write_err := a.db.CreateTeamMember(ctx, database.CreateTeamMemberParams{
		Fullname:     userData.Fullname,
		Codename:     userData.Codename,
		PhoneNumber:  userData.Phone_number,
		Email:        sql.NullString{String: userData.Email, Valid: true},
		Password:     sql.NullString{String: string(hashedPassword), Valid: true},
		IsTeamLeader: sql.NullBool{Bool: false, Valid: true},
		IsAdmin:      sql.NullBool{Bool: false, Valid: true},
		DepartmentID: department.ID,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	})
	if write_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, struct{}{})
}

func (a *AppServer) LoginHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {

	var userData UserData

	err := json.NewDecoder(r.Body).Decode(&userData)
	if err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	if userData.Codename == "" && userData.Password == "" {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	// get user with this code name
	user, f_err := a.db.GetTeamMemberByCodeName(ctx, userData.Codename)
	if f_err != nil {
		return NewApiError("Invalid codename or password provided", http.StatusBadRequest)
	}

	pwd, pwd_fetch_err := a.db.GetTeamMemberHashedPwd(ctx, user.Codename)
	if pwd_fetch_err != nil {
		return NewApiError("Invalid codename or password provided", http.StatusBadRequest)
	}

	// compare passwords
	match_err := bcrypt.CompareHashAndPassword([]byte(pwd.String), []byte(userData.Password))
	if match_err != nil {
		return NewApiError("Invalid codename or password provided", http.StatusBadRequest)
	}

	return a.GenerateJWT(ctx, w, database.TeamMember{
		ID:       user.ID,
		Codename: user.Codename,
	})
}

func GenerateAccessToken(ctx context.Context, user database.TeamMember) (string, error) {

	// generate access token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, UserClaims{
		ID:       user.ID,
		Codename: user.Codename,
		StandardClaims: jwt.StandardClaims{
			IssuedAt:  time.Now().Unix(),
			ExpiresAt: time.Now().Add(time.Minute * 30).Unix(), // 30 minutes expiration
		},
	})
	return token.SignedString([]byte(os.Getenv("JWT_TOKEN_SECRET")))
}

func GenerateRefreshToken(ctx context.Context) (string, error) {

	// generate access token
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, UserClaims{
		StandardClaims: jwt.StandardClaims{
			IssuedAt:  time.Now().Unix(),
			ExpiresAt: time.Now().Add(time.Hour * 48).Unix(), // 2 days expiration
		},
	})
	return token.SignedString([]byte(os.Getenv("JWT_TOKEN_SECRET")))
}

func ParseToken(token string) (*UserClaims, error) {
	parsedAccessToken, err := jwt.ParseWithClaims(token, &UserClaims{}, func(token *jwt.Token) (interface{}, error) {
		return []byte(os.Getenv("JWT_TOKEN_SECRET")), nil
	})
	if err != nil {
		return nil, err
	}
	return parsedAccessToken.Claims.(*UserClaims), nil
}

func (a *AppServer) GenerateJWT(ctx context.Context, w http.ResponseWriter, user database.TeamMember) *ApiError {

	access_token, access_err := GenerateAccessToken(ctx, user)
	if access_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	refresh_token, refresh_err := GenerateRefreshToken(ctx)
	if refresh_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	// cancel exiting token
	cancel_err := a.db.CancelToken(ctx, user.ID)
	if cancel_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	// save token
	write_err := a.db.CreateToken(ctx, database.CreateTokenParams{
		AccessToken:  access_token,
		RefreshToken: sql.NullString{String: refresh_token, Valid: true},
		TeamMemberID: user.ID,
		CreatedAt:    time.Now(),
		UpdatedAt:    time.Now(),
	})
	if write_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, TokenResponse{
		AccessToken:  access_token,
		RefreshToken: refresh_token,
	})
}

func (a *AppServer) LogoutHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	auth_header := r.Header.Get("Authorization")

	// verify if right format
	parts := strings.Split(auth_header, " ")
	if len(parts) < 2 {
		return NewApiError("access denied", http.StatusForbidden)
	}
	if strings.ToLower(parts[0]) != "jwt" {
		return NewApiError("access denied", http.StatusForbidden)
	}

	claims, parse_err := ParseToken(parts[1])
	if parse_err != nil {
		return NewApiError("access denied", http.StatusForbidden)
	}
	if claims.Valid() != nil {
		// refresh token expired
		return NewApiError("access denied", http.StatusForbidden)
	}

	// cancel exiting token
	cancel_err := a.db.CancelToken(ctx, claims.ID)
	if cancel_err != nil {
		return NewApiError("operation unsuccessful", http.StatusInternalServerError)
	}

	return RespondWithJSON(w, http.StatusCreated, nil)
}

func (a *AppServer) RefreshTokenHandler(ctx context.Context, w http.ResponseWriter, r *http.Request) *ApiError {
	var accessData TokenResponse

	// expects refresh tokens
	if err := json.NewDecoder(r.Body).Decode(&accessData); err != nil {
		return NewApiError("Failed to decode request body", http.StatusBadRequest)
	}
	defer r.Body.Close()

	claims, parse_err := ParseToken(accessData.RefreshToken)
	if parse_err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	if claims.Valid() != nil {
		// refresh token expired
		return a.LoginHandler(ctx, w, r)
	}

	token_record, f_err := a.db.GetUserTokenByRefreshToken(ctx, sql.NullString{String: accessData.RefreshToken, Valid: true})
	if f_err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}

	user, f_err := a.db.GetTeamMemberByID(ctx, token_record.TeamMemberID)
	if f_err != nil {
		return NewApiError("Invalid data provided", http.StatusBadRequest)
	}
	return a.GenerateJWT(ctx, w, database.TeamMember{
		ID:       user.ID,
		Codename: user.Codename,
	})
}

func (a *AppServer) ValidateRequest(ctx context.Context, r *http.Request) *ApiError {
	auth_header := r.Header.Get("Authorization")

	// verify if right format
	parts := strings.Split(auth_header, " ")
	if len(parts) < 2 {
		return NewApiError("access denied", http.StatusForbidden)
	}
	if strings.ToLower(parts[0]) != "jwt" {
		return NewApiError("access denied", http.StatusForbidden)
	}

	claims, parse_err := ParseToken(parts[1])
	if parse_err != nil {
		return NewApiError("access denied", http.StatusForbidden)
	}
	if claims.Valid() != nil {
		// refresh token expired
		return NewApiError("access denied", http.StatusForbidden)
	}

	// check is user exists
	_, err := a.db.GetTeamMemberByCodeName(ctx, claims.Codename)
	if err != nil {
		return NewApiError("access denied", http.StatusForbidden)
	}

	return nil
}
