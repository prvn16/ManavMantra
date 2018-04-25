function spinnerComponent = uispinner(varargin)
%UISPINNER Create spinner component 
%   spinner = UISPINNER creates a spinner in a new UI figure window.
%
%   spinner = UISPINNER(parent) specifies the object in which to
%   create the spinner.
%
%   spinner = UISPINNER( ___ ,Name,Value) specifies spinner properties
%   using one or more Name,Value pair arguments. Use this option with any
%   of the input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Spinner
%      spinner = uispinner;
%
%   Example 2: Specify the Parent Object for a Spinner
%      % Specify a UI figure window as the parent object for a spinner.
%      fig = uifigure;
%      spinner = uispinner(fig);
%
%   See also UIFIGURE, UIEDITFIELD, UIGAUGE, UIKNOB, UISLIDER

%   Copyright 2017 The MathWorks, Inc.


className = 'matlab.ui.control.Spinner';

messageCatalogID = 'uispinner';

try
    spinnerComponent = matlab.ui.control.internal.model.ComponentCreation.createComponent(...
        className, ...
        messageCatalogID,...
        varargin{:});        
catch ex
    error('MATLAB:ui:Spinner:unknownInput', ...
        ex.message);
end
