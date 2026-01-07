# tripsense-ai-service

Express service that handles POST requests from a Spring Boot client to generate travel recommendations.

## Run locally

```bash
npm install
npm start
```

Server starts on `http://localhost:3000` by default.

### Configure with .env

Create a `.env` file in the project root:

```
OPENAI_API_KEY=sk-...
OPENAI_MODEL=gpt-4o-mini
PORT=3000
```

Restart the server after changes to `.env`.

## Endpoint

- Method: `POST`
- Path: `/api/recomendations` (misspelling intentional to match client)
- Content-Type: `application/json`

## Usage

POST to `/api/recomendations` (intentional misspelling to match the client) with either:

- Direct fields

  - `categories: string[]`
  - `locations: string[]`
  - `startDate?: string`
  - `endDate?: string`
  - `maxDistanceKm?: number`
  - `maxBudget?: number`

- Or a `preferences` array (the service will use the first item):

```json
{
  "preferences": [
    {
      "categories": ["nature", "beach"],
      "locations": ["Galle", "Mirissa"],
      "startDate": "2026-01-10",
      "endDate": "2026-01-12",
      "maxDistanceKm": 120,
      "maxBudget": 80
    }
  ]
}
```

### Response

```json
{
  "recommendations": [
    {
      "title": "Beach day",
      "location": "Galle",
      "category": "beach",
      "estimatedCost": 45,
      "estimatedDistanceKm": 30,
      "durationHours": 4,
      "score": 0.87
    }
  ],
  "summary": {
    "count": 6,
    "startDate": "2026-01-10",
    "endDate": "2026-01-12"
  }
}
```

## OpenAI Integration

- If `OPENAI_API_KEY` is set, the service uses OpenAI (model defaults to `gpt-4o-mini`; override via `OPENAI_MODEL`).
- If not set, a lightweight local fallback generates realistic, deterministic recommendations for development/testing.

## Distance API

- Method: `POST`
- Path: `/api/distance-km`
- Body:

```json
{
  "from": { "lat": 6.9271, "lng": 79.8612 },
  "to": { "lat": 6.0535, "lng": 80.221 }
}
```

- Response:

```json
{ "km": 116.4 }
```

### Home-based distances in recommendations

- You can provide `home` coordinates to compute `estimatedDistanceKm` when `locations` include coordinates.
- `locations` can be strings (e.g., "Kandy") or objects with `name`, `lat`, `lng`:

```json
{
  "preferences": [
    {
      "home": { "lat": 6.9271, "lng": 79.8612 },
      "locations": [
        { "name": "Galle", "lat": 6.0535, "lng": 80.221 },
        { "name": "Mirissa", "lat": 5.9485, "lng": 80.454 }
      ],
      "categories": ["beach", "food"],
      "maxDistanceKm": 150,
      "maxBudget": 100
    }
  ]
}
```

### Request body

```json
{
  "categories": ["adventure", "food"],
  "locations": ["Colombo", "Kandy"],
  "startDate": "2026-01-10",
  "endDate": "2026-01-12",
  "maxDistanceKm": 120,
  "maxBudget": 150
}
```

### Response body (example)

```json
{
  "recommendations": [
    {
      "title": "Mountain Hike in Kandy",
      "location": "Kandy",
      "category": "adventure",
      "estimatedCost": 22,
      "estimatedDistanceKm": 73,
      "durationHours": 5,
      "score": 0.76
    }
  ],
  "summary": { "count": 10, "startDate": "2026-01-10", "endDate": "2026-01-12" }
}
```

## Notes

- The service uses OpenAI when `OPENAI_API_KEY` is set; otherwise it generates local recommendations with realistic defaults.
- Ensure your Spring Boot service posts to `http://localhost:3000/api/recomendations`.
