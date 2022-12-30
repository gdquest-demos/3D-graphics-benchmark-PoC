# 3D Graphics Benchmark PoC

A demo showing an example of graphics benchmark using GDScript.

The objective is to set the user's graphic settings automatically, using the most compatible graphic settings the user can render at the threshold FPS.

The project flow goes as follows:

1. The game starts.
2. A "Benchmark" scene is instanced.
3. The `benchmark()` function is called. The `benchmark()` first disables the main viewport (to avoid noise in the render timestamp of the benchmark), and test each `GraphicSettings` resource set at the "Benchmark" scene sequentially (those are the `GraphicSettings` it may return). For each `GraphicSettings` to test:
   1. The `GraphicSettings` is applied to the benchmark viewport.
   2. `RenderingServer.force_draw()` is called, and the call duration is stored using `Time.get_unix_time_from_system()`.
   3. If the render duration is bigger than a threshold, skips the rest of the test (user hardware is too slow for the Graphic settings, so there is no need to test further). Else, store the duration and test X more times, storing the average render frame time.
4. `benchmark()` returns the optimal `GraphicSettings` resource (the setting with the highest render frame time, which is the highest graphic setting below the frame time threshold).
5. The optimal `GraphicSettings` is applied to the root viewport.

# TODOs / Need investigation

- first rendertime of graphic settings takes more time than the others.
- render-time -> fps approximation?
- how UE does its threshold for the render-time
