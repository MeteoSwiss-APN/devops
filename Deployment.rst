Deployment of COSMO to OSM
============================ 

How to create the env.txt for operations
-----------------------------------------

The only thing you need is the exact spack specification you want to extract the env from.

For example:

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@5.07.mch1.0.p10%pgi +pollen real_type=float cosmo_target=gpu"

Then use the python script extract_env.py  and pass it this spec as argument

.. code-block:: bash

  git clone git@github.com:MeteoSwiss-APN/spack.git
  ./spack-mch/tools/extract_env.py $COSMO_SERIALIZE_SPEC

This script is then creating a env.txt file depending on the given spec. The env.txt is directly sourceable:

.. code-block:: bash

  source env.txt
