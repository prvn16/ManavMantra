function addpref(group,pref,value)
%ADDPREF Add preference.
%   ADDPREF('GROUP','PREF',VAL) creates the preference specified by
%   GROUP and PREF and sets its value to VAL.  It is an error to add a
%   preference that already exists.
%
%   GROUP labels a related collection of preferences.  You can choose
%   any name that is a legal variable name, and is descriptive enough
%   to be unique, e.g. 'MathWorks_GUIDE_ApplicationPrefs'.
%
%   PREF identifies an individual preference in that group, and
%   must be a legal variable name.
%
%   ADDPREF('GROUP',{'PREF1','PREF2',...'PREFn'},{VAL1,VAL2,...VALn})
%   creates the preferences specified by the cell array of names,
%   setting each to the corresponding value.
%
%   Preference values are persistent and maintain their values between
%   MATLAB sessions.  Where they are stored is system dependent.
%
%   Example:
%      addpref('mytoolbox','version',1.0)
%
%   See also GETPREF, SETPREF, RMPREF, ISPREF.

%   Copyright 1984-2005 The MathWorks, Inc.

if nargin > 0
    group = convertStringsToChars(group);
end

if nargin > 1
    pref = convertStringsToChars(pref);
end

if nargin > 2
    value = convertStringsToChars(value);
end

if any(ispref(group, pref))
  error(message('MATLAB:addpref:PreferenceAlreadyExists'));
end

setpref(group, pref, value);
