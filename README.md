# Hsah Tables for 3D Spatial Management of Moving Items

Using the Godot game engine, we implemented and tested spatial hash grids for collision detection between thousands of entities. This includes a simulation script that visualizes collisions between entities, displays information about the number of detections and the query time, and an optional toggle to display the grid cells. We used this simulation to compare the efficiency and runtime of three implementations and documented the results.

# Implementation

The spatial hash grid implementations were written as individual scripts using the GDScript language. The naive class is a brute-force O(N^2) approach to neighbour detection that was made to serve as a comparison for the efficiency of the spatial hash approach. Every object checks the distance of every other object to determine whether they are within range.

The spatial_hash_grid class is a "standard" approach to spatial hashing, using a Dictionary with Vector3 as the key and an array of SpatialClients as the value. When we search for neighbours or collisions, we just check the cells surrounding the object. The objects in the surrounding cells are candidates. The candidates are collisions if the distance between the candidate and the searching object is within the collision threshold. If every object was in the same cell, our performance would again be O(N^2) because every object would be a candidate for every other object.

The spatial_hash_grid_optimized was an attempt to improve the performance even further. This version uses two PackedInt32Arrays which are memory-efficient data structures. The structure we are using is essentially a linked list inside an array. At each frame the grid is linearly rebuilt. The structure is based off of the 10MinutePhysics collision detection presentation and code. There are likely more performance improvements that could be made, but this version was able to perform noticeably better than the original version.

# Simulation

The simulation script was built to visualize and test the spatial hash grid scripts to detect collisions between entities. The script creates a number of SpatialClients randomly within the world bounds. The clients constantly move in a straight line, inversing their velocity when they hit a world boundary. Each client calls the collision detection function each frame, and changes color from blue to orange when a collision is detected. Using the space bar toggles the simulation between the naive, spatial hash, and optimized spatial hash, which allowed us to easily test each version with the same entity count, cell size, and world size. We added the "show grid" toggle to show how the spatial hash grid is used in the simulation. When toggled, the grid shows the boundaries of each occupied cell.

# Benchmarking and Complexity Analysis

To validate the efficiency of the spatial hash grid, we directly implemented a benchmarking system that toggles the simulation between the spatial hash mode, the optimized spatial hash grid, and a naive brute force algorithm mode. The naive approach checks every entity against each other and was used as a baseline for comparison against the spatial hash method. We tested the simulation using 3 different entity amounts for each mode, and recorded the query time, candidate count, and collision count every 5 seconds. For each set of values tested, 5 outputs were recorded and averaged to get the results shown in the table below.

| Entities | Mode      | Avg Query (ms) | Avg Candidates | Avg Collisions |
| -------- | --------- | -------------- | -------------- | -------------- |
| 500      | Naive     | 76.86          | 16             | 2              |
| 500      | Spatial   | 3.96           | 529            | 1              |
| 500      | Optimized | 1.88           | 582            | 1              |
| 3000     | Naive     | 1498           | 586            | 38             |
| 3000     | Spatial   | 11.88          | 4079           | 34             |
| 3000     | Optimized | 6.55           | 5648           | 39             |
| 10000    | Naive     | 18974          | 6400           | 397            |
| 10000    | Spatial   | 54.45          | 21852          | 408            |
| 10000    | Optimized | 28.43          | 39502          | 415            |

The results confirmed the expected complexity difference. Naive query time showed consistent O(n^2) behaviour, with doubling entries causing a roughly 4x increase in query time. The Spatial Hash scaled nearly linearly across the same range. At 10000 entities, the spatial hash completed queries in around 54ms compared to the naive's 19000ms, approximately a 350x increase in speed. The optimized implementation maintained roughly 2x speed increase over the original spatial hash grid at each level. At 10000 entities, this meant a 665x increase in speed on average over the naive approach.

# References

[1] Blazing fast neighbor search with spatial hashing, https://matthias-research.github.io/pages/tenMinutePhysics/11-hashing.pdf (accessed Apr. 3, 2026).

[2] “Spatial Hash Grids & Tales From Game Development,” YouTube, https://www.youtube.com/watch?v=sx4IIQL0x7c (accessed Apr. 3, 2026).

[3] “How I Optimized My JavaScript Project (Complete Walkthrough) | Faster Spatial Hash Grids,” YouTube, https://www.youtube.com/watch?v=oewDaISQpw0 (accessed Apr. 3, 2026).

[4] Matthias-Research, “Pages/tenminutephysics/11-hashing.html at master · Matthias-Research/pages,” GitHub, https://github.com/matthias-research/pages/blob/master/tenMinutePhysics/11-hashing.html (accessed Apr. 3, 2026).

[5] “Godot Docs – 4.6 branch,” Godot Engine documentation, https://docs.godotengine.org/en/stable/ (accessed Apr. 3, 2026).

[6] GDScript tutorials, https://gdscript.com/tutorials/ (accessed Apr. 3, 2026).
