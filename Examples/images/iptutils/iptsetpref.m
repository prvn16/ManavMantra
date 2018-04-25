function varargout = iptsetpref(prefName, value)
%IPTSETPREF Set value of Image Processing Toolbox preference.
%   IPTSETPREF(PREFNAME) displays the valid values for the Image
%   Processing Toolbox preference specified by PREFNAME.
%
%   IPTSETPREF(PREFNAME,VALUE) sets the Image Processing Toolbox preference
%   specified by the string PREFNAME to the value specified by VALUE.
%
%   Preference names are case insensitive and can be abbreviated. The
%   default value is enclosed in braces ({}).
%
%   The following preference values can be set:
%
%   'ImshowBorder'        {'loose'} or 'tight'
%
%        Controls whether IMSHOW includes a border around the image in
%        the figure window. Possible values:
%
%        'loose' -- Include a border between the image and the edges of
%                   the figure window, thus leaving room for axes labels,
%                   titles, etc.
%
%        'tight' -- Adjust the figure size so that the image entirely
%                   fills the figure.
%
%        Note: There can still be a border if the image is very small, or
%        if there are other objects besides the image and its axes in the figure.
%
%   'ImshowAxesVisible'   'on' or {'off'}
%
%        Controls whether IMSHOW displays images with the axes box and
%        tick labels. Possible values:
%
%        'on'  -- Include axes box and tick labels.
%
%        'off' -- Do not include axes box and tick labels.
%
%   'ImshowInitialMagnification'   {100}, any numeric value, or 'fit'
%
%        Controls the initial magnification of the image displayed by
%        IMSHOW. Possible values:
%
%        Any numeric value -- IMSHOW interprets numeric values as a
%                             percentage. The default value is 100. One
%                             hundred percent magnification means that
%                             there should be one screen pixel for every
%                             image pixel.
%
%        'fit'             -- Scale the image so that it fits into the
%                             window in its entirety.
%
%        You can override this preference by specifying the
%        'InitialMagnification' parameter when you call IMSHOW, or by
%        calling the TRUESIZE function manually after displaying the image.
%
%   'ImtoolInitialMagnification'   {'adaptive'}, any numeric value, or 'fit
%
%        Controls the initial magnification of the image displayed by
%        IMTOOL. Possible values:
%
%        'adaptive'        -- Display the entire image. If the image is
%                             too large to display on the screen at 100%,
%                             display the image at the largest
%                             magnification that fits on the screen.
%
%        Any numeric value -- IMTOOL interprets numeric values as a
%                             percentage. One hundred percent
%                             magnification means that there should be
%                             one screen pixel for every image pixel.
%
%        'fit'             -- Scale the image so that it fits into the
%                             window in its entirety.
%
%        You can override this preference by specifying the
%        'InitialMagnification' parameter when you call IMTOOL.
%
%   'ImtoolStartWithOverview'    true or {false}
%
%       Controls whether the Overview tool opens by default when viewing
%       an image in the Image Tool (IMTOOL).
%
%       true               -- Open the Overview tool when the Image Tool
%                             starts.
%
%       false              -- Do not open the Overview tool when the Image
%                             Tool starts.
%
%   'UseIPPL'              {true} or false
%
%       Controls whether some toolbox functions use hardware optimization
%       or not.  Possible values:
%
%       true               -- Enable hardware optimization.
%
%       false              -- Disable hardware optimization.
%
%       NOTE: Setting this preference value has the side effect of clearing
%       all loaded MEX-files.
%
%   'VolumeViewerUseHardware'   {true} or false
%
%       Controls whether the volumeViewer app uses OpenGL shaders on the
%       local graphics hardware to optimize volume rendering. Possible
%       values:
%
%       true               -- Enable hardware optimization.
%
%       false              -- Disable hardware optimization.
%
%       NOTE: Setting this preference to false has the side effect of
%       removing certain functionality from the app and will drastically
%       slow down rendering performance. This preference should only be set
%       to false in technical support scenarios to resolve problems with
%       graphics drivers.
%
%   Example
%   -------
%       iptsetpref('ImshowBorder', 'tight')
%
%   See also IMSHOW, IPTGETPREF, TRUESIZE.

%   Copyright 1993-2017 The MathWorks, Inc.

