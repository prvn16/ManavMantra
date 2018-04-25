function [results,defaults] = parseGroupPropertyValues(varargin)
% Parse the name/value pairs associated with creating a group

%   Copyright 2015-2018 The MathWorks, Inc.

    persistent propGroupValueParser;
    if(isempty(propGroupValueParser))
        propGroupValueParser = inputParser;
        % add required input groupName
        propGroupValueParser.addRequired('Name', @isvarname);
        % add optional Property-Value pairs to inputParser
        propGroupValueParser.addParameter('Hidden', false, @islogical);        
        propGroupValueParser.addParameter('ValidationFcn', []);   
    end
    propGroupValueParser.parse(varargin{:}{:});
    results  = propGroupValueParser.Results;
    results.Name = char(results.Name);
    assert(isscalar(results.Hidden), message('MATLAB:settings:LogicalScalarHidden'));   
    
    defaults = cell2struct(cell([1 numel(fields(results))]),fieldnames(results),2);
    def_fieldnames = propGroupValueParser.UsingDefaults;

    % Set the field of defaults to true if it is included in propGroupValueParser.UsingDefaults
    for i=1:numel(def_fieldnames)
        defaults.(def_fieldnames{i}) = true;
    end
    
    % Set the field of defaults to false if not included in propGroupValueParser.UsingDefaults
    idx = structfun(@(x)isempty(x),defaults);
    def_fieldnames = fieldnames(defaults);
    
    for i=1:numel(def_fieldnames)
        if(idx(i))
            defaults.(def_fieldnames{i}) = false;
        end
    end
end
