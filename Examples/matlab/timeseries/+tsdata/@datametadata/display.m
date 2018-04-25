function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.datametadata
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
    strPackage = getString(message('MATLAB:tsdata:datametadata:display:Package'));
    fprintf('  %s: %s\n\n',strPackage, mc.ContainingPackage.Name);
else
    fprintf('\n');
end

%% General Settings
strCommonProperties = getString(message('MATLAB:tsdata:datametadata:display:CommonProperties'));
fprintf('  %s:\n',strCommonProperties);
% Accept string as well as valid datatype for units
if ischar(this.Units) || isstring(this.Units)
    locPrintSetting('Units:', sprintf('''%s''', this.Units));
elseif isobject(this.Units) && isprop(this.Units,'Name')
    locPrintSetting('Units:', sprintf('%s (%s)', this.Units.Name, ...
        class(this.Units)));
end

%% Interpolation
if ~isempty(this.Interpolation)
    locPrintSetting('Interpolation:', ...
        sprintf('%s (%s)', this.Interpolation.Name, ...
        class(this.Interpolation)));
end

%% Custom defined properties
if ~isempty(this.UserData)
    locPrintSetting('UserData:', locGetArrayStr(this.UserData));
end

%% Links for methods and properties
if bHotLinks
    strMoreProperties = getString(message('MATLAB:tsdata:datametadata:display:MoreProperties'));
    strMethods = getString(message('MATLAB:tsdata:datametadata:display:Methods'));
    fprintf('\n  <a href="matlab: properties(''%s'')">%s</a>, ', mc.Name,strMoreProperties);
    fprintf('<a href="matlab: methods(''%s'')">%s</a>\n\n', mc.Name,strMethods);
else
    fprintf('\n');
end

end

%% HELPER FUNCTIONS =======================================================

%% function locPrintSetting -----------------------------------------------
function locPrintSetting(labelStr, valStr, sizeLabel)

if nargin > 2
    label_len = length(sizeLabel);
else
    label_len = length(labelStr);
end

fprintf('    %s%s %s\n', ...
    blanks(17-label_len), ...
    labelStr, ...
    valStr);
end

%% function locGetArrayStr ------------------------------------------------
function str = locGetArrayStr(val)
str = sprintf('%dx', size(val));
str = sprintf('[%s %s]', str(1:end-1), class(val));
end
