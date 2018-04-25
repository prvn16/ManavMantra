function hh = scatter3(varargin)
%SCATTER3 3-D Scatter plot.
%   SCATTER3(X,Y,Z,S,C) displays colored circles at the locations
%   specified by the vectors X,Y,Z (which must all be the same size).  The
%   area of each marker is determined by the values in the vector S (in
%   points^2) and the colors of each marker are based on the values in C.  S
%   can be a scalar, in which case all the markers are drawn the same
%   size, or a vector the same length as X,Y, and Z.
%   
%   When C is a vector the same length as X,Y, and Z, the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a LENGTH(X)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   SCATTER3(X,Y,Z) draws the markers with the default size and color.
%   SCATTER3(X,Y,Z,S) draws the markers with a single color.
%   SCATTER3(...,M) uses the marker M instead of 'o'.
%   SCATTER3(...,'filled') fills the markers.
%
%   SCATTER3(AX,...) plots into AX instead of GCA.
%
%   H = SCATTER3(...) returns handles to scatter objects created.
%
%   Use PLOT3 for single color, single marker size 3-D scatter plots.
%
%   Example
%      [x,y,z] = sphere(16);
%      X = [x(:)*.5 x(:)*.75 x(:)];
%      Y = [y(:)*.5 y(:)*.75 y(:)];
%      Z = [z(:)*.5 z(:)*.75 z(:)];
%      S = repmat([1 .75 .5]*10,numel(x),1);
%      C = repmat([1 2 3],numel(x),1);
%      scatter3(X(:),Y(:),Z(:),S(:),C(:),'filled'), view(-60,60)
%
%   See also SCATTER, PLOT3.

%   Copyright 1984-2017 The MathWorks, Inc.

[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
nargs = length(args);
if nargs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
end
[pvpairs,args,nargs,msg] = parseargs(args);
if ~isempty(msg), error(msg); end

% Until proven otherwise, color will be auto.
cDataProp = 'CData_I';
% Until proven otherwise, size will be auto.
sDataProp = 'SizeData_I';

if nargs < 3
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 7
    error(message('MATLAB:narginchk:tooManyInputs'));
end
  
allowNonNumeric = true;
dataargs = getRealData(args(1:nargs), allowNonNumeric);

switch (nargs)
    case 3
        [x,y,z] = deal(dataargs{:});
        error(Lxyzchk(x,y,z));
        if isempty(cax) || ishghandle(cax,'axes')
            cax = newplot(cax);
            parax = cax;
        else
            parax = cax;
            cax = ancestor(cax,'axes');
        end
        [~,c,~] = nextstyle(cax);
        error(Lcchk(x,c));
        % Defaults don't quite work yet, go through old code:
        s = get(0,'DefaultLineMarkerSize')^2;
    case 4
        [x,y,z,s] = deal(dataargs{:});
        try
            sarg = getRealData({s});
        catch
            error(message('MATLAB:scatter:SizeColorType'));
        end
        s = datachk(sarg{1});
        sDataProp= 'SizeData';
        error(Lxyzchk(x,y,z));
        error(Lschk(x,s));
        if isempty(cax) || ishghandle(cax,'axes')
            cax = newplot(cax);
            parax = cax;
        else
            parax = cax;
            cax = ancestor(cax,'axes');
        end
        [~,c,~] = nextstyle(cax);
    case 5
        [x,y,z,s,c] = deal(dataargs{:});
        try
            scarg = getRealData({s,c});
        catch
            error(message('MATLAB:scatter:SizeColorType'));
        end
        s = datachk(scarg{1});
        c = datachk(scarg{2});
        sDataProp = 'SizeData';
        cDataProp = 'CData';
        error(Lxyzchk(x,y,z));
        error(Lschk(x,s));
        if matlab.graphics.internal.isCharOrString(args{nargs}), c = args{nargs}; end
        error(Lcchk(x,c));
        if isempty(cax) || ishghandle(cax,'axes')
            cax = newplot(cax);
            parax = cax;
        else
            parax = cax;
            cax = ancestor(cax,'axes');
        end
    otherwise
        error(message('MATLAB:scatter3:invalidInput'));
end

if isempty(s), s = 36; end

matlab.graphics.internal.configureAxes(cax,x,y,z);
[x,y,z] = matlab.graphics.internal.makeNumeric(cax,x,y,z);

h = matlab.graphics.chart.primitive.Scatter;
try
    set(h,'Parent',parax,'XData',datachk(x),...
          'YData',datachk(y),...
          'ZData',datachk(z),...
          sDataProp,s,...
          cDataProp,c,pvpairs{:});
catch e
    delete(h)
    throw(e)
end

switch cax.NextPlot
    case {'replaceall','replace'}
        view(cax,3);
        grid(cax,'on');
    case {'replacechildren'}
        view(cax,3);
end

if nargout>0, hh = h; end

%--------------------------------------------------------------------------
function [pvpairs,args,nargs,msg] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
n = 1;
extrapv = {};
% check for 'filled' or LINESPEC or ColorSpec
while length(pvpairs) >= 1 && n < 5 && matlab.graphics.internal.isCharOrString(pvpairs{1})
  arg = lower(pvpairs{1});
  if startsWith('filled',arg,'IgnoreCase',true)
    pvpairs(1) = [];
    extrapv = [{'MarkerFaceColor','flat','MarkerEdgeColor','none',} ...
               extrapv];
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = [{'LineStyle',l},extrapv];
      end
      if ~isempty(c)
        extrapv = [{'CData',ColorSpecToRGB(c)},extrapv];
      end
      if ~isempty(m)
        extrapv = [{'Marker',m},extrapv];
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
msg = checkpvpairs(pvpairs);
nargs = length(args);

%--------------------------------------------------------------------------
function [color,msg] = ColorSpecToRGB(s)
color=[];
msg = [];
switch s
 case 'y'
  color = [1 1 0];
 case 'm'
  color = [1 0 1];
 case 'c'
  color = [0 1 1];
 case 'r'
  color = [1 0 0];
 case 'g'
  color = [0 1 0];
 case 'b'
  color = [0 0 1];
 case 'w'
  color = [1 1 1];
 case 'k'
  color = [0 0 0];
 otherwise
  msg = getString(message('MATLAB:scatter3:unrecognizedColorString'));
end

%--------------------------------------------------------------------------
function msg = Lxyzchk(x,y,z)
msg = [];
% Verify {X,Y,Z) data is correct size
if any([length(x) length(y) length(z) ...
        numel(x) numel(y) numel(z)] ~= length(x))
    msg = struct('identifier','MATLAB:scatter3:invalidData',...
                 'message',getString(message('MATLAB:scatter3:invalidData')));
end

%--------------------------------------------------------------------------
function msg = Lcchk(x,c)
msg = [];
% Verify CData is correct size
if matlab.graphics.internal.isCharOrString(c) || isequal(size(c),[1 3])
    % string color or scalar rgb 
elseif length(c)==numel(c) && length(c)==length(x)
    % C is a vector
elseif isequal(size(c),[length(x) 3])
    % vector of rgb's
else
    msg = struct('identifier','MATLAB:scatter3:invalidCData',...
                 'message',getString(message('MATLAB:scatter3:invalidCData')));
end

%--------------------------------------------------------------------------
function msg = Lschk(x,s)
msg = [];
% Verify correct S vector
if length(s) > 1 && ...
              (length(s)~=numel(s) || length(s)~=length(x))
    msg = struct('identifier','MATLAB:scatter3:invalidSData',...
                 'message',getString(message('MATLAB:scatter3:invalidSData')));
end
