function tzTable = timezones(area)
% TIMEZONES List all time zones for use by datetimes.
%   T = TIMEZONES returns a table listing all the IANA time zones accepted by
%   DATETIME, including their offset from UTC (in hours, east is positive) and
%   their Daylight Saving Time shift (in hours).
%
%   T = TIMEZONES(AREA) returns a table listing all the IANA time zones in AREA.
%   AREA is one of the following: 'Africa', 'America', 'Antarctica', 'Arctic',
%   'Asia', 'Atlantic', 'Australia', 'Etc', 'Europe', 'Indian', 'Pacific', or
%   'All'.
%
%   See also DATETIME, datetime.TimeZone.

%   Copyright 2015-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if nargin > 0
    area = matlab.internal.datatypes.stringToLegacyText(area);
end

t = datetime.allTimeZones();
areas = {'Africa' 'America' 'Antarctica' 'Arctic' 'Asia' 'Atlantic' 'Australia' 'Etc' 'Europe' 'Indian' 'Pacific'};
t.Area = categorical(strtok(t.Name,'/'),areas);
if nargin == 0 || strcmpi(area,'All')
    t.Properties.Description = getString(message('MATLAB:datetime:uistrings:TZTableAllCaption'));
    j = ~isundefined(t.Area);
elseif isCharString(area) && any(strcmpi(area,areas))
    area = areas{strcmpi(area,areas)}; % correct capitalization
    t.Properties.Description = getString(message('MATLAB:datetime:uistrings:TZTableCaption',area));
    j = (t.Area == area);
else
    error(message('MATLAB:datetime:InvalidTZArea'));
end
t = t(j & strcmp(t.Name,t.CanonicalName),[1 5 3 4]);
t.Properties.VariableUnits = {'' '' getString(message('MATLAB:datetime:uistrings:TZPropertiesUTCOffsetUnit')) getString(message('MATLAB:datetime:uistrings:TZPropertiesDSTOffsetUnit'))};
if nargout == 0
    web(table2html(t));
else
    tzTable = t;
end


function theHTML = table2html(t)
sorttablePath = ['file:' strrep(matlabroot,'\','/') '/toolbox/shared/comparisons/private/sorttable.js'];
numPreDataLines = 11;
theHTML = cell(1,numPreDataLines+height(t)+2); % two lines of closing tags
theHTML{1} = ['text://<html><head><title>' t.Properties.Description '</title>'];
theHTML{2} = '<style type="text/css">table {border-collapse:collapse; border:3px solid black; margin-left:5%; width:90%}';
theHTML{3} = 'caption {padding:3px; font-weight:bold;}';
theHTML{4} = 'th {border:2px solid black; padding:3px; background:#eee;}';
theHTML{5} = 'td {border:2px solid black; padding:3px;}</style>';
theHTML{6} = ['<script src="' sorttablePath '" type="text/javascript"></script></head>'];
theHTML{7} = '<body>';
theHTML{8} = getString(message('MATLAB:datetime:uistrings:TZMoreInfoDoc'));
theHTML{9} = ['<p><table class="sortable"><caption>' t.Properties.Description '</caption>'];
theHTML{10} = ['<thead><tr> <th class="sorttable_alpha">' getString(message('MATLAB:datetime:uistrings:TZNameHeader')) '</th> ' ...
    '<th class="sorttable_generalnumeric">' getString(message('MATLAB:datetime:uistrings:UTCOffsetHeader1')) ...
    '<br>' getString(message('MATLAB:datetime:uistrings:UTCOffsetHeader2')) '</th> ' ...
    '<th class="sorttable_generalnumeric">' getString(message('MATLAB:datetime:uistrings:DSTOffsetHeader1')) ...
    '<br>' getString(message('MATLAB:datetime:uistrings:DSTOffsetHeader2')) '</th> </tr></thead>'];
theHTML{11} = '<tbody>';
for i = 1:height(t)
    theHTML{numPreDataLines+i} = sprintf('<tr> <td>%s</td> <td>%g</td> <td>%g</td> </tr>', ...
        strrep(t.Name{i},'/','&#47;'),t.UTCOffset(i),t.DSTOffset(i));
end
theHTML{end-1} = '</tbody></table>';
theHTML{end}   = '</body></html>';
theHTML = strjoin(theHTML,'\n');
