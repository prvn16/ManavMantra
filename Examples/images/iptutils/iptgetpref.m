function value = iptgetpref(prefName)
%IPTGETPREF Get value of Image Processing Toolbox preference.
%   PREFS = IPTGETPREF without an input argument returns a structure
%   containing all the Image Processing Toolbox preferences with their
%   current values.  Each field in the structure has the name of an Image
%   Processing Toolbox preference.  See IPTSETPREF for a list.
%
%   VALUE = IPTGETPREF(PREFNAME) returns the value of the Image Processing
%   Toolbox preference specified by the string or character vector
%   PREFNAME.  See IPTSETPREF for a complete list of valid preference
%   names.  Preference names are not case-sensitive and can be abbreviated.
%
%   Example
%   -------
%       value = iptgetpref('ImshowAxesVisible')
%
%   See also IMSHOW, IPTSETPREF.

%   Copyright 1993-2017 The MathWorks, Inc.

s = settings;

% Get IPT factory preference settings
factoryPrefs = iptprefsinfo;
allNames = factoryPrefs(:,1);
allNames = [allNames{:}];

value = [];
if nargin == 0
    % Display all current preference settings
    for k = 1:length(allNames)
        thisField = allNames{k};
        value.(thisField) = iptgetpref(thisField);
    end
    
else
    % Return specified preferences
    prefName = matlab.images.internal.stringToChar(prefName);
    validateattributes(prefName,{'char'},{},mfilename,'PREFNAME');
    preference = validatestring(prefName,allNames,mfilename,'PREFNAME');
    
    % Handle the mixed-data-type magnification preferences first
    switch (preference)
        case 'ImshowInitialMagnification'
            value = getInitialMag(s.matlab,'imshow');
        case 'ImtoolInitialMagnification'
            value = getInitialMag(s.images,'imtool');
        case 'ImtoolStartWithOverview'
            value = s.images.imtool.OpenOverview.ActiveValue;
        case 'UseIPPL'
            value = s.images.UseIPPL.ActiveValue;
        case 'VolumeViewerUseHardware'
            value = s.images.volumeviewertool.useHardwareOpenGL.ActiveValue;
        case 'ImshowAxesVisible'
            if s.matlab.imshow.ShowAxes.ActiveValue
                value = 'on';
            else
                value = 'off';
            end
        case 'ImshowBorder'
            value = s.matlab.imshow.BorderStyle.ActiveValue;
        otherwise
            
    end
end




function mag = getInitialMag(s,fun)
% Helper function to simplify the mixed type preferences

style = s.(fun).InitialMagnificationStyle.ActiveValue;
if strcmp(style,'numeric')
    mag = s.(fun).InitialMagnification.ActiveValue;
else
    mag = style;
end
