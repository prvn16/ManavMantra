function [results] = checkGpuInstall( varargin )
%CODER.CHECKGPUINSTALL Verify the GPU code generation environment
%
%   CODER.CHECKGPUINSTALL checks the GPU code generation environment on your
%   machine. By default, this will check the CUDA environment, basic GPU
%   code generation, generated GPU code execution, and the cuDNN environment
%   on your host machine.
%
%   CODER.CHECKGPUINSTALL(OPTIONS) checks the GPU code generation environment
%   based on the given parameters.
%
%   Possible parameters:
%
%   'default'          This will perform the default system check on
%                      the host machine, checking for CUDA SDK, cuDNN,
%                      and ensuring basic code generation works correctly.
%
%   'host'             This will check for a host CUDA environment.
%
%   'crosscompile'     This option will add system checks for
%                      all the Jetson Tegra cross-compile environments.
%   
%   'full'             Specifying this option will perform all available
%                      system checks.
%
%   'tk1','tx2','tx1'  Any of these options will check for the
%                      respective cross-compile environment of that
%                      Jetson Tegra platform.
%
%   'gpu'              This option will check if a compatible GPU
%                      device is present on the host machine for code
%                      execution.
%
%   'codegen'          This option will test basic code generation and
%                      building on the host machine. Prerequisite is a host
%                      CUDA code generation environment.
%
%   'codeexec'         This option performs the same code generation as
%                      the 'codegen' option, and then tests that the code
%                      executes properly on the host machine. Prerequisite
%                      is a host CUDA code generation environment and 
%                      successful code generation.
%
%   'cudnn'            Check for a properly configured cuDNN install on the
%                      host machine.
%
%   'quiet'            This option will suppress all printing and
%                      error/warning generation. Instead it will silently
%                      process the checks and return the results.
%
%   See also gpuDevice, gpuDeviceCount, codegen, setenv, getenv.

%
%   Copyright 2017 The MathWorks, Inc.
%   
    try
        [results] = gpucoder.internal.system.checkGpuInstallPrivate(varargin{:});
    catch e
        throw(e);
    end

end