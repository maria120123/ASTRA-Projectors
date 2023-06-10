# Documentation for the ASTRA-Projectors package

This MATLAB package creates a pair of matrix free forward and backward projectors from ASTRA that are easy to use and incorporate into existing code. ASTRA is able to use either the CPU or GPU for computations with the projectors, as specified by the user.

## Supported ASTRA projectors
The following ASTRA projectors are supported:
- _line_
- _strip_
- _linear_

However, depending on the setup- and device type, some of the projectors might not be supported. The following table highlights which types of operators are available for which setups.

|      | Line    | Strip   | Linear |
|:---- |:--------|:--------|:-------|
|    __Parallel beam__             ||
|CPU   | &check; | &check; | &check;|
|GPU   | &cross; | &cross; | &check;|
|    __Fan beam__                  ||
|CPU   | &check; | &check; | &cross;|
|GPU   | &cross; | &cross; | &check;|

The back projector is automatically chosen when using the ASTRA projectors. The resulting normal equations will be either matched or unmatched depending on the type of device used for computation, as highlighted by the following table.

| Device | Parallel beam | Fan beam  |
|:----------|:--------------|:----------|
| CPU | Matched       | Matched   |    
| GPU | Unmatched     | Unmatched |

The mathematical details of the forward and back projectors can be found in the book P. C. Hansen, J. S. Jørgensen, and W. R. B. Lionheart, Computed Tomography: Algorithms, Insight, and Just Enough Theory, SIAM, 2021. Which can be found here: 
https://my.siam.org/Store/Product/viewproduct/?ProductId=38341835

Note: fan beam geometry is referred to as _fanflat_ in ASTRA.

## Creating the projector pairs
The function _astra_projectors()_ creates a projector pair given a set of CT parameters. There are four mandatory input arguments _GPU_, _num_pixels_, _num_angles_, and _num_detectors_. Further input arguments are accepted which are covered in the function documentation.
-	Note: Using GPU results in an unmatched projector pair while using CPU results in a matched projector pair.


The projector pair A and B are MATLAB class that acts as matrices. They can compute the forward and backward projection as matrix-vector products with the usual multiplication operator A*x, B*x or with the function handles A.mtimes(x) and B.mtimes(x). Moreover, routines can get the size of the projectors with the usual size(A) and size(B).

Finally, it is possible to materialize the operators with the functions sparse(A), sparse(B), full(A), and full(B). Where sparse() returns a sparse matrix and full() returns a dense matrix.

_Note:_ Having the multiplication operator “*” defined, means that the two projectors A and B can easily be passed to existing code without any modifications.

## Setting up the package
Check GPU compatibility:
ASTRA uses CUDA to offload forward and backward projections. This requires an NVIDIA GPU to run. To see if the computer has such a device, run the command “nvidia-smi” in the terminal.  A successful result indicates that the GPU exists and is compatible.

Install ASTRA: https://astra-toolbox.com/docs/install.html
-	Ensure that CUDA is enabled if you wish to use GPU.
o	An automatic check has been implemented based on the MATLAB package GPU computing.

Include the package folder.
-	Run either:
    1)	_astra_setup()_ included in this package providing the file path to the ASTRA installation (only the first time).
    2)	Include the ASTRA directories matlab/mex and matlab/tools in your MATLAB path.

Now you are ready to use the ASTRA-Projectors package.
