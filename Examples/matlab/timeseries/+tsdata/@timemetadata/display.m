function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.timemetadata
%
% Copyright 2005-2011 The MathWorks, Inc.

% Use the builtin disp method for arrays
if numel(this)>1
    builtin('disp',this);
    return
end

%% Class name
mc = metaclass(this);
bHotLinks = matlab.internal.display.isHot;
if bHotLinks
    fprintf('  <a href="matlab: help %s">%s</a>\n', mc.Name, mc.Name);
else
    fprintf('  %s\n', mc.Name);
end

%% Print the package name
if ~isempty(mc.ContainingPackage)
    strPackage = getString(message('MATLAB:tsdata:timemetadata:display:Package'));
    fprintf('  %s: %s\n\n', strPackage, mc.ContainingPackage.Name);
else
    fprintf('\n');
end

%% Heading including empty, uniform, etc. 
if this.Length == 0
    strEmptyTimemetadataObj = getString(message('MATLAB:tsdata:timemetadata:display:EmptyTimeseriesTimeMetaDataObject'));
    fprintf('  %s\n', strEmptyTimemetadataObj);
elseif ~isnan(this.Increment)
    strUniformTime = getString(message('MATLAB:tsdata:timemetadata:display:UniformTime'));
    fprintf('  %s:\n', strUniformTime);
    locPrintSetting('Length', num2str(this.Length), true);
    locPrintSetting('Increment',sprintf('%d %s',this.Increment, this.Units), true);
  
else
    strNonUniformTime = getString(message('MATLAB:tsdata:timemetadata:display:NonUniformTime'));
    fprintf('  %s:\n', strNonUniformTime);   
    locPrintSetting('Length', num2str(this.Length), true);
end

%% Start and End
if this.Length>0
    strTimeRange = getString(message('MATLAB:tsdata:timemetadata:display:TimeRange'));
    fprintf('\n  %s:\n', strTimeRange);
    
    % If a start date is defined use it to convert the relative start and
    % end times into absolute start and end times with the right format
    if ~isempty(this.StartDate)
        if tsIsDateFormat(this.Format)
            startstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.Start,this.Format);
            endstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.End,this.Format);
        else
            startstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.Start,'dd-mmm-yyyy HH:MM:SS');
            endstr = datestr(datenum(this.Startdate)+tsunitconv('days',this.Units)*this.End,'dd-mmm-yyyy HH:MM:SS');
        end
    else
        startstr = sprintf('%d %s', this.Start, this.Units);
        endstr = sprintf('%d %s', this.End, this.Units);      
    end  
    
    locPrintSetting('Start', startstr, true);
    locPrintSetting('End', endstr, true);
end

%% General Settings
strCommonProperties = getString(message('MATLAB:tsdata:timemetadata:display:CommonProperties'));
fprintf('\n  %s:\n', strCommonProperties);
if ischar(this.Units) || isstring(this.Units) 
     locPrintSetting('Units:', sprintf('''%s''', this.Units));
end
if ischar(this.Format) || isstring(this.Format) 
     locPrintSetting('Format:', sprintf('''%s''', this.Format));
end
if ischar(this.StartDate) || isstring(this.StartDate) 
     locPrintSetting('StartDate:', sprintf('''%s''', this.StartDate));
end

%% Custom defined properties
if ~isempty(this.UserData)
    locPrintSetting('UserData:', locGetArrayStr(this.UserData));
end

%% Links for methods and properties
if bHotLinks
    strMoreProperties = getString(message('MATLAB:tsdata:timemetadata:display:MoreProperties'));
    strMethods = getString(message('MATLAB:tsdata:timemetadata:display:Methods'));
    fprintf('\n  <a href="matlab: properties(''%s'')">%s</a>, ', mc.Name, strMoreProperties);
    fprintf('<a href="matlab: methods(''%s'')">%s</a>\n\n', mc.Name, strMethods);
else
    fprintf('\n');
end

end

%% HELPER FUNCTIONS =======================================================

%% function locPrintSetting -----------------------------------------------
function locPrintSetting(labelStr, valStr, leftAlign)
    
    label_len = length(labelStr);
        
    if nargin > 2 && leftAlign
        fprintf('    %s%s %s\n', ...
                labelStr, ...
                blanks(12-label_len), ...
                valStr);       
    else
        fprintf('    %s%s %s\n', ...
                blanks(12-label_len), ...
                labelStr, ...
                valStr);
    end    
end

%% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
    str = sprintf('%dx', size(val));
    str = sprintf('[%s %s]', str(1:end-1), class(val));
end