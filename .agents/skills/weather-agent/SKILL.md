---
name: weather-agent
description: >
  Fetches and displays the current weather forecast for any city in the world.
  Use this skill when the user asks about the weather, temperature, forecast,
  rain, wind, or conditions in a specific city or location.
compatibility: Requires Python 3 (stdlib only) and outbound HTTPS access to wttr.in. Invoke with `python3` or `pixi run python` if python3 is not on PATH.
allowed-tools: bash
---

# Weather Agent

Fetch and display the current conditions and 3-day forecast for any city using the free [wttr.in](https://wttr.in) API. No API key required.

## Steps

1. Run the bundled Python script, passing the city name as an argument. Try each command in order until one succeeds:

   ```bash
   python3 .agents/skills/weather-agent/scripts/weather.py "<city name>"
   ```

   If `python3` is not found, try:

   ```bash
   pixi run python .agents/skills/weather-agent/scripts/weather.py "<city name>"
   ```

2. The script will print a formatted forecast. Return its output to the user.

3. If the city name contains special characters or is ambiguous, try the most common English spelling first (e.g. `Munich` instead of `München`).

## Fallback (no Python)

If Python 3 is unavailable, fall back to `curl`:

```bash
# One-line summary
curl -s "https://wttr.in/<city>?format=3"

# Full ASCII forecast (3 days)
curl -s "https://wttr.in/<city>"
```

Replace spaces with `+` in the city name (e.g. `New+York`).

## Error handling

- **City not found** — wttr.in returns a plain-text error instead of JSON. The script detects this and exits with a clear message. Ask the user to check the spelling.
- **Network unavailable** — The script reports the connection error. Inform the user and suggest trying again.

## Example

```
User: What's the weather in Amsterdam?
Agent: python3 .agents/skills/weather-agent/scripts/weather.py "Amsterdam"
       # or if python3 not found:
       pixi run python .agents/skills/weather-agent/scripts/weather.py "Amsterdam"
```

## Output fields

| Field | Description |
|-------|-------------|
| Location | Resolved city, region, country |
| Temp | Current temperature °C and feels-like °C |
| Humidity | Relative humidity % |
| Wind | Speed (km/h) with compass direction |
| Visibility | km |
| UV index | Numeric value with risk label |
| Forecast | High/low °C, condition, total daily rainfall for each of the next 3 days |
