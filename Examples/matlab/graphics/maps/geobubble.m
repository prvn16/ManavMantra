function gb = geobubble(varargin)
%GEOBUBBLE Visualize data values at specific geographic locations
%   gb = GEOBUBBLE(tbl,latvar,lonvar) creates a geographic bubble chart
%   with filled circles (bubbles) on a map from the table tbl and returns
%   the GeographicBubbleChart object. The latvar input indicates the table
%   variable used for bubble latitudes. The lonvar input indicates the
%   table variable used for bubble longitudes. Use gb to modify the
%   geographic bubble chart after it is created.
%
%   gb = GEOBUBBLE(tbl,latvar,lonvar,Name,Value) specifies additional
%   options using one or more name-value pair arguments to set the values
%   of geographic bubble chart properties. Two key properties are
%   'SizeVariable' and 'ColorVariable', which specify the table variables
%   that detemine the size and color of the bubbles.
%
%   gb = GEOBUBBLE(lat,lon) creates a geographic bubble chart from
%   locations specified by the coordinate vectors lat and lon.
%
%   gb = GEOBUBBLE(lat,lon,sizedata) scales the areas of the bubbles
%   according to the numeric values in the sizedata vector.
%
%   gb = GEOBUBBLE(lat,lon,sizedata,colordata) uses bubble color to
%   indicate the various categories present in the categorical vector,
%   colordata.
%
%   gb = GEOBUBBLE(___,Name,Value) specifies additional options for the
%   geographic bubble chart using one or more name-value pair arguments.
%   Specify the options after all other input arguments.
%
%   gb = GEOBUBBLE(parent,___) creates the geographic bubble chart in the
%   figure, uipanel, or uitab specified by parent.
%
%   Example
%   -------
%   tsunamis = readtable('tsunamis.xlsx');
%   tsunamis.Cause = categorical(tsunamis.Cause);
%   figure
%   gb = geobubble(tsunamis,'Latitude','Longitude', ...
%       'SizeVariable','MaxHeight','ColorVariable','Cause', ...
%       'Basemap','colorterrain')
%   geolimits([10 65],[-180 -80])
%   title 'Tsunamis in North America';
%   gb.SizeLegendTitle = 'Maximum Height';
%
%   See also GEOLIMITS

% Copyright 2016-2018 The MathWorks, Inc.

    if nargin < 2
        narginchk(2,Inf)
    end
    
    % If the first argument is a UI container, assign it to parent and
    % remove it from varargin.
    parent = gobjects(0);
    if isa(varargin{1}, 'matlab.graphics.Graphics')
        validParentClasses = { ...
            'matlab.ui.Figure', ...
            'matlab.ui.container.Panel', ...
            'matlab.ui.container.Tab'};
        parent = varargin{1};
        validateattributes( ...
            parent, validParentClasses, {'scalar'}, '', 'parent')
        if ~isvalid(parent)
            % Parent cannot be a deleted graphics object.
            error(message('MATLAB:graphics:geobubble:DeletedParent'));
        end
        
        varargin(1) = [];
        if nargin < 3
            narginchk(3,Inf)
        end
    end
    args = varargin;
    
    % Check for the table vs. matrix syntax.
    if isa(args{1}, 'tabular')
        % Table syntax
        %   geobubble(tbl,latvar,lonvar,Name,Value)
        [dataargs, args] = parseTableInputs(args);
    elseif isnumeric(args{1})
        % Matrix syntax
        %   geobubble(lat,lon,sizedata,colordata,Name,Value)
        
        % Extract latitude and longitude values.
        lat = args{1};
        lon = args{2};
        args(1:2) = [];

        % Extract the remaining data arguments and validate them together.
        [sizedata, args] = extractSizeData(args);
        [colordata, args] = extractColorData(args);
        v = matlab.graphics.chart.internal.maps.GeographicBubbleDataValidator("variables");
        dataargs = validateDataArguments(v, lat, lon, sizedata, colordata);
    else
        error(message('MATLAB:graphics:geobubble:InvalidArguments'));
    end
    
    % Examine what's left in varargin to see if there's a Parent name-value
    % pair. If there's at least one such pair, the value in the last pair
    % should be used the parent, even if the first argument is a valid UI
    % container.
    [parentFromNameValue, args] ...
        = findNameValuePair('Parent', gobjects(0), args{:});
    
    if ~isempty(parentFromNameValue)
        parent = parentFromNameValue;
    end
    
    if isempty(parent)
        parent = gcf;
    end
    validateParent(parent, 'GeographicBubbleChart')
    
    posArgsPresent = ...
        startsWith("OuterPosition", string(args(1:2:end)), 'IgnoreCase', 1); 

    try
        if ~posArgsPresent
            constructor = @(varargin) ...
                matlab.graphics.chart.GeographicBubbleChart( ...
                dataargs{:}, args{:}, varargin{:});
            gb = matlab.graphics.internal.prepareCoordinateSystem( ...
                'matlab.graphics.chart.GeographicBubbleChart', ...
                parent, constructor);
        else
            gb = matlab.graphics.chart.GeographicBubbleChart( ...
                dataargs{:}, args{:}, 'Parent', parent);
        end
        
        % Set Basemap. Basemap can be string.empty or '' but not
        % [], which is the initialization value.
        if isequal(gb.Basemap, [])
            gb.Basemap = 'auto';
        end
    catch e
        throwAsCaller(e)
    end
    
    % Ensure that computing of map properties has concluded.
    drawnow
