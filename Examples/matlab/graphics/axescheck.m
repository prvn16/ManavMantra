function [ax,args,nargs] = axescheck(varargin)
% This function is undocumented and may change in a future release.

%AXESCHECK Process Axes objects from input list
%   [AX,ARGS,NARGS] = AXESCHECK(ARG1,ARG2,...) looks for Axes provided in
%   the input arguments. It first checks if ARG1 is an Axes. If so, it is
%   removed from the list in ARGS and the count in NARGS. AXESCHECK then
%   checks the arguments for Name, Value pairs with the name 'Parent'. If a
%   graphics object is found following the last occurance of 'Parent', then
%   all 'Parent', Value pairs are removed from the list in ARGS and the
%   count in NARGS. ARG1 (if it is an Axes), or the value following the
%   last occurance of 'Parent', is returned in AX. Double handles to
%   graphics objects are converted to graphics objects. If AX is determined
%   to be a handle to a deleted graphics object, an error is thrown.

%    Copyright 1984-2015 The MathWorks, Inc.

args = varargin;
nargs = nargin;
ax=[];

% Check for either a scalar Axes handle, or any size array of Axes.
% 'isgraphics' will catch numeric graphics handles, but will not catch
% deleted graphics handles, so we need to check for both separately.
if (nargs > 0) && ...
        ((isscalar(args{1}) && isgraphics(args{1},'axes')) ...
        || isa(args{1},'matlab.graphics.axis.AbstractAxes') || isa(args{1},'matlab.ui.control.UIAxes'))
  ax = handle(args{1});
  args = args(2:end);
  nargs = nargs-1;
end
if nargs > 0
  inds = find(strcmpi('parent',args));
  if ~isempty(inds)
    inds = unique([inds inds+1]);
    pind = inds(end);
    
    % Check for either a scalar handle, or any size array of graphics objects.
    % If the argument is passed using the 'Parent' P/V pair, then we will
    % catch any graphics handle(s), and not just Axes.
    if nargs >= pind && ...
            ((isscalar(args{pind}) && isgraphics(args{pind})) ...
            || isa(args{pind},'matlab.graphics.Graphics'))
      ax = handle(args{pind});
      args(inds) = [];
      nargs = length(args);
    end
  end
end

% Make sure that the graphics handle found is a scalar handle, and not an
% empty graphics array or non-scalar graphics array.
if (nargs < nargin) && ~isscalar(ax)
    throwAsCaller(MException(message('MATLAB:graphics:axescheck:NonScalarHandle')));
end

% Throw an error if a deleted graphics handle is detected.
if ~isempty(ax) && ~isvalid(ax)
  % It is possible for a non-Axes graphics object to get through the code
  % above if passed as a Name/Value pair. Throw a different error message
  % for Axes vs. other graphics objects.
  if(isa(ax,'matlab.graphics.axis.AbstractAxes') || isa(ax,'matlab.ui.control.UIAxes'))
    throwAsCaller(MException(message('MATLAB:graphics:axescheck:DeletedAxes')));
  else
    throwAsCaller(MException(message('MATLAB:graphics:axescheck:DeletedObject')));
  end
end
