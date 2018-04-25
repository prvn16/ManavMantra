function [] = checkSupportedCodegenTarget(fileName) %#codegen
% For internal use only

% Error checking internal helper file
% for functions that support precompiled platform specific library only

% Copyright 2014 The MathWorks, Inc.

if ~coder.target('MATLAB')
  coder.internal.errorIf(~images.internal.coder.isCodegenForHost(), 'images:validate:unsupportedCodegenTarget', fileName)
end
