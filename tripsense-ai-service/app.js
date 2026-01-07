try {
  require("dotenv").config();
} catch (_) {
  // dotenv not installed or not needed; continue without loading .env
}
const express = require("express");
const cors = require("cors");
const http = require("http");
const https = require("https");
const { URL } = require("url");
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

function requestJson(u) {
  return new Promise((resolve, reject) => {
    let urlObj;
    try {
      urlObj = new URL(u);
    } catch (e) {
      return reject(new Error("invalid_url"));
    }
    const mod = urlObj.protocol === "https:" ? https : http;
    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (urlObj.protocol === "https:" ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: "GET",
      headers: { Accept: "application/json" },
    };
    const req = mod.request(options, (resp) => {
      let data = "";
      resp.on("data", (chunk) => (data += chunk));
      resp.on("end", () => {
        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          try {
            resolve(JSON.parse(data || "{}"));
          } catch (_) {
            reject(new Error("invalid_json"));
          }
        } else {
          reject(new Error(`upstream_status_${resp.statusCode}`));
        }
      });
    });
    req.on("error", (err) => reject(err));
    req.end();
  });
}

// Proxy user details by email to upstream user service (default localhost:8080)
app.get("/api/users/:email", async (req, res) => {
  try {
    const email = req.params.email;
    if (!email || typeof email !== "string" || !email.includes("@")) {
      return res.status(400).json({ error: "invalid_email" });
    }
    const base = (
      process.env.USER_SERVICE_BASE || "http://localhost:8080"
    ).replace(/\/$/, "");
    const upstreamUrl = `${base}/api/v1/users/${encodeURIComponent(email)}`;
    const data = await requestJson(upstreamUrl);
    return res.json({ user: data });
  } catch (err) {
    console.error("/api/users proxy error", err?.message || err);
    return res.status(502).json({ error: "upstream_error" });
  }
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
      home,
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
        home,
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
      home,
    });
    finish(localRecs);
  } catch (err) {
    console.error("/api/recomendations error", err);
    res.status(500).json({ error: "internal_error" });
  }
});

app.post("/api/distance-km", (req, res) => {
  try {
    const { from, to } = req.body || {};
    const validNum = (v) => typeof v === "number" && Number.isFinite(v);
    const hasCoords = (p) => p && validNum(p.lat) && validNum(p.lng);
    if (!hasCoords(from) || !hasCoords(to)) {
      return res
        .status(400)
        .json({ error: "from and to must have lat,lng numbers" });
    }
    const km = haversineKm(from.lat, from.lng, to.lat, to.lng);
    res.json({ km });
  } catch (err) {
    console.error("/api/distance-km error", err);
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
      home: p.home,
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

function haversineKm(lat1, lon1, lat2, lon2) {
  const toRad = (d) => (d * Math.PI) / 180;
  const R = 6371;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) *
      Math.cos(toRad(lat2)) *
      Math.sin(dLon / 2) *
      Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return Math.round(R * c * 10) / 10;
}

function generateLocalRecommendations(params) {
  const {
    categories = [],
    locations = [],
    maxDistanceKm,
    maxBudget,
    home,
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

      const name = typeof loc === "string" ? loc : loc?.name || "Unknown";
      let distance = Math.round((10 + rand() * 140) * 10) / 10;
      const validNum = (v) => typeof v === "number" && Number.isFinite(v);
      if (
        home &&
        validNum(home?.lat) &&
        validNum(home?.lng) &&
        typeof loc === "object" &&
        validNum(loc?.lat) &&
        validNum(loc?.lng)
      ) {
        distance = haversineKm(home.lat, home.lng, loc.lat, loc.lng);
      }
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
        location: name,
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
