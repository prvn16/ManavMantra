function cfgObj = gpuConfig(cfgType, varargin)
%CODER.GPUCONFIG Create a code generation configuration object
%
%   CODER.GPUCONFIG(OPTION) returns a CODEGEN configuration object.
%
%        OPTION   Returns               CODEGEN Output Type
%        'MEX'    coder.MexCodeConfig   MEX-function
%        'LIB'    coder.CodeConfig*     C/C++ Static Library
%        'DLL'    coder.CodeConfig*     C/C++ Dynamic Library
%        'EXE'    coder.CodeConfig*     C/C++ Executable
%        'SINGLE' coder.SingleConfig    Single Precision Conversion
%
%   Pass the object to CODEGEN using the -config option.  Set properties on
%   the configuration object to fine tune the code generation process.
%
%   *Note: If Embedded Coder is available, returns a 
%   coder.EmbeddedCodeConfig object instead.
%
%   CODER.GPUCONFIG is the same as CODER.GPUCONFIG('MEX').
%
%   CODER.GPUCONFIG(OPTION,'ECODER',FLAG) behaves like
%   CODER.GPUCONFIG(OPTION) except it explicitly enables Embedded Coder
%   features based on the value of FLAG (true or false).
%
%   See also CODEGEN, coder.MexCodeConfig, coder.CodeConfig,
%   coder.EmbeddedCodeConfig.

%   Copyright 2010-2017 The MathWorks, Inc.


    try 
        if nargin < 1
            cfgType = 'mex';
        end
        
        cfgTypes = {'mex','dll','lib','exe'};
        if ~any(strcmpi(cfgType, cfgTypes))
            error(message('gpucoder:validate:UnsupportedConfigType', cfgType));
        end
        
        cfgObj = coder.config(cfgType, varargin{:});
        cfgObj.GpuConfig = coder.gpu.config;
        cfgObj.GpuConfig.Enabled = true;
        gpucprivate('restoreToGpuCoderFactorySettings', cfgObj);
    catch e
        throw(e);
    end
end


