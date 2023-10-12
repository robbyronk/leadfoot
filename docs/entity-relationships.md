# ERD

```mermaid
---
title: Future Entity Relationship Diagram
---
erDiagram
    USER ||--o{ LAP-TIME : sets
    USER ||--o{ TUNE : has
    TRACK ||--o{ LAP-TIME : has
    CAR ||--o{ LAP-TIME : has
    TUNE ||--o{ LAP-TIME : has
    TUNE ||--o| GEARING : has
    CAR ||--o{ TUNE : has
```

```mermaid
---
title: Current Entity Relationship Diagram
---
erDiagram
    USER ||--o{ LAP-TIME : sets
```

Lap Time
- Time (integer of milliseconds)
- User
- Car (text)
- Track (text)
- Tune (text)
- Controller/Wheel/Keyboard
- Video Link
- Other Notes

```shell
mix phx.gen.live Leaderboard LapTime lap_times lap_time_millis:integer car:string track:string tune:string input_method:string video_url:string notes:string user_id:references:users --binary-id
```
