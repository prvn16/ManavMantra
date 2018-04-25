function varargout = numericDisplay(data, varargin)
    % This helper function is used to get the formatted display output for
    % the given numeric/logical data. It returns a couple of outputs:
    % 1) A string array representation of the display output. 
    % 2) The scaling factor for the given data
    %
    % This helper function only works with 2 dimensional data.
    % 
    % It takes in an additional optional input which corresponds to a
    % subset of the input data. If no value is specified, the input data is
    % used
    %
    % In also takes in a set of optional Name-Value pairs that provide 
    % additional information for processing the data. These additional 
    % inputs are:
    %
    % 'Format': This specifies the numeric display format. It can be one of
    % these - +, bank, hex, long, longE, longEng, longG, rat short, shortE,
    % shortEng, shortG. The default is the current format.
    %
    % 'ScalarOutput': This is a logical value. If this is set to true, the
    % output is returned as a 1x1 string array. Otherwise, the output is
    % returned as a string array which has the same dimensions as that of
    % the input. The default value is false.   
    
    % Validate input arguments
    narginchk(1,6);
    
    % Validate input
    isValidNumericData(data);
    
    p = inputParser;   
    defaultCompact = false;  
    defaultFormat = get(0, 'format');   
    
    addOptional(p, 'input_data_subset', data, @(x)isValidSubNumericData(x, data));
    addParameter(p, 'ScalarOutput', defaultCompact, @isscalar);   
    addParameter(p, 'Format', defaultFormat, @isCharOrString);
    
    parse(p, varargin{:});
    processed_results = processStringInputs(p.Results);    
    
    % Convert ScalarOutput to logical
    processed_results.ScalarOutput = logical(processed_results.ScalarOutput);
    
    [out, scale] = matlab.internal.display.numericDisplayHelper(data, ...
        processed_results.input_data_subset, ...
        processed_results);
    
    if (nargout == 0 || nargout ==1)
        varargout{1} = out;
    elseif nargout == 2
        varargout{1} = out;
        varargout{2} = scale;
    end
end

function results = processStringInputs(results)
    fieldnames = fields(results);
    for i=1:numel(fieldnames)
        if isstring(results.(fieldnames{i}))
            results.(fieldnames{i}) = results.(fieldnames{i}).char;
        end
    end
end

function isValidNumericData(data)
    if ~(isnumeric(data) || islogical(data))
        error('MATLAB:class:RequireNumeric', message('MATLAB:class:RequireNumeric').getString());
    end
    
     if numel(size(data)) > 2
         error('MATLAB:class:RequireNDims', message('MATLAB:class:RequireNDims', 2).getString());
     end
end

function isValidSubNumericData(data, superset_data)   
    
    isValidNumericData(data);
     
    if ~strcmp(class(data), class(superset_data))
        error('MATLAB:class:RequireClass', message('MATLAB:class:RequireClass', class(superset_data)).getString());
    end
    
    orig_data_sparseness = issparse(superset_data);
    orig_data_complexity = isreal(superset_data);
    sub_data_sparseness = issparse(data);
    sub_data_complexity = isreal(data);    
    
    if orig_data_sparseness ~= sub_data_sparseness
        if orig_data_sparseness
            error('MATLAB:services:printmat:mustBeSparse', message('MATLAB:services:printmat:mustBeSparse').getString());
        else
            error('MATLAB:class:RequireClass', message('MATLAB:class:RequireClass', class(superset_data)).getString());
        end         
    end
    
    if orig_data_complexity ~= sub_data_complexity
        if orig_data_complexity
            error('MATLAB:validators:mustBeReal', message('MATLAB:validators:mustBeReal').getString());
        else
            error('MATLAB:services:printmat:mustBeComplex', message('MATLAB:services:printmat:mustBeComplex').getString());            
        end        
    end
end

function isCharOrString(inp)
    % Only scalar strings
    if isstring(inp) && numel(inp) > 1
        error('MATLAB:class:RequireScalar', message('MATLAB:class:RequireScalar').getString());
    end
    
    if ~(ischar(inp) || isstring(inp))
        error('MATLAB:class:RequireClass', 'Value must be a char or a scalar string');
    end
end