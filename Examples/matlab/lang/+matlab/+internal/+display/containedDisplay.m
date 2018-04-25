function out = containedDisplay(data, width, varargin)
    % This function returns the contained representation of the input data,
    % in the specified width. The data can be any valid datatype in MATLAB.
    % It returns a string, which is a representation of the contained
    % display, for the given data. The returned string is non-empty only if
    % the data has a contained representation thet can be fit in the given
    % width
    %
    % In also takes in a set of optional Name-Value pairs that provide 
    % additional information for processing the data. These additional 
    % inputs are:
    %
    % 'Format': This specifies the numeric display format. It can be one of
    % these - +, bank, hex, long, longE, longEng, longG, rat short, shortE,
    % shortEng, shortG. The default is the current format.
    %
    % 'CommaDelimiter' - This is a boolean flag which represents the
    % delimiter added between row elements of the data. If it is true, we
    % add commas to delineate the elements in a row vector and we do not
    % add any padding spaces. If it is false, we add space to delineate the
    % elements in a row vector and we pad 4 of them. The defautl value is
    % false
    
    % Validate input arguments
    narginchk(2,6);
    
    % Validate width
    isValidWidth(width);
    
    p = inputParser;   
    defaultCommaDelimiter = false;  
    defaultFormat = get(0, 'format'); 
    addParameter(p, 'CommaDelimiter', defaultCommaDelimiter, @isscalar);   
    addParameter(p, 'Format', defaultFormat, @isCharOrString);
    
    parse(p, varargin{:});
    processed_results = processStringInputs(p.Results); 
    
    % Convert ScalarOutput to logical
    processed_results.CommaDelimiter = logical(processed_results.CommaDelimiter);
    
    out = matlab.internal.display.containedDisplayHelper(...
        data, width, processed_results);
end

function results = processStringInputs(results)
    fieldnames = fields(results);
    for i=1:numel(fieldnames)
        if isstring(results.(fieldnames{i}))
            results.(fieldnames{i}) = results.(fieldnames{i}).char;
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

function isValidWidth(inp)
    % Input must be numeric
    if ~isnumeric(inp)
        error('MATLAB:class:RequireNumeric', message('MATLAB:class:RequireNumeric').getString());
    end
    
    % Input must be scalar
    if ~isscalar(inp)
        error('MATLAB:class:RequireScalar', message('MATLAB:class:RequireScalar').getString());
    end 
    
    % Input must not be complex
    if ~isreal(inp)
        error('MATLAB:validators:mustBeReal', message('MATLAB:validators:mustBeReal').getString());
    end
    
    % Input must be finite
    if isinf(inp)
        error('MATLAB:validators:mustBeFinite', message('MATLAB:validators:mustBeFinite').getString());
    end    
    
    % Input must not be nan
    if isnan(inp)
        error('MATLAB:validators:mustBeNonNan', message('MATLAB:validators:mustBeNonNan').getString());
    end
    
    % Must be positive
    if inp < 0
        error('MATLAB:validators:mustBePositive', message('MATLAB:validators:mustBePositive').getString());
    end
end