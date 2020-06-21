Code Development
==================

C++ dycore
-------------

Serialized unittest data
^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to run test the C++ dycore, the regression tests require a set of serialized data files from COSMO. 
Jenkins runs periodically the serialization (`<https://jenkins-mch.cscs.ch/job/cosmo_serialize/>`_), which installs all the serialized data set corresponding to the latest master in the g110 project space. In order find the location of the jenkins serialized data follow the steps described in :ref:`Locate jenkins serialized data`.

In a development situation where you are modifying the FORTRAN COSMO dycore, the master serialized data by jenkins will not be compatible with your modifications. 
In that case you need to serialize your own data (see :ref:`Serialize your own data`).

Before we can start, we need to load the spack instance

.. code-block:: bash

   . /project/g110/spack/user/admin-tsa/spack/share/spack/setup-env.sh


Locate jenkins serialized data
""""""""""""""""""""""""""""""""
In order to find the location of the serialized data, execute the following steps: 

Set the spack spec of COSMO for serialization mode: 

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@master%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

Find the spack install location of the serialized data

.. code-block:: bash

  SERIALIZE_DATA=$(spack location -i $(COSMO_SERIALIZE_SPEC))/data


Serialize your own data
""""""""""""""""""""""""""

Set the spack spec (for dev-build version) of COSMO for serialization mode: 

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

In your working directory of cosmo, build a spack COSMO executable for serialization

.. code-block:: bash

  cd </path/to/cosmo>
  spack dev-build $(COSMO_SERIALIZE_SPEC)

Load the spack instance modules

.. code-block:: bash

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads $(COSMO_SERIALIZE_SPEC) )

Get the testsuite data

.. code-block:: bash

  cd </path/to/cosmo>/cosmo/test/testsuite/data
  ./get_data.sh

Execute the serialized data generation

.. code-block:: bash

  cd </path/to/cosmo>/cosmo/ACC
  python2 test/serialize/generateUnittestData.py -v -e cosmo_serialize --mpirun=srun


Set the path to the serialized data

.. code-block:: bash

  SERIALIZE_DATA=</path/to/cosmo>/cosmo/ACC/test/serialize/data/

Compile and Test a Local C++ dycore
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This section describes how to compile and test a version of the COSMO C++ dycore from your working directory. 

Set a COSMO C++ dycore spec

.. code-block:: bash

  DYCORE_SPEC="cosmo-dycore@master real_type=float build_type=Release"

In your working directory of cosmo, build a C++ dycore executable 

.. code-block:: bash

  cd </path/to/cosmo>
  spack dev-build cosmo-dycore@master real_type=float build_type=Release +cuda

Load the spack dycore module

.. code-block:: bash

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads $(DYCORE_SPEC) )

Run the regression tests on a serialized data set, for example: 

.. code-block:: bash
  
  </path/to/cosmo>/spack-build/src/tests/regression/regression_tests/regression_tests -p $(SERIALIZE_DATA)/cosmo1_test3


Recompile 
^^^^^^^^^^^

Once the `spack dev-build` has been called, the dycore can be recompile any time by simply calling make on the build directory.

Load the spack dycore module

.. code-block:: bash

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads $(DYCORE_SPEC) )

And build 

.. code-block:: bash

  cd </path/to/cosmo>/spack-build/
  make


COSMO
-------------

Compiling cosmo in a working directory where it is being develop will be different in two cases: 
 
 * Compile cosmo against a master/mch/release version of the dycore
 * Compile cosmo against a modified version of the dycore

Before we can start, we need to load the spack instance

.. code-block:: bash

  . /project/g110/spack/user/admin-tsa/spack/share/spack/setup-env.sh


Compile cosmo against a master version of the dycore
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this case, we wish to link against any of the versions installed by jenkins, compiling the C++ dycore is not required. 

Set the spack spec of COSMO:

.. code-block:: bash 
 
  COSMO_SPEC="cosmo@master%pgi real_type=float cosmo_target=gpu +cppdycore +claw"

.. note:: The COSMO spack recipe contains a variant `production`. When activated as `+production` the spec will ensure that all other variants are the ones used to compile an executable for production. 

In your working directory of cosmo, compile an executable using spack

.. code-block:: bash
  
  spack dev-build $(COSMO_SPEC)


Compile cosmo against a modified version of the dycore
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

First we need to compile the local version of the dycore being develop. Follow the steps in :ref:`Compile and Test a Local C++ dycore`.
Assuming the `DYCORE_SPEC` has already been set, get determine the hash of the spack dycore installation

.. code-block:: bash

  DYCORE_HASH=$(spack find --format "{hash}" ${DYCORE_SPEC})

We set the COSMO spec

.. code-block:: bash 
 
  COSMO_SPEC="cosmo@master%pgi real_type=float cosmo_target=gpu +cppdycore +claw"


Then we can compile a COSMO executable from the working directory

.. code-block:: bash

  cd </path/to/cosmo>/
  spack dev-build -i $(COSMO_SPEC) ^/$(DYCORE_HASH)

Testing COSMO with the Testsuite
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following commands demonstrate how to launch the testsuite for a COSMO executable compiled in dev-build mode

.. code-block:: bash 
 
  module use spack-mch/spack/modules/$slave/linux-rhel7-skylake_avx512
  module use /project/g110/modules/admin-$slave/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads ${SPACK_SPEC} )

  # launch tests
  cp -f <path/to/cosmo>/cosmo/ACC/cosmo_float cosmo/test/testsuite
  cd cosmo/test/testsuite/data
  ./get_data.sh
  cd ..

  if [[ $real_type == 'float' ]]; then
    export REAL_TYPE=FLOAT
  fi

  if [[ $target == 'cpu' ]]; then
    export JENKINS_NO_DYCORE=ON
  fi

  ASYNCIO=ON sbatch -p debug -W submit.tsa.slurm

