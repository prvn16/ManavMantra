function str = getParameterNameString(params, leftBracket, rightBracket)

% Copyright 2016 The MathWorks, Inc.

if isempty(params)
    str = '';
    return;
end

propNames = {params.Property};
paramNames = {params.Name};

numParams = numel(propNames);
propAndParamNames = cell(1,numParams);
for idx = 1:numParams
    propAndParamNames{idx} = [propNames{idx} '=' paramNames{idx}];
end

str = [leftBracket, strjoin(propAndParamNames,','), rightBracket];
end
