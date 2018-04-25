function pref_info = iptprefsinfo
%IPTPREFSINFO Image Processing Toolbox preference information.
%   IPTPREFSINFO returns a 3-column cell array containing information
%   about each Image Processing Toolbox preference.  Each row contains
%   information about a single preference.  
%   
%   The first column of each row contains a cell array with one element.
%   that indicates the current preference name.
%   
%   The second column of each row is a cell array containing the set of
%   acceptable values for that preference setting.  An empty cell array
%   indicates that the preference does not have a fixed set of values.
%
%   The third column of each row contains a single-element cell array
%   containing the default value for the preference.  An empy cell array
%   indicates that the preference does not have a default value.
%
%   See also IPTSETPREF, IPTGETPREF, IPTPREFS.

%   Copyright 2008-2016 The MathWorks, Inc.

pref_info = { ...
    {'ImshowBorder'},               {'tight'; 'loose'},         {'loose'}
    {'ImshowAxesVisible'},          {'on'; 'off'},              {'off'}
    {'ImshowInitialMagnification'}, {100; 'fit'},               {100}
    {'ImtoolStartWithOverview'},    {true; false},              {false}
    {'ImtoolInitialMagnification'}, {100; 'fit' ; 'adaptive' }, {'adaptive'}
    {'UseIPPL'},                    {true; false},              {true}
    {'VolumeViewerUseHardware'},    {true; false},              {true}
  };
