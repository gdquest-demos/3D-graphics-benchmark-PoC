# (WIP) 3D Graphics Benchmark PoC

A demo showing an example of graphics benchmark using GDScript.

The objective is to set the user's graphic settings automatically, using the most compatible graphic settings the user can render at the threshold FPS.

The project flow goes as follows:

1. The game starts.
2. A "Benchmark" scene is instanced.
3. The `benchmark()` function is called. The `benchmark()` first disables the main viewport (to avoid noise in the render timestamp of the benchmark), and test each `GraphicSettings` resource set at the "Benchmark" scene sequentially (those are the `GraphicSettings` it may return). For each `GraphicSettings` to test:
   1. The `GraphicSettings` is applied to the benchmark viewport.
   2. A timestamp is created with `capture_timestamp("timestamp")`
   3. `RenderingServer.force_draw()` is called.
   4. On the next frame, the timestamp difference is captured with `rendering_device.get_captured_timestamp_gpu_time(0)`.
   5. If the render duration is bigger than a threshold, skips the rest of the test (user hardware is too slow for the Graphic settings, so there is no need to test further). Else, store the duration and test X more times, storing the average render frame time.
4. `benchmark()` stores the benchmark results for the different settings in `benchmark_results`.
5. The optimal `GraphicSettings` is applied to the root viewport.
