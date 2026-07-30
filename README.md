# 🗺️ Flutter Map Route Planner Application

A feature-rich, high-performance Flutter map application built with **Clean Architecture** principles and **Cubit State Management**. This app enables real-time geolocation tracking, location search, custom markers, and route planning with distance and duration estimations—all powered by free, open-source services.

---

## 🛠️ Packages & Dependencies

Below is the complete list of packages used in this project, in order of installation:

| Package            |  Version  | Purpose                                                                                                                   |
| :----------------- | :-------: | :------------------------------------------------------------------------------------------------------------------------ |
| **`flutter_map`**  | `^7.0.2`  | Core interactive map engine for rendering OpenStreetMap layers, polyline routes, and markers.                             |
| **`latlong2`**     | `^0.9.1`  | Provides essential mathematical models and lightweight data structures for geographical coordinates (`LatLng`).           |
| **`geolocator`**   | `^13.0.1` | Handles device location permissions and fetches accurate GPS coordinates for the current user.                            |
| **`http`**         | `^1.2.2`  | Manages async HTTP requests to communicate with Geocoding and Routing REST APIs.                                          |
| **`flutter_bloc`** | `^8.1.3`  | Facilitates predictable State Management via Cubit to decouple business logic from UI and maximize rendering performance. |

### ⚡ One-Line Terminal Installation

To install all required packages at once via the terminal, run:

```bash
flutter pub add flutter_map latlong2 geolocator http flutter_bloc
```
