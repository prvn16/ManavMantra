function requestedProfiles = iccProfileCache(requestedDir)
%iccProfileCache   Cache ICC profiles into memory, return in a cell array.
%
%   PROFILES = iccProfileCache(DIRECTORY) loads all of the valid ICC
%   profiles in the given DIRECTORY into a persistent memory cache and
%   returns the cache as a cell array in the PROFILES variable.
%
%   All profiles in the default ICC profiles repository as well as profiles
%   in the most recently queried directory are cached (but in separate
%   caches).

%   Copyright 1993-2012 The MathWorks, Inc.

% Keep track of the iccroot and last requested directory's profiles.
persistent currentProfiles iccrootProfiles lastDir

if ( (~isempty(currentProfiles)) && (isequal(requestedDir, lastDir)) )
    
    % Requesting the same profiles as the last query.
    requestedProfiles = currentProfiles;
    return
    
elseif ( (~isempty(iccrootProfiles)) && (isequal(requestedDir, iccroot)) )
    
    % Requesting the cached iccroot profiles.
    requestedProfiles = iccrootProfiles;
    return
    
end

% Build the cache of profiles.
d = dir(fullfile(requestedDir, '*.ic*'));
profileCount = numel(d);

requestedProfiles = cell(profileCount, 1);
hWait = createWaitbar(profileCount);

for idx = 1:profileCount
    
    try
        requestedProfiles{idx} = iccread(fullfile(requestedDir, d(idx).name));
    catch
        requestedProfiles{idx} = [];
    end
    
    updateWaitbar(hWait, idx ./ profileCount);
    
end

% Remove empty entries for invalid profiles.
requestedProfiles = cleanupEmpties(requestedProfiles);

% Clean up waitbar.
deleteWaitbar(hWait)

% Set persistent variables before exiting.
try
  
  if (isequal(requestedDir, iccroot))
    
    iccrootProfiles = requestedProfiles;
    
  end
  
catch
  
  iccrootProfiles = [];
  
end

currentProfiles = requestedProfiles;
lastDir = requestedDir;



%-------------------------------------------------------------------------
function hWait = createWaitbar(profileCount)

% For a small number of profiles don't display a waitbar.
if profileCount <= 10 || ~images.internal.isFigureAvailable()
    
    hWait = [];
    
else
    
    hWait = waitbar(0, getStaticText);

end



%-------------------------------------------------------------------------
function updateWaitbar(hWait, pct)

if (~isempty(hWait))
    
    waitbar(pct, hWait, sprintf('%s %d%%', getStaticText, round(100*pct)));

end



%-------------------------------------------------------------------------
function deleteWaitbar(hWait)

if (~isempty(hWait))
    
    delete(hWait)
    
end



%-------------------------------------------------------------------------
function titleStaticText = getStaticText

titleStaticText = getString(message('images:iccProfileCache:waitBarTitle'));



%-------------------------------------------------------------------------
function cleanedCells = cleanupEmpties(allCells)

empties = [];
for idx = 1:numel(allCells)
    
    if (isempty(allCells{idx}))
        
        empties(end + 1) = idx;
        
    end
    
end

cleanedCells = allCells;

if (~isempty(empties))
    
    cleanedCells(empties) = [];
    
end
