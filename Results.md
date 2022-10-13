Machine   | OS    | RAM | Cores | Threads | -j | Libs | clang | flang | Notes
---------:|------:|----:|------:|--------:|---:|-----:|------:|------:|------ 
Ryzen 5600G | Linux | 32G | 6   |      12 |  4 | 25:17| 13:41 | 23:48 |
Ryzen 5600G | Linux | 32G | 6   |      12 | 12 | 15:00|  8:10 | 14:44 | 
Ryzen 3100  | Linux | 16G |   4 |       8 |  8 | 20:53|11:24  | fail  | Ran out of RAM during flang compilation (Maximum resident set size 5,685,444 Kb)
Ryzen 3100  | Linux | 16G |   4 |       8 |  4 | 23:26| 14:12 | 23:27 | 
Xeon X5680| MacOS | 12G |     6 |      12 | 12 | 37:14| 18:22 | fail  | Ran out of RAM during flang compilation (Maximum resident set size 4,685,930,496 bytes)
Xeon X5680| MacOS | 12G |     6 |       6 | 12 |43:56 |21:28  |39:28  |
Apple M1  | MacOS |  8G |     8 |       8 |  4 |17:32 | 8:51  |  25:12| Passive cooling
Apple M1  | MacOS |  8G |     8 |       8 |  4 |17:19 | 8:32  |  22:28| Laptop external cooler
Apple M1  | MacOS |  8G |     8 |       8 |  8 |13:42 | 7:03  |3:01:51| Passive cooling
Ampere A1 |FreeBSD| 24G |     4 |       4 |  4 |39:14 | 17:24 | 34:17 | 
