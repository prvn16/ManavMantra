function [hcomponent, hcontainer] = javacomponent(varargin)
% This function is undocumented and will change in a future release

% JAVACOMPONENT Create a Java Swing Component and put it in a figure
%
% JAVACOMPONENT(COMPONENTNAME) creates the Java component specified by the
% string COMPONENTNAME and places it in the current figure or creates a new
% figure if one is not available. The default position is [20 20 60 20].
% NOTE: This is a thread safe way to create and embed a java component in a
% figure window. If COMPONENTNAME is a cellarray, the 1st input must be a
% string with the component name and subsequent entries can be constructor
% input arguments. For more thread safe functions to create and modify java
% components, see javaObjectEDT, javaMethodEDT.
%
% JAVACOMPONENT(..., POSITION, PARENT) places the Java component in the
% specified PARENT at position POSITION. PARENT can be a Figure, a Uipanel,
% or a Uitoolbar. POSITION is in pixel units with the format [left, bottom,
% width, height]. Note that POSITION is ignored if PARENT is a Uitoolbar.
%
% JAVACOMPONENT(..., CONSTRAINT, PARENT) places the Java component next to
% the figure's drawing area using CONSTRAINT. CONSTRAINT can be NORTH,
% SOUTH, EAST, OR WEST - following Java AWT's BorderLayout rules. The
% handle to the Java component is returned on success, empty is returned on
% error. If the parent is a uipanel, the component is placed in the parent
% figure of the uipanel. If parent is a uitoolbar, CONSTRAINT is ignored
% and the component is placed last in the child list for the given toolbar.
%
% [HCOMPONENT, HCONTAINER] = JAVACOMPONENT(...)
% returns the handle to the Java component in HCOMPONENT and its HG
% container in HCONTAINER. HCONTAINER is only returned when pixel
% positioning is used. It should be used to change the units, position, and
% visibility of the Java component after it is added to the figure.
%
%   Examples:
%
%   f = figure;
%   b = javacomponent({'javax.swing.JButton','Hello'}, [], f,  ...
%           {'ActionPerformed','disp Hi'});
%
%   f = figure('WindowStyle', 'docked');
%   b1 = javacomponent('javax.swing.JButton', [], f, ...
%           {'ActionPerformed','disp Hi'});
%   setLabel(b1,'Hello')
%
%   f = figure;
%   [comp, container] = javacomponent('javax.swing.JSpinner');
%   container.Position = [100, 100, 100, 40];
%   container.Units = 'normalized';
%
%   f = figure;
%   p = uipanel('Position', [0 0 .2 1]);
%   ppos = getpixelposition(p);
%   [tree treecontainer] = javacomponent('javax.swing.JTree', ...
%                             [0 0 ppos(3) ppos(4)], p);
%
%   f = figure('WindowStyle', 'docked');
%   % Note use of constructor args in 1st input.
%   table = javacomponent({'javax.swing.JTable', 3, 10}, ...
%              java.awt.BorderLayout.SOUTH, f);
%
%   f = figure;
%   tb = uitoolbar(f);
%   % Note: Position input is ignored.
%   b2 = javacomponent('javax.swing.JButton', [], tb, ...
%                 {'ActionPerformed','disp Hi'});
%   setLabel(b2,'Hi again!')
%
% See also USEJAVACOMPONENT, javaObjectEDT, javaMethodEDT

% Deprecated input.
%
% JAVACOMPONENT(HCOMPONENT) places the Java component HCOMPONENT in the
% current figure or creates a new figure if one is not available. The
% default position is [20 20 60 20]. HCOMPONENT is tagged for autodelegation
% to the EDT.

% Copyright 1984-2014 The MathWorks, Inc.

narginchk(1,4)
[varargin{:}] = convertStringsToChars(varargin{:});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We are having to unwrap the parent
% at both the top level function and again
% in the private impl's. It is okay for now
% but if we are forced to do more work here
% then it is a sign to refactor.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (nargin>=3)
    parent = varargin{3};
else
    parent = gcf;
end

[hcomponent, hcontainer] =  javacomponentdoc_helper(varargin{:});
end



%---------------------------------------------------------------------
% Strange serialization workarounds
function containerDelete(varargin)  %#ok
end
