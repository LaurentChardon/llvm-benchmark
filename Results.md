Machine   | OS    | RAM | Cores | Threads | -j | Libs | clang | flang | Notes
---------:|------:|----:|------:|--------:|---:|-----:|------:|------:|------ 
Ryzen 5700X | Linux | 32G | 8   |      16 | 16 | 11:19| 6:13 | fail |
Ryzen 5700X | Linux | 32G | 8   |      16 |  8 | 12:31| 6:58 | fail |
Ryzen 5700X | Linux | 32G | 8   |      16 |  4 | 21:06| 11:28 | 18:58 |
Ryzen 5600G | Linux | 32G | 6   |      12 |  4 | 25:17| 13:41 | 23:48 |
Ryzen 5600G | Linux | 32G | 6   |      12 | 12 | 15:00|  8:10 | 14:44 | 
Ryzen 3100  | Linux | 16G |   4 |       8 |  8 | 20:53|11:24  | fail  | Ran out of RAM during flang compilation (Maximum resident set size 5,685,444 Kb)
Ryzen 3100  | Linux | 16G |   4 |       8 |  4 | 23:26| 14:12 | 23:27 | 
Xeon X5680| MacOS | 12G |     6 |      12 | 12 | 37:14| 18:22 | fail  | Ran out of RAM during flang compilation (Maximum resident set size 4,685,930,496 bytes)
Xeon X5680| MacOS | 12G |     6 |      12 |  6 |43:56 |21:28  |39:28  |
Apple M1  | MacOS |  8G |     8 |       8 |  4 |17:32 | 8:51  |  25:12| Passive cooling
Apple M1  | MacOS |  8G |     8 |       8 |  4 |17:19 | 8:32  |  22:28| Laptop external cooler
Apple M1  | MacOS |  8G |     8 |       8 |  8 |13:42 | 7:03  |3:01:51| Passive cooling
Ampere A1 |FreeBSD| 24G |     4 |       4 |  4 |39:14 | 17:24 | 34:17 | 
Ampere A1 |FreeBSD|512G |    80 |      80 | 80 | 2:05 |  1:48 |  5:46 | 
E5-2670   | Linux |128G |    16 |      32 | 32 |12:10 |  6:50 | 11:16 | 
E5-2670   | Linux |128G |    16 |      32 | 16 |15:21 |  8:44 | 14:05 | 
E5-2697 V3| Linux |128G |    28 |      56 | 56 | 5:39 |  3:21 |  6:19 |
E5-2697 V3| Linux |128G |    28 |      56 | 28 | 6:25 |  3:48 |  6:22 |

