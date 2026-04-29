# Google Docs Publishing

## Purpose
Define the exact document structure, formatting conventions, and tool call pattern for publishing a completed travel itinerary to Google Docs.

## Document Structure

```
[Document Title]
5-Day [Location] Travel Itinerary

[Section 1] Overview
- Destination summary (2–3 sentences)
- Travel themes covered (bulleted list)
- How to use this itinerary (1 sentence)

[Section 2] Theme Summaries
One short paragraph per theme explaining why it was selected and what to expect.

[Section 3] Day-by-Day Itinerary
For each day (1–5):
  Heading: Day N — [Theme Name] — [City/Area]
  Table: place | city | best_time_to_travel | duration_hours | travel_time_from_prev | notes
  End-of-day callout: "Where to eat tonight" (1–2 restaurant suggestions)

[Section 4] Quick Reference Table
Flattened single table of ALL places across all 5 days.
Columns: day | place | city | best_time_to_travel
This is the canonical output required by the agent spec.

[Section 5] Practical Tips
- Visa / entry requirements (remind user to verify)
- Currency and payment norms
- Getting around (primary transport modes)
- Best time of year to visit
```

## Formatting Conventions
- Document title: `5-Day [Location] Travel Itinerary`
- Day headings: Heading 2 style, e.g. `Day 1 — Art & Heritage — Florence`
- Tables: Use markdown table syntax in the doc body.
- Bold the `place` name in every table row.
- Use em-dash (—) as separator in headings, not hyphen.

## create_google_doc Call Pattern
The tool accepts a title and body. Structure the call as:

```
title: "5-Day [Location] Travel Itinerary"
body: <full document content as markdown>
```

If the tool has a character limit per call, split into multiple calls:
1. First call: title + Overview + Theme Summaries.
2. Subsequent calls: one call per day.
3. Final call: Quick Reference Table + Practical Tips.

## Required Output Columns
The Quick Reference Table in Section 4 MUST contain exactly:
- `place`
- `city`
- `best_time_to_travel`

Do not omit these columns from the final document.

## Quality Gate Before Publishing
- [ ] Document title includes location.
- [ ] All 5 days are present.
- [ ] Section 4 Quick Reference Table contains all required columns for every place.
- [ ] No placeholder text (e.g., "[TBD]", "INSERT HERE") remains.
- [ ] Practical Tips section is present.
