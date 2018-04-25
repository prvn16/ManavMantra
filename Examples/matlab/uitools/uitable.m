function [thandle, chandle] = uitable(varargin)
% UITABLE creates a two dimensional graphic table component.
%   UITABLE creates a table component using default property values in
%   the current figure window. If no figure exists, one will be created.
%
%   UITABLE('PropertyName1',value1,'PropertyName2',value2,...) creates a
%   uitable object with specified property values. MATLAB uses default
%   property values for any property that is not specified.
%
%   UITABLE(PARENT, ...) creates a uitable object as child of the specified
%   parent handle PARENT. The parent can be a figure or uipanel handle.
%
%   H = UITABLE(...) creates a uitable object and returns its handle.
%
%   Execute GET(H), where H is a uitable handle, to see the list of uitable
%   object properties and their current values.
%
%   Execute SET(H) to see the list of uitable object properties that can be
%   set and their legal property values.
%
%   Example: create a table with data, column names, parent and position.
%      f = figure;
%      data = rand(3);
%      colnames = {'X-Data', 'Y-Data', 'Z-Data'};
%      t = uitable(f, 'Data', data, 'ColumnName', colnames, ...
%                  'Position', [20 20 260 100]);
%
%
%   See also FIGURE, INSPECT, FORMAT, SPRINTF, UICONTROL, UIMENU, UIPANEL

%   Copyright 2002-2012 The MathWorks, Inc.
%   Built-in function.

% If using the 'v0' switch explicitly, use the old uitable.
if (usev0dialog(varargin{:}))
    [thandle, chandle] = uitable_deprecated(varargin{2:end});
else
    % If using the 2-output syntax or using an old, unsupported API,
    % use the old table.
    if (nargout == 2) ||(uitable_parseold(varargin{:}))
        % Warn about using the old undocumented uitable.
        urlHelpUitable = 'matlab:help(''uitable'')';
        urlDocUitable = 'matlab:doc(''uitable'')';
        urlCSHelpWindow = 'matlab:helpview([docroot,''/techdoc/helptargets.map''],''uitable_migration'',''CSHelpWindow'')';
 
        warning(message('MATLAB:uitable:OldTableUsage', urlHelpUitable, urlDocUitable, urlCSHelpWindow))
        [thandle, chandle] = uitable_deprecated(varargin{:});
    else
        % If not using the v0 option and using PV pairs that are either supported
        % by the new API or not supported at all, use the new uitable.
        thandle = builtin('uitable', varargin{:});
    end
end
