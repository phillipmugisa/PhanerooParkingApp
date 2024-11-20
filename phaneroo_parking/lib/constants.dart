const String backendUrl = "http://34.173.233.148";
// const String backendUrl = "http://localhost:8000";
// const String backendUrl = "http://parkingpro.mugisa.tech";

// vehicles
const String listVehiclesRoute = "$backendUrl/vehicles";
const String registerVehicleRoute = "$backendUrl/vehicles/register";
const String getVehicleRoute = "$backendUrl/vehicles/";

const String getServiceVehiclesRoute = "$backendUrl/vehicles";
const String getParkingVehiclesRoute = "$backendUrl/vehicles";

// security
const String listParkingStationsRoute = "$backendUrl/parkingstations";
const String getParkingStationsRoute = "$backendUrl/parkingstations/details";
const String createParkingStationsRoute =
    "$backendUrl/parkingstations/register";

const String createServiceParkingStationsRoute =
    "$backendUrl/parkingsessions/register";

const String registerServiceRoute = "$backendUrl/services/register";
const String currentService = "$backendUrl/services/current";
const String parkingGroups = "$backendUrl/parkingstations/groups";
const String parkingServiceGroups =
    "$backendUrl/parkingstations/groups/service";

const String searchRoute = "$backendUrl/vehicles/search?q=";

// auth
const String registerUserRoute = "$backendUrl/register";
const String loginRoute = "$backendUrl/login";
const String logoutRoute = "$backendUrl/logout";
const String currentUserRoute = "$backendUrl/users/current";
const String refreshTokenRoute = "$backendUrl/refresh/token";

// allocations
const String createAllocationRoute = "$backendUrl/allocations/register";