end


function [sizedata, args] = extractSizeData(args)
% Extract sizedata value from cell array of remaining arguments.
    if isempty(args)
        sizedata = [];
    else
        if isscalar(args)
            % args = {sizedata}
            sizedata = args{1};
            args(1) = [];
        else
            numArgsIsOdd = mod(length(args),2) == 1;
            if numArgsIsOdd
                % args = {sizedata, name-value pairs}
                sizedata = args{1};
                args(1) = [];
            else
                % Even number of remaining arguments ...
                if ischar(args{1}) || isstring(args{1})
                    % args = {name-value pairs}
                    sizedata = [];
                else
                    % args = {sizedata, colordata} or
                    % args = {sizedata, colordata, name-value pairs}
                    sizedata = args{1};
                    args(1) = [];
                end
            end
        end
    end
end


function [colordata, args] = extractColorData(args)
% Extract colordata value from cell array of remaining arguments.
    if isempty(args)
        colordata = [];
    else
        % args consists of colordata alone, colordata followed by
        % name-value pairs, or just name-value pairs.
        if iscategorical(args{1}) || isscalar(args)
            % args = {colordata}
            colordata = args{1};
            args(1) = [];
        else
            numArgsIsOdd = mod(length(args),2) == 1;
            if numArgsIsOdd
                % args = {colordata, name-value pairs}
                colordata = args{1};
                args(1) = [];
            else
                % args = {name-value pairs}
                colordata = [];
            end
        end
    end
end


function [value, remargs] = findNameValuePair(name, default, varargin)
%FINDNAMEVALUEPAIR Find name-value pair and return non-matching pairs
%
%   [VALUE, REMARGS] = findNameValuePair(NAME, DEFAULT, Name, Value)
%   returns the value of the last name-value pair in the input whose name
%   matches the string NAME. If there is no match, VALUE equals DEFAULT.
%   REMARGS is a cell vector containing all non-matching input pairs.
%   Partial strings are matched (meaning that a Name string in a name-value
%   pair could be a truncated version of the first input, NAME), and
%   matching is case-insensitive. The number of inputs is assumed to be
%   even. (If the last value is missing, no error is thrown. Instead, the
%   last Name is skipped and it ends up in the remaining arguments list.)
%   If necessary, you can use internal.map.CheckNameValuePairs to
%   pre-validate that there are an even number of name-value inputs and
%   that the first element in each pair is a string.

    value = default;
    remargs = varargin;
    if ~isempty(varargin)
        deleteIndex = false(size(varargin));
        % Ignore the last Name if the length of the name-value list is odd.
        n = 2*floor(numel(varargin)/2);
        for k = 1:2:n
            
            try
                validateattributes( ...
                    varargin{k}, {'char', 'string', 'cell'}, {'nonempty'})
            catch e
                throwAsCaller(e)
            end
            
            if strncmpi(name, varargin{k}, numel(varargin{k}))
                % Found a match. Copy the value, overwriting any earlier
                % values, and flag the pair for removal from REMARGS.
                value = varargin{k+1};
                deleteIndex(k:k+1) = true;
            end
        end
        remargs(deleteIndex)=[];
    end
end


