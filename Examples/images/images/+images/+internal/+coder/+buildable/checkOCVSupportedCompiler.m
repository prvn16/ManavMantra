function [isCompilerOK, systemCompilerSetup, compilerOCVbuiltWith] = checkOCVSupportedCompiler(thisArch)
% checkOCVSupportedCompiler(thisArch) determines if functions that depend
% on openCV can generate code based on the compilers that openCV is
% internally built on. It errors for desktop targets when unsupported
% compilers (like minGW) is used, and for mexOpenCV (openCV support
% package) re-uses this internal function for the same purpose.
%
% Copyright 2017 The MathWorks, Inc.

compilerForMex = mex.getCompilerConfigurations('C','selected');

isCompilerOK = true;

% this list of compilers that are supported is current as of R2017b.
if strcmp(thisArch, 'glnxa64')
    isCompilerOK = ~isempty(strfind(compilerForMex.Name,'gcc'));
    compilerOCVbuiltWith = 'gcc-4.9.3';

elseif strcmp(thisArch, 'maci64')
    isCompilerOK = ~isempty(strfind(compilerForMex.Name,'Xcode with Clang'));
    compilerOCVbuiltWith = 'Xcode 6.2.0';

elseif strcmp(thisArch, 'win64')
    isCompilerOK = ~isempty(strfind(compilerForMex.Name,'Microsoft Visual C++ 2015')) && ...
        (~isempty(strfind(compilerForMex.Location,'Microsoft Visual Studio 14.0')) || ...
         ~isempty(strfind(compilerForMex.Details.CompilerExecutable,'Microsoft Visual Studio 14.0')));
    compilerOCVbuiltWith = 'Microsoft Visual C++ 2015';

end

systemCompilerSetup = compilerForMex.Name;
end
