function gaugeComponent = uigauge(varargin)
%UIGAUGE Create circular, linear, ninety-degree, or semicircular gauge component
%   gauge = UIGAUGE creates a circular gauge in a new UI figure window.
%
%   gauge = UIGAUGE(style) specifies the gauge style.
%
%   gauge = UIGAUGE(parent) specifies the object in which to create the 
%   gauge.
%
%   gauge = UIGAUGE(parent,style) creates a gauge of the specified style in
%   the specified parent object.
%
%   gauge = UIGAUGE( ___ ,Name,Value) specifies gauge properties using one
%   or more Name,Value pair arguments. Use this option with any of the 
%   input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Circular Gauge
%      gauge = uigauge;
%
%   Example 2: Create a Linear Gauge
%      gauge = uigauge('linear');
%
%   Example 3: Specify the Parent Object for a Gauge
%      % Specify a UI figure window as the parent object for a linear gauge.
%      fig = uifigure;
%      gauge = uigauge(fig,'linear');
%
%   Example 4: Specify Scale Colors and Color Limits 
%      gauge = uigauge('ScaleColors', {'yellow', 'red'},...
%      'ScaleColorLimits', [60 80; 80 100]);
%
%   See also UIFIGURE, UIKNOB, UILAMP, UISLIDER

%   Copyright 2017 The MathWorks, Inc.

styleNames = {...
    'circular', ...
    'semicircular', ...
    'ninetydegree', ...
    'linear' , ...
    };

classNames = {...
    'matlab.ui.control.Gauge', ...
    'matlab.ui.control.SemicircularGauge', ...
    'matlab.ui.control.NinetyDegreeGauge', ...
    'matlab.ui.control.LinearGauge', ...
    };

defaultClassName = 'matlab.ui.control.Gauge';

messageCatalogID = 'uigauge';

try
    gaugeComponent = matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily(...
        styleNames, ...
        classNames, ...
        defaultClassName, ...
        messageCatalogID,...
        varargin{:});
catch ex
    error('MATLAB:ui:Gauge:unknownInput', ...
        ex.message);
end
