function createFunctionSignatureQuery( className, parameterName, varargin )
    %CREATEFUNCTIONSIGNATUREQUERY Create a query function for given
    %class
    % The query function would be named as ['query', functionName,
    % parameterName,'.m'] that queries the parameter value corresponds to
    % the parameter name for a specific function
    %
    % createFunctionSignatureQuery(className,parameterName) generates the
    % query function in
    % matlabroot/toolbox/fixedpoint/fixedpoint/+FixedpointFunctionSignatures 
    %
    % createFunctionSignatureQuery(className,parameterName, outputDir)
    % generates the query function in the directory specified by outputDir
    
    
    % Copyright 2017 The MathWorks, Inc.
    
    queryFunctionName = ['query', className, parameterName];
    
    narginchk(2,3);
    
    if nargin == 2
        outputFilePath = fullfile(matlabroot,'toolbox','fixedpoint','fixedpoint','+FixedpointFunctionSignatures');
    else
        outputFilePath = varargin{1};
    end
    
    outputFile = fopen(fullfile(outputFilePath,[queryFunctionName, '.m']), 'w');
    
    % write function header
    fprintf(outputFile, 'function output = %s()\n', queryFunctionName);
    fprintf(outputFile, '    %%%s query function for parameter %s in function %s\n\n', ...
    queryFunctionName, parameterName, className);
    
    % write function copyright
    fprintf(outputFile, '    %% Copyright 2017 The MathWorks, Inc.\n\n');
    
    % write function body
    prototype = eval(className);
    setQuery = set(prototype);
    parameterValues = setQuery.(parameterName);
    
    fprintf(outputFile, '    output={');
    if numel(parameterValues) > 0
        fprintf(outputFile, '''%s''', parameterValues{1});
    end
    if numel(parameterValues) > 1
        for value = parameterValues(2:end)
            fprintf(outputFile, ',''%s''', value{:});
        end
    end
    fprintf(outputFile, '};\n');
    
    % write function end
    fprintf(outputFile, 'end\n');
    
    fclose(outputFile);
end

