function out = rulerFunctions(func, numargsout, args)
% This function is undocumented and may change in a future release.

%   Copyright 2016-2017 The MathWorks, Inc.

%% Input parsing and error checking

% Parse the function name into pieces.
[axle, ruler, family, prop, mode] = parseFunctionName(func);

% Count how many arguments were passed into the parent function
nargs = numel(args);

% Make sure we have 0-2 input arguments to the calling function.
if nargs > 2
    throwAsCaller(MException(message('MATLAB:narginchk:tooManyInputs')))
end

% Make sure we have either 0 or 1 output arguments to the calling function.
if numargsout > 1
    throwAsCaller(MException(message('MATLAB:nargoutchk:tooManyOutputs')));
end

% Helper function to validate the acceptable types of axes.
% PolarAxes and Axes are listed separately to prevent mixed vectors.
isAxes = @(ax) isa(ax,'matlab.graphics.axis.Axes') || ...
    isa(ax, 'matlab.graphics.axis.PolarAxes') || ...
    isa(ax, 'matlab.ui.control.UIAxes') || ...
    isa(ax, 'matlab.graphics.illustration.ColorBar') || ...
    isa(ax, 'matlab.graphics.chart.Chart');

% Parse the input arguments to look for an Axes.
if nargs > 0 && isscalar(args{1}) && (isgraphics(args{1},'axes') || ...
        isgraphics(args{1},'polaraxes') || isgraphics(args{1},'colorbar'))
    % The first input is a single axes or colorbar.
    ax = handle(args{1});
    args = args(2:end);
    nargs = nargs - 1;
elseif nargs > 0 && ~isempty(args{1}) && isAxes(args{1}) && all(isvalid(args{1}(:)))
    % The first input is an array of axes, charts, or colorbars.
    ax = args{1}(:);
    args = args(2:end);
    nargs = nargs - 1;
elseif nargs > 0 && isa(args{1},'matlab.graphics.Graphics')
    if ~isempty(args{1}) && all(isvalid(args{1}(:))) && all(arrayfun(isAxes,args{1}(:)))
        % Mixed list of different types of axes.
        throwAsCaller(MException(message('MATLAB:rulerFunctions:MixedAxesVector')));
    else
        % Empty vector or one of the objects is not an axes or has been deleted.
        throwAsCaller(MException(message('MATLAB:rulerFunctions:InvalidObject')));
    end
elseif nargs == 2
    % If we have two input arguments and the first input is not a valid
    % graphics object, then the user specified an invalid syntax.
    throwAsCaller(MException(message('MATLAB:rulerFunctions:InvalidAxes')));
else
    % No axes handle provided, so use the current Axes.
    ax = gca;
end

fh = [];
if isa(ax,'matlab.graphics.chart.Chart')
    % Subclasses of matlab.graphics.chart.Chart will implement individual
    % ruler functions if they are supported.
    
    % Error if the function does not exist as a method on the chart.
    if(~isPublicMethod(ax,func))
        throwAsCaller(MException(message('MATLAB:Chart:UnsupportedConvenienceFunction', func, ax(1).Type)));
    end
    
    % Store a function handle for use later.
    fh = str2func(func);
    ruler = ax;
elseif isempty(ruler) && all(isprop(ax,prop))
    % Limits are set on the Axes directly so that PreSet/PostSet events are
    % triggered, and for compatibility with colorbars.
    ruler = ax;
elseif all(isprop(ax,ruler))
    % All other properties are set on the Rulers directly.
    ruler = vertcat(ax(:).(ruler));
elseif isa(ax, 'matlab.graphics.illustration.ColorBar')
    % Colorbars support the xlim and ylim commands only for compatibility.
    throwAsCaller(MException(message('MATLAB:rulerFunctions:ColorBar',func)));
elseif isa(ax, 'matlab.ui.control.UIAxes')
    % UIAxes only supports X and Y
    throwAsCaller(MException(message('MATLAB:rulerFunctions:UIAxes',func)));
else
    % The axes specified is not compatible with this function (such as
    % calling xlim on a PolarAxes).
    throwAsCaller(axesTypeMismatch(axle, family));
end

