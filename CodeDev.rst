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

  module load python/3.7.4  
  . /project/g110/spack/user/tsa/spack/share/spack/setup-env.sh


Locate jenkins serialized data
""""""""""""""""""""""""""""""""
This section describes how to find the location of the serialized data by jenkins for the master version of COSMO. 

Set the spack spec of COSMO for serialization mode: 

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@master%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

Find the spack install location of the serialized data

.. code-block:: bash

  SERIALIZE_DATA=$(spack location -i ${COSMO_SERIALIZE_SPEC})/data


Serialize your own data (manually)
""""""""""""""""""""""""""""""""""

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

Serialize your own data using devbuildcosmo (in developement might be unstable)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

Set the spack spec (for dev-build version) of COSMO for serialization mode:

.. code-block:: bash

  COSMO_SERIALIZE_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=cpu +serialize ~cppdycore"

In your working directory of cosmo, build a spack COSMO executable for serialization

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo ${COSMO_SERIALIZE_SPEC} #use -c option for a clean build

Compile and Test a Local C++ dycore (manually)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

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


Recompile (manually)
^^^^^^^^^^^^^^^^^^^

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

Compile and Test a Local C++ dycore using devbuildcosmo (might be unstable)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set a COSMO C++ dycore spec

.. code-block:: bash

  DYCORE_SPEC="cosmo-dycore@master real_type=float build_type=Release"

In your working directory of cosmo, build a C++ dycore executable, stop it manually after the test of dycore and before the cosmo installation begins

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo -t cosmo@dev-build ^DYCORE_SPEC

Recompile using devbuildcosmo (might be unstable)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Just use directly devbuildcosmo still you have to stop it manually before the cosmo installation:

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo cosmo@dev-build ^DYCORE_SPEC #use -c option if you want a make clean

COSMO
-------------

We distinguish two sceneraios for compiling cosmo from a working directory:

 * :ref:`Compile a local version of COSMO` (that will also compile the C++ dycore locally)
 * :ref:`Compile cosmo against a master/release version of the dycore` (that has already been installed by jenkins)

Before we can start, we need to load the spack instance

.. code-block:: bash

  module load python/3.7.4
  . /project/g110/spack/user/tsa/spack/share/spack/setup-env.sh

Compile a local version of COSMO (manually)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In this section we show how to compile a version of COSMO with a local C++ dycore. 
First we need to compile the local version of the dycore (as described in :ref:`Compile and Test a Local C++ dycore`).

.. code-block:: bash

  DYCORE_SPEC="cosmo-dycore@dev-build real_type=float build_type=Release"

Before installing the dycore we need to remove any previous installation

.. code-block:: bash

  spack uninstall -f ${DYCORE_SPEC}

Next build and install a local C++ dycore executable

.. code-block:: bash

  cd </path/to/cosmo>
  spack dev-build cosmo-dycore@dev-build real_type=float build_type=Release +cuda


Find the hash of the `DYCORE_SPEC` that has just been installed.

.. code-block:: bash

  DYCORE_HASH=$(spack find --format "{hash}" ${DYCORE_SPEC})

Set the COSMO spec

.. code-block:: bash 

  COSMO_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=gpu +cppdycore +claw"


Finally we can compile a COSMO executable from the working directory

.. code-block:: bash

  cd </path/to/cosmo>/
  spack dev-build -i ${COSMO_SPEC} ^/${DYCORE_HASH}

Compile a local version of COSMO using devbuildcosmo (might be unstable)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Set the COSMO spec

.. code-block:: bash

  COSMO_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=gpu +cppdycore +claw"

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo $COSMO_SPEC #use the -t option for testing, -c for clean build


Compile cosmo against a master/release version of the dycore
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In case the local dycore has not been modified and you know it has been installed by jenkins, we can compile COSMO and link against the version installed by jenkins.
In this case  compiling the C++ dycore is not required. 
First we need to find the hash of the C++ dycore installation for the desired variant (we set a dycore spec as an example): 

.. code-block:: bash

  DYCORE_SPEC="cosmo-dycore@master real_type=float build_type=Release +cuda"
  DYCORE_HASH=$(spack find --format "{hash}" ${DYCORE_SPEC})

!!!
Careful here: the spack find command can find more than one version satisfying the DYCORE_SPEC in that case the DYCORE_HASH variable will be a list which you don't want, we therefore adivce to always check the type of the variable:

.. code-block:: bash
  echo $DYCORE_HASH

before doing any installation, especially to check if it is not a list. In case of a list set $DYCORE_HASH manually by checking which hash is corresponding to you dycore installation with:

.. code-block:: bash
  spack find -lpv $DYCORE_SPEC
!!!

If the configuration of variants required does not exists (it means it has not been installed by jenkins), we will have to compile
the C++ dycore as well (you can skip the rest of this section and jump instead to :ref:`Compile a local version of COSMO`)

Set the spack spec of COSMO:

.. code-block:: bash

  COSMO_SPEC="cosmo@master%pgi real_type=float cosmo_target=gpu +cppdycore +claw ^/${DYCORE_HASH}"

.. note:: The COSMO spack recipe contains a variant `production`. When activated as `+production` the spec will ensure that all other variants are the ones used to compile an executable for production.

In your working directory of cosmo, compile an executable using spack

.. code-block:: bash

  spack dev-build -i ${COSMO_SPEC}


Compile cosmo against a master/release version of the dycore with devbuildcosmo (might be unstable)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Set the COSMO spec

.. code-block:: bash

  COSMO_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=gpu +cppdycore +claw"

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo -w $COSMO_SPEC #use the -t option for testing, -c for clean build


Testing COSMO with the Testsuite
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following commands demonstrate how to launch the testsuite for a COSMO executable compiled in dev-build mode

.. code-block:: bash 

  module use /project/g110/modules/admin-tsa/linux-rhel7-skylake_avx512/
  source <( spack module tcl loads ${SPACK_SPEC} )

  # launch tests
  cp -f <path/to/cosmo>/cosmo/ACC/cosmo_gpu cosmo/test/testsuite
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

Testing COSMO with the Testsuite using devbuildcosmo (might be unstable)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Set the COSMO spec

.. code-block:: bash

  COSMO_SPEC="cosmo@dev-build%pgi real_type=float cosmo_target=gpu +cppdycore +claw"

Testing COSMO and DYCORE together:

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo -t $COSMO_SPEC #-c for clean build

Testing only COSMO:

.. code-block:: bash

  cd </path/to/cosmo>
  spack devbuildcosmo -wt $COSMO_SPEC #-c for clean build

Any Other Package
------------------------


The command `spack dev-build` can be used to compile any modified version of a MeteoSwiss software from your working directory. 
However being able to compile any other package might require installing your spack instance, if that package is installed by a jenkins plan.
An attempt to build your working copy with the command

.. code-block:: bash

  spack install <package>@master ... 

will not perform any compilation if spack identifies that the requested version of the software was already installed by a jenkins plan. 

That problem is circumvented for COSMO and the C++ dycore by reserving an specific version (`dev-build`) of the spack recipe of the package 
(see `link <https://github.com/MeteoSwiss-APN/spack-mch/blob/0092230d325525197f8991b172b321ffdb4a118a/packages/cosmo/package.py#L54>`_), 
which will not be used by jenkins. Therefore, `spack dev-build cosmo@dev-build` will find that version among the installed in the default spack instance.
For any other package that does not contain this `dev-build` version, we will install our own spack instance. 

.. code-block:: bash

  module load python/3.7.4 
  git clone git@github.com:MeteoSwiss-APN/spack-mch.git
  cd spack-mch
  ./config.py -m tsa -i . -p $PWD/spack -u ON

  . spack/share/spack/setup-env.sh

And then compile our package with spack in dev-build mode

.. code-block:: bash

  cd </path/to/package> 
  spack dev-build <package>@<version>

