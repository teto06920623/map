# 🗺️ Flutter Map Route Planner Application

<div align="center">

### 🎬 Application Demo

<table border="0">
  <tr>
    <td align="center" style="background-color: #0d1117; padding: 15px; border-radius: 12px; border: 1px solid #30363d;">
      <video src="https://github.com/user-attachments/assets/63d693e0-a202-49bd-9863-1bc60af6d2c5" width="100%" controls style="max-width: 400px; border-radius: 8px;">
        Your browser does not support the video tag.
      </video>
    </td>
  </tr>
</table>

*A complete walkthrough demonstrating location tracking, geocoding search, OSRM route rendering, and tile layer toggling.*

</div>

---

A feature-rich, high-performance Flutter map application built with **Clean Architecture** principles and **Cubit State Management**. This app enables real-time geolocation tracking, location search, custom markers, and route planning with distance and duration estimations—all powered by free, open-source services.

---

## 🛠️ Packages & Dependencies

Below is the complete list of packages used in this project, in order of installation:

| Package | Version | Purpose |
| :--- | :---: | :--- |
| **`flutter_map`** | `^7.0.2` | Core interactive map engine for rendering OpenStreetMap layers, polyline routes, and markers. |
| **`latlong2`** | `^0.9.1` | Provides essential mathematical models and lightweight data structures for geographical coordinates (`LatLng`). |
| **`geolocator`** | `^13.0.1` | Handles device location permissions and fetches accurate GPS coordinates for the current user. |
| **`http`** | `^1.2.2` | Manages async HTTP requests to communicate with Geocoding and Routing REST APIs. |
| **`flutter_bloc`** | `^8.1.3` | Facilitates predictable State Management via Cubit to decouple business logic from UI and maximize rendering performance. |

### ⚡ One-Line Terminal Installation

To install all required packages at once via the terminal, run:

```bash
flutter pub add flutter_map latlong2 geolocator http flutter_bloc
```

---

## 🌐 External APIs & Web Services

The application leverages open-source RESTful services and tile providers to avoid expensive API keys while delivering fast and reliable map features:

### 1. **CartoDB Tile Server** (Base Map Layer)
* **URL:** `[https://a.basemaps.cartocdn.com/light_all/](https://a.basemaps.cartocdn.com/light_all/){z}/{x}/{y}.png`
* **Purpose:** Provides smooth, modern, high-speed map vector tiles for standard rendering without server throttling.

### 2. **Esri World Imagery** (Satellite Layer)
* **URL:** `[https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/](https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/){z}/{y}/{x}`
* **Purpose:** High-resolution satellite tile layer for real-world environmental views.

### 3. **Nominatim API by OpenStreetMap** (Geocoding)
* **Endpoint:** `[https://nominatim.openstreetmap.org/search](https://nominatim.openstreetmap.org/search)`
* **Purpose:** Converts user-entered place names or query strings into geographical coordinates (`Latitude` & `Longitude`).

### 4. **OSRM (Open Source Routing Machine) API** (Route Calculation)
* **Endpoint:** `[http://router.project-osrm.org/route/v1/driving/](http://router.project-osrm.org/route/v1/driving/)`
* **Purpose:** Calculates real-time driving navigation routes, polyline point arrays, distance in kilometers, and estimated travel duration in minutes.

---

## 📐 Architecture & Key Features

* **State Management:** **Cubit (flutter_bloc)** for isolated business logic and minimum rebuilds.
* **Granular Rebuilds:** UI layers use selective `buildWhen` logic to prevent re-rendering map tiles during UI state changes.
* **Error Handling:** Robust handling for location permissions, disabled GPS services, network failures, and empty search results.
* **Multi-Layer Support:** Seamlessly switch between Standard Light, Dark, and Satellite tile styles in real-time.
