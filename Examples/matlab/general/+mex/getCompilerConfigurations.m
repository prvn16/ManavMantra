function  compConfig = getCompilerConfigurations( varargin )
% mex.getCompilerConfigurations lists compiler configuration information.
%   CC  = mex.getCompilerConfigurations() returns a mex.CompilerConfiguration
%   array containing information about the default compiler configurations 
%   used by MEX. There is one configuration for each supported language.
%
%   mex.CompilerConfiguration objects have the following properties:
%       Name:         a character vector describing the compiler
%       Manufacturer: a character vector with the manufacturer of the compiler
%       Language:     a character vector with the language of the compiler
%       Version:      a character vector describing the version of the compiler
%       Location:     a character vector pointing to root directory of the compiler
%       ShortName:    a character vector identifying the options file
%       Priority:     a character indicating the priority of this compiler
%       Details:      more specific information about the configuration 
%       LinkerName:   a character vector describing the linker
%       LinkerVersion: a character vector describing the version of the linker
%       MexOpt:       a character vector with the name and path to the options file
%
%
%   CC  = mex.getCompilerConfigurations(LANG) returns an array 
%   of mex.CompilerConfiguration objects CC containing information 
%   about the default compiler for language LANG.
%
%   LANG is a character vector for selecting a requested language. LANG can be 'Any',
%   'C', 'C++', 'CPP', or 'Fortran'.  The default value for LANG is 'Any'.
%
%   CC  = mex.getCompilerConfigurations(LANG,LIST) returns an 
%   array of mex.CompilerConfiguration objects CC containing 
%   information about configurations for LANG and LIST.
%
%   LIST is a character vector for selecting a set of configurations of interest.
%   LIST can be 'Selected', 'Installed', or 'Supported'. The default
%   value for LIST is 'Selected'. 
%
%   Example:
%     defaultC = mex.getCompilerConfigurations('C','Selected')
%     allC_CompConfs = mex.getCompilerConfigurations('C','Supported')
% 
% See also MEX

%   Copyright 2007-2016 The MathWorks, Inc. 
end

