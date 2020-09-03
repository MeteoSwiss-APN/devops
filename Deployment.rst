Deployment of COSMO to OSM
============================ 

How to create the env.txt for operations
-----------------------------------------

The only thing you need is the exact spack specification you want to extract the env from.

For example:

.. code-block:: bash
  COSMO_SPEC="cosmo@5.07.mch1.0.p10%pgi +pollen real_type=float cosmo_target=gpu"

Then use the python script extract_env.py  and pass it this spec as argument

.. code-block:: bash
  git clone git@github.com:MeteoSwiss-APN/spack.git
  ./spack-mch/tools/osm/extract_env.py -s $COSMO_SPEC -idir <installation_dir>

This script is then creating a cosmo@version%compiler_run-env file depending on the given spec in your given installation folder. The run_env is then directly sourceable:

.. code-block:: bash
  cd <installation_dir>
  source cosmo@version%compiler_run-env
