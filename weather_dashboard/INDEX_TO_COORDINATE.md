# Index → Coordinates (latitude, longitude)

This document explains how the app converts a student index number to geographic coordinates (latitude and longitude).

## Index format

- The index must match the regular expression: `^\d{6}[A-Za-z]$` — six digits followed by a single ASCII letter (e.g., `224112A`).

## Formula used by the app (exact implementation)

Extract the digits:

- `firstTwo = int.parse(index.substring(0, 2))` — digits 1–2
- `nextTwo = int.parse(index.substring(2, 4))` — digits 3–4

Compute coordinates:

- `latitude = 5 + (firstTwo / 10.0)`
- `longitude = 79 + (nextTwo / 10.0)`

These are then formatted to two decimal places before being used in the API request.

## Example

For index `224112A`:

- `firstTwo = 22` → latitude = `5 + 22/10.0` = `7.2` → `7.20`
- `nextTwo = 41` → longitude = `79 + 41/10.0` = `83.1` → `83.10`

So the app requests weather data for latitude=7.20 and longitude=83.10.

## Notes / suggestions

- Only the first four digits are used to compute coordinates — digits 5–6 and the final letter are ignored.
- If you want this logic separated or tested, extract it into a small helper function (e.g. `indexToLatLon(String index)`) and add unit tests to ensure correctness and better reusability.

File reference: implemented in `lib/screens/weather_page.dart` (method `_onFetchWeatherPressed`).

