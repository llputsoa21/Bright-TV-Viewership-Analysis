# Turning raw data into clear, confident, customer-centric decisions.

📺 BrightTV Viewership Analytics — A data-driven Customer Value Management (CVM) analysis of BrightTV's viewership behaviour, uncovering who watches what, when, and where, to power smarter content, retention, and personalisation decisions.

Project Overview: BrightTV Viewership Analytics is an end-to-end SQL analytics project built on two core datasets — viewership_tv and user_profiles_tv. The goal is to transform raw viewing logs into actionable insights that support Customer Value Management (CVM): retaining high-value viewers, growing engagement in under-performing segments, and personalising the BrightTV experience. All timestamps are converted from UTC to SAST (South African Standard Time) to reflect true local viewing behaviour.

Objectives: Understand viewership patterns across age, gender, race, and province. Identify peak viewing times and content preferences by segment. Detect monthly trends, drop-offs, and growth opportunities. Translate insights into a CVM strategy: Retain, Grow, Personalise.

Data Sources: The viewership_tv table holds raw viewing events — UserID, channel, programme, start and end timestamps, and duration. The user_profiles_tv table holds user demographics — age, gender, race, and province. The two tables are joined on UserID to build an enriched viewership fact table.

Core SQL Logic: The master query joins viewership events with user profiles via LEFT JOIN, converts UTC timestamps to SAST (+02:00), buckets users into age groups (Youth, Adult, Senior), classifies sessions by time of day (Morning, Afternoon, Evening, Night), and calculates hours viewed safely from the Duration 2 field (HH:MM:SS), guarding against negative values.

Key Insights: Provinces watching the most — Gauteng leads, followed by KZN and Western Cape. Monthly trend — steady growth with a noticeable April drop-off worth investigating. Age group by channel — Youth dominate Sport and Music; Adults lean into News and Series. Time-of-day behaviour — Evening is the undisputed prime-time window across all segments.

CVM Strategy: Retain — reward high-engagement viewers with exclusive content and loyalty perks. Grow — re-engage low-activity provinces and recover the April drop-off with targeted campaigns. Personalise — recommend the right content, to the right viewer, at the right time, using segment-level signals.
