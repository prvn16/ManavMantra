function delete(this)
    % DELETE Class destructor
    
    %   Copyright 2012-2016 The MathWorks, Inc.
    
    this.clearResultsInRuns();
    
    this.RunNameObjMap.Clear;
    this.RunNameTsIDMap.Clear;
end