% Filter out tickformat functions on CategoricalRuler
if strcmp(family,'tickformat') && ...
        any(isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler'))
    throwAsCaller(MException(message('MATLAB:rulerFunctions:Categorical',func)));
end

%% Get/Set the property based on the inputs

% Initialize output variables.
out = cell(0);

if nargs == 0
    % If no additional inputs were provided, return the current value of
    % the property.
    if ~isempty(fh)
        % Call the chart specific implementation.
        try
            out{1} = fh(ruler, args{:});
        catch err
            throwAsCaller(err);
        end
    elseif isscalar(ruler)
        out{1} = ruler.(prop);
    else
        out{1} = {ruler(:).(prop)}';
    end
    return
end

% Grab the value from the remaining input arguments.
val = args{1};

% If the property has a mode setting, check if the user is trying to
% change or query the mode.
if ~isempty(mode) && matlab.graphics.internal.isCharOrString(val)
    switch lower(val)
        case 'mode'
            % The user requested the current property mode
            if ~isempty(fh)
                % Call the chart specific implementation.
                try
                    out{1} = fh(ruler, 'mode');
                catch err
                    throwAsCaller(err);
                end
            elseif isscalar(ruler)
                out{1} = ruler.(mode);
            else
                out{1} = {ruler(:).(mode)}';
            end
            return
        case {'auto','manual'}
            % The user is trying to set the property mode
            
            if isempty(fh)
                % No output arguments are returned when you set the
                % property mode.
                if numargsout > 0
                    throwAsCaller(MException(message('MATLAB:nargoutchk:tooManyOutputs')));
                end

                % Set the mode
                set(ruler,mode,val);
                
                % This command notifies the Live Editor of potential changes to the figure.
                matlab.graphics.internal.markFigure(ax);
                return
            end
    end
end

% Call the chart specific implementation of the ruler function. Use the
% same number of outputs to defer error handling to the method.
if ~isempty(fh)
    out = cell(1,numargsout);
    try
        if numargsout == 0
            fh(ax,val);
        else
            [out{1:nargout}] = fh(ax,val);
        end
    catch err
        throwAsCaller(err);
    end
    return
end

% No output arguments are returned when you set the property.
if numargsout > 0
    throwAsCaller(MException(message('MATLAB:nargoutchk:tooManyOutputs')));
end

% Try to set the property to the specified value.
try
    switch family
        case {'lim','ticks','tickangle'}
            set(ruler,prop,val);
        case 'ticklabels'
            matlab.graphics.internal.ruler.setTickLabel(ruler, val);
        case 'tickformat'
            matlab.graphics.internal.ruler.setTickFormat(ruler, val);
    end
catch err
    % Check for recognized errors and replace them with custom error
    % messages specific to the convenience function.
    err = swapKnownErrorIDs(err, axle, val);
    throwAsCaller(err);
end

% This command notifies the Live Editor of potential changes to the figure.
matlab.graphics.internal.markFigure(ax);

end

%% Helper Functions

function [axle, ruler, family, prop, mode] = parseFunctionName(func)
% Parse the function name the user called and determine which ruler and
% property needs to be modified/queried.

axle = upper(func(1));
switch axle
    case {'X','Y','Z'}
        ruler = ['Active' axle 'Ruler'];
    case 'T'
        axle = 'Theta';
        ruler = 'ThetaAxis';
        func = func(5:end);
    otherwise
        ruler = [axle 'Axis'];
end

family = func(2:end);
switch family
    case 'lim'
        ruler = '';
        prop = [axle 'Lim'];
        mode = [axle 'LimMode'];
    case 'ticks'
        prop = 'TickValues';
        mode = 'TickValuesMode';
    case 'ticklabels'
        prop = 'TickLabels';
        mode = 'TickLabelsMode';
    case 'tickangle'
        prop = 'TickLabelRotation';
        mode = 'TickLabelRotationMode';
    case 'tickformat'
        prop = 'TickLabelFormat';
        mode = '';
end

end

function err = axesTypeMismatch(axle, family)
% The axle specified ('x','y','z','r', or 'theta') is a mismatch for the
% type of axes provided (polar or Cartesian). Generate a helpful error
% message.

axle = lower(axle);
func = [axle family];
switch axle
    case 'x'
        % This function does not work on a polar axes.
        if strcmp(family,'tickangle')
            % thetatickangle does not exist
            err = MException(message('MATLAB:rulerFunctions:PolarAxes',func));
        else
            alternative = ['theta' family];
            err = MException(message('MATLAB:rulerFunctions:PolarAxesAlternative',func,alternative));
        end
    case 'y'
        % This function does not work on a polar axes.
        alternative = ['r' family];
        err = MException(message('MATLAB:rulerFunctions:PolarAxesAlternative',func,alternative));
    case 'z'
        % This function does not work on a polar axes.
        err = MException(message('MATLAB:rulerFunctions:PolarAxes',func));
    case 'theta'
        % This function does not work on a cartesian axes.
        alternative = ['x' family];
        err = MException(message('MATLAB:rulerFunctions:CartesianAxes',func,alternative));
    case 'r'
        % This function does not work on a cartesian axes.
        alternative = ['y' family];
        err = MException(message('MATLAB:rulerFunctions:CartesianAxes',func,alternative));
end

end

%% Error Handler

function err = swapKnownErrorIDs(err, axle, val)
% Check for recognized errors and replace them with custom error messages
% specific to the convenience functions.

% If user passes an invalid type to _ticks, they may have intended to use
% _ticklabels, so suggest that instead.
alternative = [lower(axle) 'ticklabels'];

switch err.identifier
    
    % These error messages occur when you try to set the Limits property to
    % an invalid value.
    case {'MATLAB:hg:shaped_arrays:LimitsWithInfsPredicate',...
            'MATLAB:hg:shaped_arrays:LimitsWithInfsType',...
            'MATLAB:hg:shaped_arrays:LimitsType'}
        % Invalid limits for a NumericRuler or ColorBar
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidNumericLimits',...
            'MATLAB:rulerFunctions:InvalidLimitsMode');
    case 'MATLAB:graphics:DatetimeRuler:Limits'
        % Invalid limits for a DatetimeRuler
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidDatetimeLimits',...
            'MATLAB:rulerFunctions:InvalidLimitsMode');
    case 'MATLAB:graphics:DurationRuler:Limits'
        % Invalid limits for a DurationRuler
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidDurationLimits',...
            'MATLAB:rulerFunctions:InvalidLimitsMode');
        
    % These error messages occur when you try to set the TickValues
    % property to an invalid value.
    case 'MATLAB:hg:shaped_arrays:TickType'
        % Invalid ticks for a NumericRuler
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidNumericTicks',...
            'MATLAB:rulerFunctions:InvalidTicksMode',...
            'MATLAB:rulerFunctions:InvalidTicks', alternative);
    case 'MATLAB:graphics:DatetimeRuler:Ticks'
        % Invalid ticks for a DatetimeRuler
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidDatetimeTicks',...
            'MATLAB:rulerFunctions:InvalidTicksMode',...
            'MATLAB:rulerFunctions:InvalidTicks', alternative);
    case 'MATLAB:graphics:DurationRuler:Ticks'
        % Invalid ticks for a DurationRuler
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidDurationTicks',...
            'MATLAB:rulerFunctions:InvalidTicksMode',...
            'MATLAB:rulerFunctions:InvalidTicks', alternative);
        
    % These error messages occur when you try to set the TickLabels
    % property to an invalid value.
    case {'MATLAB:hg:datatypes:NumericOrStringDataType:ArrayClass',...
            'MATLAB:hg:datatypes:NumericOrStringDataType:InvalidCellArray'}
        % Invalid tick labels.
        err = MException(message('MATLAB:rulerFunctions:InvalidTickLabels'));
        
    % These error messages occur when you try to set the TickLabelRotation
    % property to an invalid value.
    case 'MATLAB:datatypes:InvalidFiniteValue'
        % Invalid format
        err = checkForModeorNumbersAsStrings(val, ...
            'MATLAB:rulerFunctions:InvalidAngle',...
            'MATLAB:rulerFunctions:InvalidAngle');
        
    % These error messages occur when you try to set the TickLabelFormat
    % property to an invalid value.
    case 'MATLAB:datatypes:PrintfFormatDataType:InvalidFormat'
        % Invalid format for a NumericRuler
        err = MException(message('MATLAB:rulerFunctions:InvalidNumericFormat'));
    case 'MATLAB:graphics:DatetimeRuler:Format'
        % Invalid format for a DatetimeRuler
        err = MException(message('MATLAB:rulerFunctions:InvalidDatetimeFormat'));
    case 'MATLAB:graphics:DurationRuler:Format'
        % Invalid format for a DurationRuler
        err = MException(message('MATLAB:rulerFunctions:InvalidDurationFormat'));
end

end

function err = checkForModeorNumbersAsStrings(val, defaultMsgID, charMsgID, stringMsgID, alternative)

import matlab.graphics.internal.isCharOrString;
% str2num does not support string. To avoid this, convert val
% to char. 
if isCharOrString(val) && ~isempty(str2num(char(val))) %#ok<ST2NM>
    err = MException(message('MATLAB:rulerFunctions:NumberAsString'));
elseif nargin == 5 && (iscellstr(val) || isstring(val))
    err = MException(message(stringMsgID, alternative));
elseif isCharOrString(val)
    err = MException(message(charMsgID));
else
    err = MException(message(defaultMsgID));
end

end

function tf = isPublicMethod(obj,func)

% Return true if func is a public method of obj, even if it's hidden.
mc = metaclass(obj);
methods = mc.MethodList;
names = string({methods.Name});
ix = (string(func) == names);
if any(ix)
    % Methods are unique, so only one element of ix can be true and on
    % the following line m will be scalar.
    m = methods(ix);
    tf = isequal(m.Access,'public');
else
    tf = false;
end

end