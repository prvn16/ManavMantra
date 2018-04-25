function b = hasResults(this)
    % HASRESULTS Returns true if the run contains results.
    
    %    Copyright 2012-2017 The MathWorks, Inc.
    
    b = this.DataStorage.Count > 0;
end