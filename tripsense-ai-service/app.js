try {
  require("dotenv").config();
} catch (_) {
  // dotenv not installed or not needed; continue without loading .env
}
const express = require("express");
const cors = require("cors");
let OpenAI;
try {
  OpenAI = require("openai");
} catch (_) {
  OpenAI = null;
}

const app = express();

app.use(cors());
app.use(express.json());

const port = process.env.PORT || 3000;

app.get("/", (req, res) => {
  res.json({ status: "ok", service: "tripsense-ai-service" });
});

// NOTE: the path intentionally matches the Spring client's constant (misspelling preserved)
app.post("/api/recomendations", (req, res) => {
  try {
    const {
      categories,
      locations,
      startDate,
      endDate,
      maxDistanceKm,
      maxBudget,
    } = normalizeInput(req.body || {});

    if (!Array.isArray(categories) || categories.length === 0) {
      return res
        .status(400)
        .json({ error: "categories must be a non-empty array" });
    }
    if (!Array.isArray(locations) || locations.length === 0) {
      return res
        .status(400)
        .json({ error: "locations must be a non-empty array" });
    }

    const doOpenAI = Boolean(process.env.OPENAI_API_KEY) && OpenAI;

    const finish = (recommendations) =>
      res.json({
        recommendations,
        summary: {
          count: recommendations.length,
          startDate: startDate || null,
          endDate: endDate || null,
        },
      });

    if (doOpenAI) {
      generateWithOpenAI({
        categories,
        locations,
        startDate,
        endDate,
        maxDistanceKm,
        maxBudget,
      })
        .then((recs) => {
          if (Array.isArray(recs) && recs.length) return finish(recs);
          finish([]);
        })
        .catch((e) => {
          console.warn("OpenAI fallback due to error:", e?.message || e);
          finish([]);
        });
      return;
    }

    // OpenAI not configured: generate lightweight local recommendations
    const localRecs = generateLocalRecommendations({
      categories,
      locations,
      startDate,
      endDate,
      maxDistanceKm,
      maxBudget,
    });
    finish(localRecs);
  } catch (err) {
    console.error("/api/recomendations error", err);
    res.status(500).json({ error: "internal_error" });
  }
});

function normalizeInput(body) {
  if (Array.isArray(body.preferences) && body.preferences.length > 0) {
    const p = body.preferences[0];
    return {
      categories: p.categories,
      locations: p.locations,
      startDate: p.startDate,
      endDate: p.endDate,
      maxDistanceKm: p.maxDistanceKm,
      maxBudget: p.maxBudget,
    };
  }
  return body;
}

async function generateWithOpenAI(params) {
  const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });
  const model = process.env.OPENAI_MODEL || "gpt-4o-mini";

  const sys = `You are a travel recommendation engine. Given categories, locations, dates, max distance and budget, produce a ranked list of trip activities as structured JSON with an array 'recommendations' of objects {title, location, category, estimatedCost, estimatedDistanceKm, durationHours, score}. Keep costs and distances realistic for Sri Lanka if locations are Sri Lankan.`;

  const resp = await client.chat.completions.create({
    model,
    messages: [
      { role: "system", content: sys },
      { role: "user", content: JSON.stringify(params) },
    ],
    response_format: { type: "json_object" },
    temperature: 0.3,
  });

  const raw = resp?.choices?.[0]?.message?.content || "{}";
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (_) {
    return [];
  }
  const list = Array.isArray(parsed.recommendations)
    ? parsed.recommendations
    : [];
  return list.slice(0, 15);
}

function generateLocalRecommendations(params) {
  const {
    categories = [],
    locations = [],
    maxDistanceKm,
    maxBudget,
  } = params || {};

  const catLabels = {
    culture: ["Temple visit", "Museum tour", "Heritage walk"],
    nature: ["Scenic hike", "Waterfall stop", "Lakeside picnic"],
    beach: ["Beach day", "Sunset watching", "Surf lesson"],
    food: ["Street food crawl", "Tea tasting", "Seafood lunch"],
    adventure: ["White-water rafting", "Zipline park", "Cycling loop"],
  };

  const defaults = [
    "Explore local market",
    "Try regional cuisine",
    "City highlights",
  ];

  const items = [];
  const safeCategories =
    Array.isArray(categories) && categories.length
      ? categories
      : ["culture", "nature", "food"];
  const safeLocations =
    Array.isArray(locations) && locations.length ? locations : ["Colombo"];

  let seed = (safeCategories.join("|") + safeLocations.join("|")).length;
  const rand = () => {
    seed = (seed * 9301 + 49297) % 233280;
    return seed / 233280;
  };

  const pick = (arr) => arr[Math.floor(rand() * arr.length) % arr.length];

  for (const loc of safeLocations.slice(0, 3)) {
    for (const cat of safeCategories.slice(0, 4)) {
      const baseTitles = catLabels[cat?.toLowerCase?.()] || defaults;
      const title = pick(baseTitles);

      let distance = Math.round((10 + rand() * 140) * 10) / 10; // 10–150 km
      if (typeof maxDistanceKm === "number") {
        distance = Math.min(distance, Math.max(5, maxDistanceKm));
      }

      let cost = Math.round((15 + rand() * 85) * 10) / 10; // 15–100 USD per activity
      if (typeof maxBudget === "number") {
        cost = Math.min(cost, Math.max(5, maxBudget));
      }

      const duration = Math.max(1, Math.round(1 + rand() * 6)); // 1–7 hours
      const score = Math.round((0.6 + rand() * 0.4) * 100) / 100; // 0.6–1.0

      items.push({
        title,
        location: loc,
        category: cat,
        estimatedCost: cost,
        estimatedDistanceKm: distance,
        durationHours: duration,
        score,
      });
    }
  }

  // Deduplicate by title+location+category
  const seen = new Set();
  const unique = [];
  for (const it of items) {
    const key = `${it.title}|${it.location}|${it.category}`;
    if (!seen.has(key)) {
      seen.add(key);
      unique.push(it);
    }
  }

  // Rank by score descending and keep top 12
  return unique.sort((a, b) => b.score - a.score).slice(0, 12);
}

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