function [dataargs, args] = parseTableInputs(args)
% Parse the table syntax:
%   geobubble(tbl,latvar,lonvar,Name,Value)

    % Three input arguments are required for the table syntax.
    if numel(args) < 3
        throwAsCaller(MException(message('MATLAB:graphics:geobubble:InvalidTableArguments')));
    end

    % Collect the first three input arguments.
    tbl = args{1};
    latvar = args{2};
    lonvar = args{3};

    % Validate the latvar table subscript.
    [varname, ~, err] = ...
        matlab.graphics.chart.internal.validateTableSubscript(...
        tbl, latvar, 'latvar');
    if ~isempty(err)
        throwAsCaller(err);
    elseif isempty(varname)
        throwAsCaller(MException(message(...
            'MATLAB:Chart:NonScalarTableSubscript', 'latvar')));
    end

    % Validate the lonvar table subscript.
    [varname, ~, err] = ...
        matlab.graphics.chart.internal.validateTableSubscript(...
        tbl, lonvar, 'lonvar');
    if ~isempty(err)
        throwAsCaller(err);
    elseif isempty(varname)
        throwAsCaller(MException(message(...
            'MATLAB:Chart:NonScalarTableSubscript', 'lonvar')));
    end

    % Build the name-value pairs for the table syntax.
    dataargs = {'SourceTable', args{1}, 'LatitudeVariable', args{2}, 'LongitudeVariable', args{3}};
    args = args(4:end);

    % Look for SizeVariable in the remaining name-value pairs.
    szinds = find(strcmpi('SizeVariable',args(1:2:end-1)));
    clrinds = find(strcmpi('ColorVariable',args(1:2:end-1)));
    p = properties('matlab.graphics.chart.GeographicBubbleChart');
    if any(szinds) || any(clrinds)
        if ~isempty(szinds)
            % Found a SizeVariable.
            szinds = szinds*2-1;
            szvar = args{szinds(end)+1};
            
            % Validate the SizeVariable, but do not remove it from the list
            % of name-value pairs.
            [~, ~, err] = ...
                matlab.graphics.chart.internal.validateTableSubscript(...
                tbl, szvar, 'SizeVariable');
            if ~isempty(err)
                throwAsCaller(err);
            end
        end
        if ~isempty(clrinds)
            % Found a ColorVariable.
            clrinds = clrinds*2-1;
            clrvar = args{clrinds(end)+1};
            
            % Validate the ColorVariable, but do not remove it from the list of
            % name-value pairs.
            [~, ~, err] = ...
                matlab.graphics.chart.internal.validateTableSubscript(...
                tbl, clrvar, 'ColorVariable');
            if ~isempty(err)
                throwAsCaller(err);
            end
        end
    elseif ~isempty(args) && ...
            ((~ischar(args{1}) && ~(isstring(args{1}) && isscalar(args{1})))...
            || ~ismember(args{1},p))
        % The fourth input argument is not a recognized property name. This
        % suggests it may be a table subscript meant to be the SizeVariable
        % or ColorVariable. Check if the argument specified happens to
        % refer to a single variable in the table.
        [tblvar, ~, err] = ...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl, args{1},'');
        if isempty(err) && isnumeric(tbl.(tblvar))
            % The fourth input argument matches a single variable in the
            % table, generate error indicating the correct syntax. If the
            % variable is numeric, assume the table variable was intended
            % to be the SizeVariable.
            throwAsCaller(MException(message('MATLAB:graphics:geobubble:SizeVariableNameValuePair')));
        elseif isempty(err)
            % The fourth input argument matches a single variable in the
            % table, generate error indicating the correct syntax.
            throwAsCaller(MException(message('MATLAB:graphics:geobubble:ColorVariableNameValuePair')));
        end
    end
end


function validateParent(parent, classname)
    try
        if ~isa(parent, 'matlab.graphics.Graphics') || ~isscalar(parent)
            % Parent must be a valid scalar graphics object.
            error(message('MATLAB:graphics:geobubble:InvalidParent'));
        elseif ~isvalid(parent)
            % Parent cannot be a deleted graphics object.
            error(message('MATLAB:graphics:geobubble:DeletedParent'));
        elseif isa(parent,'matlab.graphics.axis.AbstractAxes')
            % GeographicBubbleChart cannot be a child of Axes.
            error(message('MATLAB:hg:InvalidParent',...
                classname, fliplr(strtok(fliplr(class(parent)), '.'))));
        end
    catch e
        throwAsCaller(e)
    end
end
