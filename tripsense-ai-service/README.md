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

- The service uses OpenAI to generate recommendations when `OPENAI_API_KEY` is set; otherwise it returns an empty list.
- Ensure your Spring Boot service posts to `http://localhost:3000/api/recomendations`.
