function system = getSystemForConversion(this)
% GETSYSTEMFORCONVERSION Returns the SUD

% Copyright 2015-2016 The MathWorks, Inc.

    system = '';
    % FPT instance was not initiated via launching the UI where a
    % SUD is selected, but created in a unit testing environment
    if isempty(this.GoalSpecifier)
        system = this.Model;
    else
        systemObj = this.GoalSpecifier.getSystemForConversion;
        if ~isempty(systemObj)
            system = systemObj.getFullName;
        end
    end
end
