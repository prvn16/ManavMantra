function editfieldComponent = uieditfield(varargin)
%UIEDITFIELD Create text or numeric edit field component 
%   editfield = UIEDITFIELD creates a text edit field in a new UI figure
%   window. 
%
%   editfield = UIEDITFIELD(style) creates an edit field of the specified
%   style.
%
%   editfield = UIEDITFIELD(parent) specifies the object in which to create
%   the edit field.
%
%   editfield = UIEDITFIELD(parent,style) creates an edit field of the 
%   specified style in the specified parent object.
%
%   editfield = UIEDITFIELD( ___ ,Name,Value) specifies edit field
%   properties using one or more Name,Value pair arguments. Use this option
%   with any of the input argument combinations in the previous syntaxes.
%
%   Example 1: Create a Text Edit Field
%      % Create a text edit field, the default style for an edit field.
%      editfield = uieditfield;
%
%   Example 2: Create a Numeric Edit Field
%      % Create a numeric edit field by specifying the style as numeric.
%      editfield = uieditfield('numeric');
%
%   Example 3: Specify Parent Object for Numeric Edit Field
%      % Specify a UI figure as the parent object for a numeric edit field.
%      fig = uifigure;
%      editfield = uieditfield(fig,'numeric');
%
%   See also UIFIGURE, UILABEL, UITEXTAREA

%   Copyright 2017 The MathWorks, Inc.


styleNames = {...
    'text', ...
    'numeric' ...
    };

classNames = {...
    'matlab.ui.control.EditField', ...
    'matlab.ui.control.NumericEditField' ...
    };

defaultClassName = 'matlab.ui.control.EditField';

messageCatalogID = 'uieditfield';

try
    editfieldComponent = matlab.ui.control.internal.model.ComponentCreation.createComponentInFamily(...
        styleNames, ...
        classNames, ...
        defaultClassName, ...
        messageCatalogID,...
        varargin{:});
catch ex
    error('MATLAB:ui:EditField:unknownInput', ...
        ex.message);
end