s = settings;


prefName = matlab.images.internal.stringToChar(prefName);


validateattributes(prefName,{'char'},{},mfilename,'PREFNAME')

% Get factory IPT preference settings.
factoryPrefs = iptprefsinfo;
allNames = factoryPrefs(:,1);

validPrefs = [allNames{:}];
preference = validatestring(prefName,validPrefs,mfilename,'PREFNAME');
matchTF = strcmp(preference,validPrefs);

allowedValues = factoryPrefs{matchTF, 2};

if nargin == 1
    if nargout == 0
        % Print possible settings
        defaultValue = factoryPrefs{matchTF, 3};
        if isempty(allowedValues)
            str = getString(message('images:iptsetpref:hasNoFixedValues',preference));
            fprintf('%s\n',str);
        else
            fprintf('[');
            for k = 1:length(allowedValues)
                thisValue = allowedValues{k};
                isDefault = ~isempty(defaultValue) & ...
                    isequal(defaultValue{1}, thisValue);
                if (isDefault)
                    fprintf(' {%s} ', num2str(thisValue));
                else
                    fprintf(' %s ', num2str(thisValue));
                end
                notLast = k ~= length(allowedValues);
                if (notLast)
                    fprintf('|');
                end
            end
            fprintf(']\n');
        end
        
    else
        % Return possible values as cell array.
        varargout{1} = factoryPrefs{matchTF,2};
    end
    
elseif ~isempty(preference)
    % Syntax: IPTSETPREF(PREFNAME,VALUE)
    
    value = matlab.images.internal.stringToChar(value);
    
    if strcmpi(preference,'ImshowInitialMagnification')
        value = images.internal.checkInitialMagnification(value,{'fit'},mfilename,...
            'VALUE',2);
        setInitialMag(s.matlab,'imshow',value);
        
    elseif strcmpi(preference,'ImtoolInitialMagnification')
        value = images.internal.checkInitialMagnification(value,{'fit','adaptive'},...
            mfilename,'VALUE',2);
        setInitialMag(s.images,'imtool',value);
        
    elseif strcmpi(preference,'ImtoolStartWithOverview')
        validateattributes(value, {'logical', 'numeric'}, {'scalar'}, ...
            mfilename, 'VALUE',2);
        value = value ~= 0;
        s.images.imtool.OpenOverview.PersonalValue = value;
        
    elseif strcmpi(preference,'VolumeViewerUseHardware')
        validateattributes(value, {'logical', 'numeric'}, {'scalar'}, ...
            mfilename, 'VALUE',2);
        value = value ~= 0;
        s.images.volumeviewertool.useHardwareOpenGL.PersonalValue = value;
        
    elseif strcmpi(preference,'UseIPPL')
        validateattributes(value, {'logical', 'numeric'}, {'scalar'}, ...
            mfilename, 'VALUE',2);
        
        % Clear MEX-files so that the next time an IPPL MEX-file loads
        % it'll check this preference again.
        clear mex %#ok<CLMEX>
        
        % Some functions cache the Java preference 'UseIPPL' as persistent
        % state to avoid hitting the java perferences in each call. Clear
        % this persistent state if the preference for UseIPPL is changed.
        functionList = images.internal.functionsThatCacheIPPPref();
        clear(functionList{:});
        
        % convert to logical
        value = value ~= 0;
        s.images.UseIPPL.PersonalValue = value;
        
    elseif strcmpi(preference,'ImshowAxesVisible')
        value = validatestring(value,allowedValues,mfilename,'VALUE',2);
        % convert to logical
        value = strcmpi(value,'on');
        s.matlab.imshow.ShowAxes.PersonalValue = value;
        
    elseif strcmpi(preference,'ImshowBorder')
        value = validatestring(value,allowedValues,mfilename,'VALUE',2);
        s.matlab.imshow.BorderStyle.PersonalValue = value;
    end
    
end


function setInitialMag(s,fun,value)
% Helper function to simplify the mixed type preferences

if isnumeric(value)
    s.(fun).InitialMagnificationStyle.PersonalValue = 'numeric';
    s.(fun).InitialMagnification.PersonalValue = value;
else
    s.(fun).InitialMagnificationStyle.PersonalValue = value;
end
