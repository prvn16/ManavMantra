function updateSourceName(this, newSourceName)
%% UPDATESOURCENAME function updates the source name of the dataset

%   Copyright 2016 The MathWorks, Inc.

    this.Source = newSourceName;
    runNames = getAllRunNames(this);
    if ~isempty(runNames)
        for idx = 1:numel(runNames)
          run = runNames{idx};
          if this.RunNameObjMap.isKey(run)
              runObj = this.RunNameObjMap.getDataByKey(run);
              if runObj.isvalid
                  runObj.setSource(newSourceName);
              end
          end
        end
    end
end