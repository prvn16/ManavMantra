function createFimathParamterValuesQueryFunctions(varargin)
    %% createFimathParamterValuesQueryFunctions create query functions for fimath
    %
    % createFimathParamterValuesQueryFunctions() generates query function
    % in 
    % matlabroot/toolbox/fixedpoint/fixedpoint/+FixedpointFunctionSignatures
    %
    % createFimathParamterValuesQueryFunctions(outputDir) generates query
    % function to the output directory specified by outputDir
    
    % Copyright 2017 The MathWorks, Inc.
    
    narginchk(0,1);
    
    FixedpointFunctionSignatures.createFunctionSignatureQuery('fimath','RoundingMethod',varargin{:});
    FixedpointFunctionSignatures.createFunctionSignatureQuery('fimath','OverflowAction',varargin{:});
    FixedpointFunctionSignatures.createFunctionSignatureQuery('fimath','ProductMode',varargin{:});
    FixedpointFunctionSignatures.createFunctionSignatureQuery('fimath','SumMode',varargin{:});
    
end
