function directoryName = iccroot
%ICCROOT Find system ICC profile repository.
%   ROOTDIR = ICCROOT returns the system directory containing ICC profiles.
%   Additional profiles may be stored in other directories, but this is the
%   default location used by the color management system.
%
%   NOTE: Currently only Windows and Mac OS X platforms are supported.
%
%   Example:
%
%      % Return information on all of the profiles in the root directory.
%      iccfind(iccroot)
%
%   See also ICCFIND, ICCREAD, ICCWRITE.

%   Copyright 1993-2013 The MathWorks, Inc.

% Based on information in Fraser, Murphy, and Bunting's "Real World Color
% Management, 2nd ed." (2005).

if (ispc)
    
    % On Windows, system profiles are stored in the $WINDIR$\System or
    % $WINDIR$\System32 directories.
    winRoot = getenv('windir');
    
    possibleLocations = {'System32\Spool\Drivers\Color', ... % XP, 2000
                         'System32\Color', ...               % NT
                         'System\Color'};                    % 98, 98SE, ME
    
    % Look for each directory, reporting the first one found.
    for p = 1:numel(possibleLocations)
 
        if (isdir(fullfile(winRoot, possibleLocations{p})))
        
            directoryName = fullfile(winRoot, possibleLocations{p});
            return
            
        end
        
    end

else
  
  if (ismac)
    
    % On Mac OS X, a number of directories contain system profiles.  The
    % following are the most common, with the "all users" directory being
    % the most likely to contain profiles installed by applications and
    % hardware for common use.
    possibleLocations = {'/Library/ColorSync/Profiles', ...     % All users
                    '/System/Library/ColorSync/Profiles'}; % Mac OS X
    
    % Look for each directory, reporting the first one found.
    for p = 1:numel(possibleLocations)
      
      if (isdir(possibleLocations{p}))
        
        directoryName = possibleLocations{p};
        return
        
      end
      
    end
    
  end
  
end

% Unsupported platforms issue an error.
error(message('images:iccroot:unknownLocation'))
