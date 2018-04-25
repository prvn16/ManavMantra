function rmpref(group,pref)
%RMPREF Remove preference.
%   RMPREF('GROUP','PREF') removes the preference specified by GROUP
%   and PREF.  It is an error to remove a preference that does not
%   exist.
%
%   RMPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) removes each
%   preference specified in the cell array of names. It is an error
%   if any of the preferences do not exist.
%
%   RMPREF('GROUP') removes all the preferences for the specified
%   GROUP. It is an error to remove a group that does not exist.
%
%   Example:
%      addpref('mytoolbox','version',1.0)
%      rmpref('mytoolbox')
%
%   See also ADDPREF, GETPREF, SETPREF, ISPREF.

%   Copyright 1984-2015 MathWorks, Inc.

narginchk(1,2);

if nargin > 0
    group = convertStringsToChars(group);
end

if nargin > 1
    pref = convertStringsToChars(pref);
end

Preferences = prefutils('loadPrefs');

if nargin == 1
  if ~ispref(group)
    error(message('MATLAB:rmpref:GroupMustExist'));
  end
  Preferences = rmfield(Preferences, group);
else
  if any(~ispref(group, pref))
    error(message('MATLAB:rmpref:GroupAndPrefMustExist'));
  end
  pref = prefutils('checkAndConvertToCellVector',pref);
  Group = prefutils('getFieldRequired',Preferences,group);
  for i=1:length(pref)
    Group = rmfield(Group,pref{i});
  end
  Preferences.(group) = Group;
end

prefutils('savePrefs', Preferences);
    

