function [profiles, descriptions] = iccfind(directory, pattern)
%ICCFIND   Search for ICC profiles by description.
%   [PROFILES, DESCRIPTIONS] = ICCFIND(DIRECTORY, PATTERN) searches for all
%   of the ICC profiles in the specified DIRECTORY with a given PATTERN in
%   their Description fields.  PROFILES is a cell array of profile
%   structures.  DESCRIPTIONS is a cell array of matching Description
%   fields.  ICCFIND performs case-insensitive pattern matching.
%
%   [PROFILES, DESCRIPTIONS] = ICCFIND(DIRECTORY) returns all of the
%   profiles and their descriptions for the given directory.
%
%   Note:
%
%      To improve performance, ICCFIND caches copies of the ICC profiles in
%      memory.  Adding or modifying profiles may not change the results of
%      ICCFIND.  Issuing the "clear functions" command will clear the
%      cache.
%
%   Examples:
%
%      % (1) Get all of the ICC profiles in the default location.
%      profiles = iccfind(iccroot);
%
%      % (2) Find the profiles whose descriptions contain "RGB".
%      [profiles, descriptions] = iccfind(iccroot, 'rgb');
%
%   See also ICCREAD, ICCROOT, ICCWRITE.

%   Copyright 1993-2015 The MathWorks, Inc.

% Get all of the profiles from the specified directory.
allProfiles = iccProfileCache(directory);
allDescriptions = getDescriptions(allProfiles);

% If no pattern was given, return all profiles.
if (nargin == 1)
    
    profiles = allProfiles;
    descriptions = allDescriptions;
    return
    
end

% Find all of the profiles with the given pattern in their description.
matchIndices = strfind(lower(allDescriptions), lower(pattern));

descriptions = {};
profiles = {};
for idx = 1:numel(matchIndices)
    
    if (~isempty(matchIndices{idx}))
        
        % Store matching profiles in the output.
        descriptions{end + 1} = allDescriptions{idx};
        profiles{end + 1} = allProfiles{idx};
        
    end
    
end

% For readability return a columnar cell array.
descriptions = descriptions';
profiles = profiles';



function allDescriptions = getDescriptions(allProfiles)
%getDescriptions   Return a cell array of the profiles' descriptions.

allDescriptions = cell(numel(allProfiles), 1);
for idx = 1:numel(allProfiles)
    
    allDescriptions{idx} = allProfiles{idx}.Description.String;
    
end
