function hh = scatter(varargin)
%SCATTER Scatter/bubble plot.
%   SCATTER(X,Y,S,C) displays colored circles at the locations specified
%   by the vectors X and Y (which must be the same size).  
%
%   S determines the area of each marker (in points^2). S can be a
%   vector the same length a X and Y or a scalar. If S is a scalar, 
%   MATLAB draws all the markers the same size. If S is empty, the
%   default size is used.
%   
%   C determines the colors of the markers. When C is a vector the
%   same length as X and Y, the values in C are linearly mapped
%   to the colors in the current colormap. When C is a 
%   length(X)-by-3 matrix, it directly specifies the colors of the  
%   markers as RGB values. C can also be a color string. See ColorSpec.
%
%   SCATTER(X,Y) draws the markers in the default size and color.
%   SCATTER(X,Y,S) draws the markers at the specified sizes (S)
%   with a single color. This type of graph is also known as
%   a bubble plot.
%   SCATTER(...,M) uses the marker M instead of 'o'.
%   SCATTER(...,'filled') fills the markers.
%
%   SCATTER(AX,...) plots into AX instead of GCA.
%
%   H = SCATTER(...) returns handles to the scatter objects created.
%
%   Use PLOT for single color, single marker size scatter plots.
%
%   Example
%     load seamount
%     scatter(x,y,5,z)
%
%   See also SCATTER3, PLOT, PLOTMATRIX.

%   Copyright 1984-2017 The MathWorks, Inc.
 
[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
nargs = length(args);
if nargs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
end 
[pvpairs,args,nargs,msg] = parseargs(args);
error(msg);
if nargs < 2
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 4
    error(message('MATLAB:narginchk:tooManyInputs'));
end
% Until proven otherwise, color will be auto.
cDataProp = 'CData_I';
% Until proven otherwise, size will be auto.
sDataProp = 'SizeData_I';

allowNonNumeric = true;
dataargs = getRealData(args(1:nargs), allowNonNumeric);

switch (nargs)
    case 2
        [x,y] = deal(dataargs{:});
        error(Lxychk(x,y));
        [cax,parax] = localGetAxesInfo(cax);
        [ls,c,m] = nextstyle(cax); %#ok
        error(Lcchk(x,c));
        % Defaults don't quite work yet, go through old code:
        s = get(0,'DefaultLineMarkerSize')^2;
    case 3
        [x,y,s] = deal(dataargs{:});
        try
            sarg = getRealData({s});
        catch
            error(message('MATLAB:scatter:SizeColorType'));
        end
        s = datachk(sarg{1});
        error(Lxychk(x,y));
        error(Lschk(x,s));
        [cax,parax] = localGetAxesInfo(cax);
        [ls,c,m] = nextstyle(cax); %#ok
        error(Lcchk(x,c));
        sDataProp = 'SizeData';
    case 4
        [x,y,s,c] = deal(dataargs{:});
        try
            scarg = getRealData({s,c});
        catch
            error(message('MATLAB:scatter:SizeColorType'));
        end
        s = datachk(scarg{1});
        c = datachk(scarg{2});
        error(Lxychk(x,y));
        error(Lschk(x,s));
        if matlab.graphics.internal.isCharOrString(args{nargs}), c = args{nargs}; end
        error(Lcchk(x,c));
        [~,parax] = localGetAxesInfo(cax);
        sDataProp = 'SizeData';
        cDataProp = 'CData';
end

if isempty(s), s = 36; end

matlab.graphics.internal.configureAxes(cax,x,y);
[x,y] = matlab.graphics.internal.makeNumeric(cax,x,y);

h = matlab.graphics.chart.primitive.Scatter;
try
    set(h,'Parent',parax,cDataProp,c,...
          'XData',datachk(x),...
          'YData',datachk(y),...
          sDataProp,s,...
          pvpairs{:});
catch e
    delete(h);
    throw(e)
end

if nargout>0, hh = h; end

%--------------------------------------------------------------------------
function [cax,parax] = localGetAxesInfo(cax)

if isempty(cax) || (isa(cax,'matlab.graphics.axis.AbstractAxes') || ...
    isa(cax,'matlab.ui.control.UIAxes'))
    cax = newplot(cax);
    parax = cax;
else
    parax = cax;
    cax = ancestor(cax,'matlab.graphics.axis.AbstractAxes','node');
end

%--------------------------------------------------------------------------

function [pvpairs,args,nargs,msg] = parseargs(args)
msg = '';
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
n = 1;
extrapv = {};
% check for 'filled' or LINESPEC or ColorSpec
while length(pvpairs) >= 1 && n < 4 && matlab.graphics.internal.isCharOrString(pvpairs{1})
  arg = lower(pvpairs{1});
  if startsWith('filled',arg,'IgnoreCase',true)
    pvpairs(1) = [];
    extrapv = [{'MarkerFaceColor'},{'flat'},...
        {'MarkerEdgeColor'},{'none'},extrapv]; %#ok<AGROW>
    % Too many conditions to check for effective preallocation.
  else
    [l,c,m,tmsg]=colstyle(pvpairs{1});
    if isempty(tmsg)
      pvpairs(1) = [];
      if ~isempty(l) 
        extrapv = [{'LineStyle'},{l},extrapv]; %#ok<AGROW>
        % Too many conditions to check for effective preallocation.
      end
      if ~isempty(c)
        extrapv = [{'CData'},{ColorSpecToRGB(c)},extrapv]; %#ok<AGROW>
        % Too many conditions to check for effective preallocation.
      end
      if ~isempty(m)
        extrapv = [{'Marker'},{m},extrapv]; %#ok<AGROW>
        % Too many conditions to check for effective preallocation.
      end
    end
  end
  n = n+1;
end
pvpairs = [extrapv pvpairs];
if isempty(args)
  msg.message = getString(message('MATLAB:scatter:NoDataInputs'));
  msg.identifier = 'MATLAB:scatter:NoDataInputs';
else
  msg = checkpvpairs(pvpairs);
end
nargs = length(args);

%--------------------------------------------------------------------------

function color = ColorSpecToRGB(s)
color=[];
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
end

%--------------------------------------------------------------------------
function msg = Lxychk(x,y)
msg = [];
% Verify {X,Y) data is correct size
if any([length(x) length(y) ...
        numel(x) numel(y) ] ~= length(x))
    msg = struct('identifier','MATLAB:scatter:InvalidXYData',...
                 'message',getString(message('MATLAB:scatter:InvalidData')));
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
    msg = struct('identifier','MATLAB:scatter:InvalidCData',...
                 'message',getString(message('MATLAB:scatter:InvalidCData')));
end

%--------------------------------------------------------------------------
function msg = Lschk(x,s)
msg = [];
% Verify correct S vector
if length(s) > 1 && ...
              (length(s)~=numel(s) || length(s)~=length(x))
    msg = struct('identifier','MATLAB:scatter:InvalidSData',...
                 'message',getString(message('MATLAB:scatter:InvalidSData')));
end

%--------------------------------------------------------------------------
