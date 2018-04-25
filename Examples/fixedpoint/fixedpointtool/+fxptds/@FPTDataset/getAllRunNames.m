function runNames = getAllRunNames(this)
    % GETRUNNAMES return all the run names in the dataset
    
    %    Copyright 2012-2017 The MathWorks, Inc.
    
    runNames = {''};
    cnt = 1;
    for i = 1:this.RunNameObjMap.getCount
        runObj = this.RunNameObjMap.getDataByIndex(i);
        if runObj.isvalid
            currentRunName = this.RunNameObjMap.getKeyByIndex(i);

            % NOTE: filter out D2S_Run_Collector_Internal_Run_Name that is
            % specifically tied to double to single conversion. See: g1381623
            if isempty(regexpi(currentRunName, '^D2S_Run_Collector_Internal_Run_Name$'))
                runNames{cnt} = currentRunName;
                cnt=cnt+1;
            end
        end
    end
end