function utDisplay(ts, showhtml)
% This undocumented function may be removed in a future release.

% Copyright 2017 The MathWorks, Inc.

% Call builtin display for arrays
if length(ts)~=1
    builtin('disp',ts);
    return
end

% Class name
mc = metaclass(ts);

if nargin>=2
    bHotLinks = showhtml && matlab.internal.display.isHot;
else
    bHotLinks = matlab.internal.display.isHot;
end
if bHotLinks
    fprintf('  <a href="matlab: help %s">%s</a>\n\n', mc.Name, mc.Name);
else
    fprintf('  %s\n\n', mc.Name);
end

% Duplicate times
if ts.hasduplicatetimes
    if bHotLinks
        % Create the helpview code to scroll to the Duplicate Times
        % remark on the timeseries reference page and embed it in the
        % hyperlink.
        doclink = sprintf('helpview(''%s/techdoc/helptargets.map'',''timeseries_dup_time'')',docroot);
        strTsContainsDuplicateTimesHref = getString(message('MATLAB:timeseries:display:TimeseriesContainsDuplicateTimesHref',doclink));
        fprintf('  %s\n\n', strTsContainsDuplicateTimesHref);
    else
        strTsContainsDuplicateTimes = getString(message('MATLAB:timeseries:display:TimeseriesContainsDuplicateTimes'));
        fprintf('  %s\n\n', strTsContainsDuplicateTimes);
    end
end
    
% General Settings
strCommonProperties = getString(message('MATLAB:timeseries:display:CommonProperties'));
fprintf('  %s:\n',strCommonProperties);
if ischar(ts.Name)
    locPrintSetting('Name:', sprintf('''%s''', ts.Name));
else
    locPrintSetting('Name:', '');
end
       
% Time
locPrintSetting('Time:', locGetArrayStr(ts.Time));
if bHotLinks
    str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                  locGetHyperLinkDispString(evalc('ts.TimeInfo')), ...
                  class(ts.TimeInfo));
else
    str = class(ts.TimeInfo);
end
locPrintSetting('TimeInfo:', str);            

% Data     
locPrintSetting('Data:', locGetArrayStr(ts.Data));     
if bHotLinks 
    str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                  locGetHyperLinkDispString(evalc('ts.DataInfo')), ...
                  class(ts.DataInfo));                
else
    str = class(ts.DataInfo);
end
locPrintSetting('DataInfo:', str);             

% Quality - only print if there is quality defined
if ~isempty(ts.Quality)     
    locPrintSetting('Quality:', locGetArrayStr(ts.Quality));    
    if bHotLinks
        str = sprintf('<a href="matlab: fprintf([''%s''])">[1x1 %s]</a>', ...
                      locGetHyperLinkDispString(evalc('ts.QualityInfo')), ...
                      class(ts.QualityInfo)); 
    else
        str = class(ts.QualityInfo);
    end
    locPrintSetting('QualityInfo:', str);             
end
    
% Events
if ~isempty(ts.Events)
    locPrintSetting('Events:', locGetArrayStr(ts.Events));
end

% User Data
if ~isempty(ts.UserData)
    locPrintSetting('UserData:', locGetArrayStr(ts.UserData));
end

% Links for methods and properties
if bHotLinks
    strMoreProperties = getString(message('MATLAB:timeseries:display:MoreProperties'));
    strMethods = getString(message('MATLAB:timeseries:display:Methods'));
    fprintf('\n  <a href="matlab: properties(''%s'')">%s</a>, ', mc.Name, strMoreProperties);
    fprintf('<a href="matlab: methods(''%s'')">%s</a>\n\n', mc.Name, strMethods);
else
    fprintf('\n');
end

end

% HELPER FUNCTIONS =======================================================

% function locPrintSetting -----------------------------------------------
function locPrintSetting(labelStr, valStr)

    label_len = length(labelStr);
    
    fprintf('    %s%s %s\n', ...
            blanks(13-label_len), ...
            labelStr, ...
            valStr);
end

% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
end


% function locGetArrayStr ------------------------------------------------
function str = locGetHyperLinkDispString(varName)
    str = varName;
    str = strrep(str, '''', '''''');    
    str = strrep(str, '"', ''' char(34) ''');
    str = strrep(str, '<', ''' char(60) ''');
    str = strrep(str, '>', ''' char(62) ''');
    str = strrep(str, sprintf('\n'), '\n');    
end