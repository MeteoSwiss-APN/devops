Performance benchmarks of COSMO
=================================

The performance benchmarks use a local git repository (no remote) to track changes.
When you make changes or update something, please create a commit so others can
see what you did. ``environment/perf-benchmarks`` uses a separate git repository with remotes.

Each testcase has a ``reference_float`` folder with reference files. This makes it possible
to check whether the current files are OK. ``reference_float`` should be kept up
to date when changes are made to testcases.

``TIMINGS_float.cfg`` defines the reference timings and thresholds. ``TOLERANCE_float``
defines the tolerance when checking the output values.

Because we have regularly issues with file access permissions, you should use
``fix_permissions.sh`` before and after you made changes.
