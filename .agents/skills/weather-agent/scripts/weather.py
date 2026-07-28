#!/usr/bin/env python3
"""
weather.py - Fetch and display weather forecast for a city using wttr.in
Usage: python3 weather.py <city name>
"""

import json
import sys
import urllib.request
import urllib.parse
import urllib.error
from datetime import datetime


WEATHER_CODES = {
    "113": "Sunny ☀️",
    "116": "Partly Cloudy 🌤️",
    "119": "Cloudy ☁️",
    "122": "Overcast ☁️",
    "143": "Mist 🌫️",
    "176": "Patchy Rain 🌦️",
    "179": "Patchy Snow 🌨️",
    "182": "Patchy Sleet 🌧️",
    "185": "Patchy Freezing Drizzle 🌧️",
    "200": "Thundery Outbreaks ⛈️",
    "227": "Blowing Snow 🌨️",
    "230": "Blizzard ❄️",
    "248": "Fog 🌫️",
    "260": "Freezing Fog 🌫️",
    "263": "Light Drizzle 🌧️",
    "266": "Drizzle 🌧️",
    "281": "Freezing Drizzle 🌧️",
    "284": "Heavy Freezing Drizzle 🌧️",
    "293": "Light Rain 🌧️",
    "296": "Rain 🌧️",
    "299": "Moderate Rain 🌧️",
    "302": "Heavy Rain 🌧️",
    "305": "Heavy Rain 🌧️",
    "308": "Very Heavy Rain 🌧️",
    "311": "Light Freezing Rain 🌧️",
    "314": "Moderate/Heavy Freezing Rain 🌧️",
    "317": "Light Sleet 🌨️",
    "320": "Moderate/Heavy Sleet 🌨️",
    "323": "Light Snow 🌨️",
    "326": "Moderate Snow 🌨️",
    "329": "Patchy Heavy Snow ❄️",
    "332": "Heavy Snow ❄️",
    "335": "Patchy Blizzard ❄️",
    "338": "Blizzard ❄️",
    "350": "Ice Pellets 🌨️",
    "353": "Light Shower 🌦️",
    "356": "Moderate/Heavy Shower 🌧️",
    "359": "Torrential Shower 🌧️",
    "362": "Light Sleet Shower 🌨️",
    "365": "Moderate/Heavy Sleet Shower 🌨️",
    "368": "Light Snow Shower 🌨️",
    "371": "Moderate/Heavy Snow Shower ❄️",
    "374": "Light Shower Ice Pellets 🌨️",
    "377": "Moderate/Heavy Shower Ice Pellets 🌨️",
    "386": "Patchy Light Rain + Thunder ⛈️",
    "389": "Moderate/Heavy Rain + Thunder ⛈️",
    "392": "Patchy Light Snow + Thunder ⛈️",
    "395": "Moderate/Heavy Snow + Thunder ⛈️",
}

UV_LABELS = {0: "Low", 1: "Low", 2: "Low", 3: "Moderate", 4: "Moderate",
             5: "Moderate", 6: "High", 7: "High", 8: "Very High",
             9: "Very High", 10: "Very High", 11: "Extreme"}

WIND_DIRECTIONS = {
    "N": "↑", "NNE": "↗", "NE": "↗", "ENE": "→",
    "E": "→", "ESE": "→", "SE": "↘", "SSE": "↓",
    "S": "↓", "SSW": "↙", "SW": "↙", "WSW": "←",
    "W": "←", "WNW": "←", "NW": "↖", "NNW": "↑",
}


def fetch_weather(city: str) -> dict:
    import ssl
    encoded = urllib.parse.quote(city, safe="")
    url = f"https://wttr.in/{encoded}?format=j1"
    req = urllib.request.Request(url, headers={"User-Agent": "weather-skill/1.0"})
    # Try verified first, fall back to unverified if local certs are unavailable
    contexts = [ssl.create_default_context(), ssl._create_unverified_context()]
    for ctx in contexts:
        try:
            with urllib.request.urlopen(req, timeout=10, context=ctx) as resp:
                raw = resp.read().decode("utf-8")
            break
        except urllib.error.URLError as e:
            if "CERTIFICATE" in str(e).upper() and ctx is not contexts[-1]:
                continue
            raise SystemExit(f"❌  Network error: {e.reason}") from e
    else:
        raise SystemExit("❌  SSL error: certificate verification failed")

    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        # wttr.in returns plain text for unknown cities
        raise SystemExit(f"❌  City not found: {raw.strip()}")


def fmt_condition(code: str, desc: str) -> str:
    return WEATHER_CODES.get(code, desc)


def fmt_wind(speed_kmph: str, direction: str) -> str:
    arrow = WIND_DIRECTIONS.get(direction, direction)
    return f"{arrow} {speed_kmph} km/h"


def fmt_uv(uv: str) -> str:
    idx = min(int(uv), 11)
    return f"{uv} ({UV_LABELS.get(idx, 'Extreme')})"


def fmt_date(date_str: str) -> str:
    try:
        return datetime.strptime(date_str, "%Y-%m-%d").strftime("%A, %d %b")
    except ValueError:
        return date_str


def print_divider(width: int = 52) -> None:
    print("─" * width)


def display(data: dict) -> None:
    # Location
    area = data["nearest_area"][0]
    city_name = area["areaName"][0]["value"]
    region = area.get("region", [{}])[0].get("value", "")
    country = area["country"][0]["value"]
    location = f"{city_name}, {region}, {country}" if region else f"{city_name}, {country}"

    print()
    print(f"  📍 {location}")
    print_divider()

    # Current conditions
    cur = data["current_condition"][0]
    code = cur["weatherCode"]
    condition = fmt_condition(code, cur["weatherDesc"][0]["value"])
    wind = fmt_wind(cur["windspeedKmph"], cur["winddir16Point"])

    print(f"  Now:        {condition}")
    print(f"  Temp:       {cur['temp_C']}°C  (feels like {cur['FeelsLikeC']}°C)")
    print(f"  Humidity:   {cur['humidity']}%")
    print(f"  Wind:       {wind}")
    print(f"  Visibility: {cur['visibility']} km")
    print(f"  UV index:   {fmt_uv(cur['uvIndex'])}")
    print_divider()

    # Daily forecast
    print(f"  {'Date':<22} {'High':>5} {'Low':>5}  {'Condition':<24} {'Rain'}")
    print_divider()
    for day in data["weather"]:
        label = fmt_date(day["date"])
        high = f"{day['maxtempC']}°C"
        low = f"{day['mintempC']}°C"
        # Use midday slot (index 4 of 8 hourly slots) for representative condition
        midday = day["hourly"][4]
        day_code = midday["weatherCode"]
        day_cond = fmt_condition(day_code, midday["weatherDesc"][0]["value"])
        total_rain = sum(float(h["precipMM"]) for h in day["hourly"])
        rain_str = f"{total_rain:.1f} mm" if total_rain > 0 else "None"
        print(f"  {label:<22} {high:>5} {low:>5}  {day_cond:<24} {rain_str}")

    print_divider()
    print()


def main() -> None:
    if len(sys.argv) < 2:
        print("Usage: python3 weather.py <city>")
        print("Example: python3 weather.py London")
        sys.exit(1)

    city = " ".join(sys.argv[1:])
    data = fetch_weather(city)
    display(data)


if __name__ == "__main__":
    main()
