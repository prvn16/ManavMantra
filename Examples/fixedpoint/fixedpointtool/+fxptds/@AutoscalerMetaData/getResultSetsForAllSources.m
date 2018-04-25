function resStruc = getResultSetsForAllSources(this)
    % Gets the result list for all sources in the map
    % Copyright 2016 The MathWorks, Inc.
    
    resStruc = [];
    for i = 1:this.ResultSetForSourceMap.getCount
        source = this.ResultSetForSourceMap.getKeyByIndex(i);
        resStruc(i).Handle = source; %#ok<AGROW>
        resStruc(i).ResultSet = this.ResultSetForSourceMap.getDataByIndex(i); %#ok<AGROW>
    end
end