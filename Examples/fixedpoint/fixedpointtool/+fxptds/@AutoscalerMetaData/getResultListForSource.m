function resList = getResultListForSource(this, source)
    % Gets the list of results associated with the specified source.
    % Copyright 2016 The MathWorks, Inc.
    
    if(~isequal(2, nargin) || isempty(source) )
        [msg, id] = fxptui.message('blklist4srcInValidInputArgs');
        error(id, msg);
    end
    
    list = [];
    resSet = getResultSetForSource(this, source);
    if ~isempty(resSet)
        cellList = resSet.values;
        list = [cellList{:}];
    end
    
    % initialize the list array for improved performance. Initialize them with
    % fxptui.simresult as they are most common.
    if ~isempty(list)
        resList(1:numel(list)) = fxptds.BlockResult;
    else
        resList = [];
        return;
    end
    cntr = 1;
    for idx = 1:numel(list)
        res = list(idx);
        % The result could be invalid i.e., referring to a non-existing element.
        if ~isempty(res) && fxptds.isResultValid(res)
            resList(cntr) = res;
            cntr = cntr+1;
        end
    end
    %Delete excess memory locations.
    resList(cntr:end) = [];
end
% LocalWords:  blklist