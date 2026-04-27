# Travel Theme Research

## Purpose
Systematically identify the 4–6 strongest travel themes for a given location so every downstream itinerary day has a coherent focus.

## Theme Identification Framework

### Step 1 — Seed categories
Always evaluate the location against these universal theme buckets:
- **Nature & Landscapes** (national parks, coastlines, mountains, wildlife)
- **History & Heritage** (UNESCO sites, archaeological zones, colonial districts)
- **Food & Culinary Culture** (local cuisine, markets, wine/coffee regions)
- **Arts, Architecture & Culture** (museums, street art, performing arts)
- **Adventure & Outdoor Activities** (trekking, diving, cycling, skiing)
- **Wellness & Spirituality** (temples, retreats, thermal baths)
- **Urban Life & Nightlife** (neighbourhoods, rooftops, local social scene)
- **Unique Local Experiences** (festivals, craft traditions, seasonal phenomena)

### Step 2 — Rank themes
Score each seed category present for the location on three axes (1–3 each):

| Axis | 1 | 2 | 3 |
|------|---|---|---|
| **Traveler demand** | niche | moderate | mass appeal |
| **Distinctiveness** | generic | notable | world-class or unique |
| **Year-round viability** | seasonal | most of year | year-round |

Select the top 4–6 by total score. Break ties by distinctiveness.

### Step 3 — Validate with web search
For each selected theme, run a targeted search: `"[location] [theme keyword] travel guide"`. Confirm:
- At least 3 named places or experiences exist per theme.
- No major accessibility or safety issues make a theme impractical.

### Step 4 — Name and describe each theme
Output each theme as:
```
Theme: <short evocative name>
Why here: <1–2 sentences on what makes this theme exceptional for this location>
Key experiences: <3–5 bullet points of named places or activities>
```

## Anti-patterns to avoid
- Do not list more than 6 themes — itinerary days are finite.
- Do not include a theme if fewer than 3 concrete places support it.
- Do not duplicate themes (e.g., "History" and "Colonial Architecture" should merge).

## Output contract
Return a ranked list of themes before proceeding to itinerary planning. Each theme must have a name, a "why here" rationale, and 3–5 concrete experiences.
