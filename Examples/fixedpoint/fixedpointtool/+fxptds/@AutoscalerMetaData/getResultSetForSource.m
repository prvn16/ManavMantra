function resultSet = getResultSetForSource(this, source)
    % getResultSetForSource(metaData, source) retrieves the results that
    % come from subystem described in source
    % Copyright 2016 The MathWorks, Inc.
    if(~isequal(2, nargin) || isempty(source) )
        [msg, id] = fxptui.message('blklist4srcInValidInputArgs');
        error(id, msg);
    end
    key = source.UniqueKey;
    if this.ResultSetForSourceMap.isKey(key)
        resultSet = this.ResultSetForSourceMap.getDataByKey(key);
    else
        resultSet = containers.Map();
    end
end
% LocalWords:  blklist