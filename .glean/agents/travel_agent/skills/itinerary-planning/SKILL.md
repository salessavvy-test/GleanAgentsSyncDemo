# Itinerary Planning

## Purpose
Translate a ranked theme list into a structured 5-day day-by-day travel itinerary that is geographically efficient, time-realistic, and formatted to the required output schema.

## Output Schema
Every row in the final itinerary table MUST contain exactly these columns:

| Column | Type | Rules |
|--------|------|-------|
| `place` | string | Specific named venue/attraction, not a city or region |
| `city` | string | City or district where the place is located |
| `best_time_to_travel` | string | Recommended time window using canonical values below |

Additional columns (include when data is available):

| Column | Description |
|--------|-------------|
| `day` | Day number (1–5) |
| `theme` | Which theme this place belongs to |
| `duration_hours` | Suggested time to spend at the place |
| `travel_time_from_prev` | Estimated travel time from the previous place in minutes |
| `notes` | Practical tips (book in advance, dress code, entry fee) |

## Day Structure Template
Each day should follow this rhythm:

```
Day N — [Theme Name]
Morning   (7:00–12:00): 1–2 places, unhurried
Lunch     (12:00–13:30): local food experience tied to the day's theme
Afternoon (13:30–18:00): 2–3 places
Evening   (18:00–21:00): 1 place or activity + dinner
```

Maximum 5–6 distinct places per day to keep pace realistic.

## Geographic Sequencing Rules
1. **Cluster by proximity** — group places within the same neighbourhood or district on the same day to minimise transit.
2. **Directional flow** — move through distinct zones progressively rather than backtracking.
3. **Heavy-hitter first** — put the most iconic or physically demanding experience in the morning.
4. **Rest pacing** — Day 3 or 4 should have a lighter schedule to account for fatigue.

## Travel Time Estimation
Use these defaults when exact data is unavailable; refine with web search when critical:

| Mode | Urban km | Estimated time |
|------|----------|----------------|
| Walking | ≤ 1.5 km | 15–20 min |
| Walking | 1.5–3 km | 25–40 min |
| Taxi/Rideshare | any | 10 min base + 3 min/km in traffic |
| Public transit | any | 20 min base + route time |
| Car/intercity | any | map distance / 60 km/h + 15 min buffer |

Flag any leg exceeding 45 minutes — consider whether it breaks day cohesion.

## best_time_to_travel Canonical Values
Use one of these for consistency:
- `"Early morning (7–9 am)"` — sunrise spots, crowded sites before crowds, markets
- `"Morning (9 am–12 pm)"` — standard museum/attraction opening hours
- `"Midday (12–2 pm)"` — food markets, shaded indoor venues
- `"Afternoon (2–5 pm)"` — walking tours, neighbourhoods
- `"Late afternoon (4–6 pm)"` — golden hour viewpoints, beach
- `"Evening (6–9 pm)"` — sunset, rooftops, dinner districts
- `"Night (9 pm+)"` — nightlife, night markets, stargazing

## Validation Checklist
Before finalising the itinerary:
- [ ] Every day has a named theme.
- [ ] No day exceeds 5–6 places.
- [ ] Every place has all three required columns populated.
- [ ] Travel times between consecutive places have been estimated.
- [ ] At least one food experience per day.
- [ ] Day 3 or 4 has a visibly lighter schedule.
- [ ] No place appears twice.
