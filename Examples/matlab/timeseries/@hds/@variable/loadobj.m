function this = loadobj(SavedData)
% LOAD method for @variable class

%   Copyright 1986-2005 The MathWorks, Inc.

% Fetch variable with same name from variable manager
% (ensures unique handle for each var name)
if ischar(SavedData)
   varname = SavedData;
else
   % Pre R14sp3 save format
   varname = SavedData.Name;
end
this = hds.variable;
this.Name = varname;
