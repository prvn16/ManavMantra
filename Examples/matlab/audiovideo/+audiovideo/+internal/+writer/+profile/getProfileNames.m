function profileNames = getProfileNames()
% GETPROFILENAMES returns the names of VideoWriter profiles supported on
% the current platform. This is used by the tab-completion infrastructure
% to generate the list of formats supported.

% Copyright 2017 The MathWorks, Inc.

prof = VideoWriter.getProfiles;
profileNames = {prof.Name}';