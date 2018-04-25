function display(this)
% DISPLAY  Overloaded DISPLAY method for tsdata.qualmetadata
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
    strPackage = getString(message('MATLAB:tsdata:qualmetadata:display:Package'));
    fprintf('  %s: %s\n\n',strPackage, mc.ContainingPackage.Name);
else
    fprintf('\n');
end

%% Codes
%fprintf('\n');
if ~isempty(this.Code) && ~isempty(this.Description)
    if length(this.Code)==length(this.Description)
        %% Heading
        code_col_width = 16;
        str = getString(message('MATLAB:tsdata:qualmetadata:display:Code'));
        heading = [str blanks(code_col_width - length(str)) getString(message('MATLAB:tsdata:qualmetadata:display:Description'))];
        fprintf('  %s\n', heading);
        fprintf('  %s\n', repmat('-',[1 length(heading)]));
        
        %% Table
        for i=1:length(this.Code)
            try
                str = num2str(this.Code(i));
                fprintf('  %s%s%s\n', ...
                        str, ...
                        blanks(code_col_width - length(str)), ...
                        this.Description{i});    
            catch me
                rethrow(me);
            end
        end        
        fprintf('  %s\n', repmat('-',[1 length(heading)]));
    else
        strQltyCodeDescNoSync = getString(message('MATLAB:tsdata:qualmetadata:display:QualityCodeDescNotSynchronized'));
        fprintf('  %s\n', strQltyCodeDescNoSync);
    end
elseif isempty(this.Code)
    strQltyCodeNoDef = getString(message('MATLAB:tsdata:qualmetadata:display:NoQualityCodeDefined'));
    fprintf('    %s\n', strQltyCodeNoDef);
elseif isempty(this.Description)
    strQltyDescNoDef = getString(message('MATLAB:tsdata:qualmetadata:display:NoQualityDescDefined'));
    fprintf('    %s\n', strQltyDescNoDef);
end

%% General Properties
strCommonProperties = getString(message('MATLAB:tsdata:qualmetadata:display:CommonProperties'));
fprintf('\n  %s:\n', strCommonProperties);
locPrintSetting('Code:', locGetArrayStr(this.Code));
locPrintSetting('Description:', locGetArrayStr(this.Description));

%% Custom defined properties
if ~isempty(this.UserData)
    locPrintSetting('UserData:', locGetArrayStr(this.UserData));
end

%% Links for methods and properties
if bHotLinks
    strMoreProperties = getString(message('MATLAB:tsdata:qualmetadata:display:MoreProperties'));
    strMethods = getString(message('MATLAB:tsdata:qualmetadata:display:Methods'));
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
