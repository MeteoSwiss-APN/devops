Code Development
==================

C++ dycore
-------------

Serialized unittest data
^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to run test the C++ dycore, the regression tests require a set of serialized data files from COSMO. 
Jenkins runs periodically the serialization (`<https://jenkins-mch.cscs.ch/job/cosmo_serialize/>`_), which installs all the serialized data set corresponding to the latest master in the g110 project space. In order to find the location of the jenkins serialized data follow the steps described in :ref:`Locate jenkins serialized data`.

In a different development situation where you are modifying the FORTRAN COSMO dycore, the master serialized data by jenkins will not be compatible with your modifications. 
In that case you need to serialize your own data (see :ref:`Serialize your own data`).

Before we can start, we need to load the spack instance

.. code-block:: bash

   . /project/g110/spack/user/admin-tsa/spack/share/spack/setup-env.sh


Locate jenkins serialized data
""""""""""""""""""""""""""""""""
This section describes how to find the location of the serialized data by jenkins for the master version of COSMO. 

Set the spack spec of COSMO for serialization mode: 

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@master%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

Find the spack install location of the serialized data

.. code-block:: bash

  SERIALIZE_DATA=$(spack location -i ${COSMO_SERIALIZE_SPEC})/data


Serialize your own data
""""""""""""""""""""""""""

Set the spack spec (for dev-build version) of COSMO for serialization mode: 

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

In your working directory of cosmo, build a spack COSMO executable for serialization

.. code-block:: bash

  cd </path/to/cosmo>
  spack dev-build ${COSMO_SERIALIZE_SPEC}

Load the spack instance modules

.. code-block:: bash

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads ${COSMO_SERIALIZE_SPEC} )

Get the testsuite data

.. code-block:: bash

  cd </path/to/cosmo>/cosmo/test/testsuite/data
  ./get_data.sh

Execute the serialized data generation

.. code-block:: bash

  cd </path/to/cosmo>/cosmo/ACC
  python2 test/serialize/generateUnittestData.py -v -e cosmo_serialize --mpirun=srun


Set the path to the serialized data (later it will be used in this guide)

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
  source <( spack module tcl loads ${DYCORE_SPEC} )

Run the regression tests on a serialized data set, for example: 

.. code-block:: bash
  
  </path/to/cosmo>/spack-build/src/tests/regression/regression_tests/regression_tests -p ${SERIALIZE_DATA}/cosmo1_test3

In case you need to run the tests on a compute node, you should prepend the previous command with `srun` and the corresponding arguments. 


Recompile 
^^^^^^^^^^^

Once the `spack dev-build` has been called, the dycore can be recompiled any time by simply calling make on the build directory.
Like that, spack is only needed to setup the build and environment. 
In order to use flat make for further compilations, you need to load first the spack dycore module

.. code-block:: bash

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads ${DYCORE_SPEC} )

And build simply calling make in the right build directory 

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

In this section we describe how to compile COSMO and link against any of the versions installed by jenkins.
In this case  compiling the C++ dycore is not required. 
First we need to find the hash of the C++ dycore installation for the desired variant (we set a dycore spec as an example): 

.. code-block:: bash

  DYCORE_SPEC="cosmo-dycore@master real_type=float build_type=Release +cuda"
  DYCORE_HASH=$(spack find --format "{hash}" ${DYCORE_SPEC})

If the configuration of variants required does not exists (it means it has not been installed by jenkins), we will have to compile
the C++ dycore as well (you can skip the rest of this section and jump instead to :ref:`Compile cosmo against a modified version of the dycore`)

Set the spack spec of COSMO:

.. code-block:: bash 
 
  COSMO_SPEC="cosmo@master%pgi real_type=float cosmo_target=gpu +cppdycore +claw ^/${DYCORE_HASH}"

.. note:: The COSMO spack recipe contains a variant `production`. When activated as `+production` the spec will ensure that all other variants are the ones used to compile an executable for production. 

In your working directory of cosmo, compile an executable using spack

.. code-block:: bash
  
  spack dev-build -i ${COSMO_SPEC}


Compile cosmo against a modified version of the dycore
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this section we show how to compile a version of COSMO where the C++ dycore has been modified or the version and variant configuration has not been installed by jenkins.
First we need to compile the local version of the dycore. Follow the steps in :ref:`Compile and Test a Local C++ dycore`.
Assuming the `DYCORE_SPEC` has already been set, we determine the hash of the spack dycore installation

.. code-block:: bash

  DYCORE_HASH=$(spack find --format "{hash}" ${DYCORE_SPEC})

Then we set the COSMO spec

.. code-block:: bash 
 
  COSMO_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=gpu +cppdycore +claw"


Then we can compile a COSMO executable from the working directory

.. code-block:: bash

  cd </path/to/cosmo>/
  spack dev-build -i ${COSMO_SPEC} ^/${DYCORE_HASH}

Testing COSMO with the Testsuite
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following commands demonstrate how to launch the testsuite for a COSMO executable compiled in dev-build mode

.. code-block:: bash 
 
  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
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


Any Other Package
------------------------


The command `spack dev-build` can be used to compile any modified version of a MeteoSwiss software from your working directory. 
However being able to compile any other package might require installing your spack instance, if that package is installed by a jenkins plan.
An attempt to build your working copy with the command

.. code-block:: bash

  spack install <package>@master ... 

will not perform any compilation if spack identifies that the requested version of the software was already installed by a jenkiny plan. 

That problem is circumvented for COSMO and the C++ dycore by reserving an specific version (`dev-build`) of the spack recipe of the package 
(see `link <https://github.com/MeteoSwiss-APN/spack-mch/blob/0092230d325525197f8991b172b321ffdb4a118a/packages/cosmo/package.py#L54>`_), 
which will not be used by jenkins. Therefore, `spack dev-build cosmo@dev-build` will find that version among the installed in the default spack instance.
For any other package that does not contain this `dev-build` version, we will install our own spack instance. 

.. code-block:: bash

  
  git clone git@github.com:MeteoSwiss-APN/spack-mch.git
  cd spack-mch
  ./config.py -m tsa -i . -r ./spack/etc/spack -p $PWD/spack -u ON

  . spack/share/spack/setup-env.sh

And then compile our package with spack in dev-build mode

.. code-block:: bash

  cd </path/to/package> 
  spack dev-build <package>@<version>

