function iptwindowalign(fixed_fig, fixed_fig_location, moving_fig, moving_fig_location, opt)
%IPTWINDOWALIGN Align figure windows.
%   IPTWINDOWALIGN(FIXED_FIG, FIXED_FIG_EDGE, MOVING_FIG, MOVING_FIG_EDGE)
%   moves the figure MOVING_FIG to align it with figure FIXED_FIG. 
%   FIXED_FIG and MOVING_FIG must be handles to figure objects.
%
%   FIXED_FIG_EDGE and MOVING_FIG_EDGE describe the alignment of
%   the figures in relation to their edges and can take any of 
%   the following values: 'left', 'right', 'hcenter', 'top',
%   'bottom', or 'vcenter'. 'hcenter' means center horizontally and 
%   'vcenter' means center vertically.
%
%   Notes
%   -----
%   The two specified locations must be consistent in terms of their
%   direction.  For example, it is an error to specify 'left' for
%   FIXED_FIG_LOCATION and 'bottom' for MOVING_FIG_LOCATION.
%
%   IPTWINDOWALIGN constrains the position adjustment of MOVING_FIG to
%   keep it entirely visible on the screen.
%
%   IPTWINDOWALIGN has no effect if either figure is docked.
%   
%   Examples
%   --------
%       % Create two figures.
%       fig1 = figure; imshow('peppers.png')
%       fig2 = figure; imshow('cameraman.tif')
%
%       % Move fig2 so its right edge is aligned with fig1's left edge.
%       iptwindowalign(fig1, 'left', fig2, 'right');
%
%       % Move fig2 so its left edge is aligned with fig1's right edge, and
%       % also move it so the two figures are vertically centered.
%       iptwindowalign(fig1, 'right', fig2, 'left');
%       iptwindowalign(fig1, 'vcenter', fig2, 'vcenter');
%
%   See also IMTOOL.

%   Copyright 1993-2017 The MathWorks, Inc.

% Calling "drawnow, drawnow" in several places below is to work around
% MATLAB 7 bugs in getting OuterPosition and setting Position on
% figures.  I added the option to skip the drawnow calls because it
% really messes up the image info tool.  It makes it resizable, even
% though it's Resize property is off, and it messes up the way it draws.
% -sle, 2004/06/22

fixed_fig_location = matlab.images.internal.stringToChar(fixed_fig_location);
moving_fig_location = matlab.images.internal.stringToChar(moving_fig_location);
if nargin > 4
    opt = matlab.images.internal.stringToChar(opt);
end

% if either figure is docked we return and silently ignore call
fixed_fig_docked = strcmpi(get(fixed_fig,'WindowStyle'),'Docked');
moving_fig_docked = strcmpi(get(moving_fig,'WindowStyle'),'Docked');
if fixed_fig_docked || moving_fig_docked
    return
end

do_drawnow = (nargin < 5) || ~strcmp(opt, 'nodrawnow');
if do_drawnow
  drawnow, drawnow;
end


destUnits = get(moving_fig,'units');
% This anonymous function returns properties represented as position
% rectangles in moving figure units.
getPropertyInDestUnits = @(h_obj,prop) hgconvertunits(h_obj, ...
                                         get(h_obj,prop),...
                                         get(h_obj,'units'),...
                                         destUnits,...
                                         get(h_obj,'Parent'));

fixed_fig_outer_position  = getPropertyInDestUnits(fixed_fig,'outerposition');

moving_fig_position       = getPropertyInDestUnits(moving_fig,'position');
moving_fig_outer_position = getPropertyInDestUnits(moving_fig,'outerposition');

alignment_direction = getAlignmentDirection(fixed_fig_location);
if alignment_direction ~=  getAlignmentDirection(moving_fig_location)
    error(message('images:iptwindowalign:directionMismatch'));
end

ref1 = getReferencePoint(fixed_fig_outer_position, fixed_fig_location);
ref2 = getReferencePoint(moving_fig_outer_position, moving_fig_location);

moving_fig_position(alignment_direction) = ...
    moving_fig_position(alignment_direction) + ref1 - ref2;

set(moving_fig, 'Position', moving_fig_position);

if do_drawnow
  drawnow, drawnow
end

movegui(moving_fig,'onscreen');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dir = getAlignmentDirection(location)
% Returns 1 for horizontal alignment, 2 for vertical alignment.

switch location
  case {'left' 'right' 'hcenter'}
    dir = 1;
    
  case {'top' 'bottom' 'vcenter'}
    dir = 2;
    
  otherwise
    error(message('images:iptwindowalign:invalidLocation'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ref = getReferencePoint(pos, loc)
% POS position vector
% LOC 'left', 'right', 'hcenter', 'top', 'bottom', 'vcenter'
% FP  output of figparams

switch loc
  case 'left'
    ref = pos(1);
    
  case 'bottom'
    ref = pos(2);
    
  case 'right'
    ref = pos(1) + pos(3);
    
  case 'top'
    ref = pos(2) + pos(4);
    
  case 'hcenter'
    ref = (getReferencePoint(pos, 'left') + getReferencePoint(pos, 'right'))/2;
    
  case 'vcenter'
    ref = (getReferencePoint(pos, 'bottom') + getReferencePoint(pos, 'top'))/2;
    
  otherwise
    error(message('images:iptwindowalign:invalidLocation'));
end
