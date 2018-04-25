function resStruc = getResultListForAllSources(this)
    %Gets the result list for all sources in the map
    % Copyright 2016 The MathWorks, Inc.
    
    resStruc = [];
    for i = 1:this.ResultSetForSourceMap.getCount
        source = this.ResultSetForSourceMap.getKeyByIndex(i);
        resStruc(i).Handle = source; %#ok<AGROW>
        cellList = this.ResultSetForSourceMap.getDataByKey(source).values;
        resStruc(i).List = [cellList{:}]; %#ok<AGROW>
    end
end