function setResultSetForSource(this, source, resultSet)
    % Adds an associated between the group of results and its source.
    % Copyright 2016 The MathWorks, Inc.
    
    if(~isequal(3, nargin) || isempty(resultSet)) || isempty(source)
        [msg, id] = fxptui.message('setblklist4srcInValidInputArgs');
        error(id, msg);
    end
    this.ResultSetForSourceMap.insert(source.UniqueKey, resultSet);
end

% LocalWords:  setblklist