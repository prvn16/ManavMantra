function lims=objbounds(h)
%OBJBOUNDS 3D object limits.
%   LIMS=OBJBOUNDS(H)  limits of the objects in vector H.
%   LIMS=OBJBOUNDS(AX) limits of the objects that are children 
%                      of axes AX. If the axes has no children or none of
%                      children contribute to the limits, the limits of the
%                      axes AX are returned.    
%   LIMS=OBJBOUNDS     limits of the objects that are children 
%                      of the current axes. If the axes has no children or none of
%                      children contribute to the limits, the limits of the
%                      current axes are returned.
%   OBJBOUNDS calculates the 3D limits of the objects specified. The
%   limits are returned in the form [xmin xmax ymin ymax zmin zmax].
%   This is a utility function used by CAMLOOKAT.
%
%  If the limits are invalid, an empty array is returned.
%
%   See also CAMLOOKAT.

%   Copyright 1984-2009 The MathWorks, Inc.

%
%  This might be called on the HG objects of a user object when its
%  bounds are requested.
%

if nargin==0
  h = gca;
end

%Save a reference to the input object
hInput = h;

xmin = nan;
xmax = nan;
ymin = nan;
ymax = nan;
zmin = nan;
zmax = nan;

if allAxes(h)
    ch = [];
    % Get the axes children.
    for i=1:length(h)
        newCh = findobj(h(i));
        ch = [ch;newCh(2:end)]; %#ok<AGROW>
    end
    h = ch;
end

for i=1:length(h)
  validtype = false;
  if (ishghandle(h(i),'surface') || ishghandle(h(i),'line') || ishghandle(h(i),'image'))
      xd = get(h(i), 'xdata');
      yd = get(h(i), 'ydata');
      validtype = ~isempty(xd) && ~isempty(yd) && ...
          any(isfinite(xd(:))) && any(isfinite(yd(:)));
      if (ishghandle(h(i), 'image'))
          if ( validtype )
              zd = 0;
              [xd,yd] = localGetImageBounds(h(i));
          end
      else
        zd = get(h(i), 'zdata');
        if isempty(zd)
          if ishghandle(h(i), 'line')
            zd = 0; % a line can have empty zdata
          else
            validtype = false;
          end
        end
      end
      
  elseif ishghandle(h(i), 'patch')
      v = get(h(i), 'vertices');
      validtype = ~isempty(v) && any(isfinite(v(:)));
      if validtype
        f = get(h(i), 'faces');
        v = v(f(isfinite(f)),:);
        xd = v(:,1);
        yd = v(:,2);
        if size(v,2)==2
          zd = 0;
        else
          zd = v(:,3);
        end
      end
  end
  
  if validtype
    if strcmp(get(h(i),'XLimInclude'),'on')
      xmin = min(xmin,min(xd(:)));
      xmax = max(xmax,max(xd(:)));
    end
    if strcmp(get(h(i),'YLimInclude'),'on')
      ymin = min(ymin,min(yd(:)));
      ymax = max(ymax,max(yd(:)));
    end
    if strcmp(get(h(i),'ZLimInclude'),'on')
      zmin = min(zmin,min(zd(:)));
      zmax = max(zmax,max(zd(:)));
    end
  end
end

lims = [xmin xmax ymin ymax zmin zmax];
if any(isnan(lims))
  lims = [];
end
% If the lims are empty and the input argument was
% an AXES object, return the lims of the AXES.
% This can happen if either the axes has no children
% or none of the children contributed to the limits.
if( isempty(lims) && allAxes(hInput))
    xl = xlim(hInput);
    yl = ylim(hInput);
    zl = zlim(hInput);
    xmin = xl(1);  xmax = xl(2); 
    ymin = yl(1);  ymax = yl(2); 
    zmin = zl(1);  zmax = zl(2); 
    lims = [xmin xmax ymin ymax zmin zmax];
end


%----------------------------------
function [xd,yd] = localGetImageBounds(h)
% Determine the bounds of the image

xdata = get(h,'XData');
ydata = get(h,'YData');
cdata = get(h,'CData');
m = size(cdata,1);
n = size(cdata,2);

[xd(1), xd(2)] = localComputeImageEdges(xdata,n);
[yd(1), yd(2)] = localComputeImageEdges(ydata,m);

%----------------------------------
function [min,max]= localComputeImageEdges(xdata,num)
% Determine the bounds of an image edge

% This algorithm is an exact duplication of the image HG c-code 
% Reference: src/hg/gs_obj/image.cpp, ComputeImageEdges(...)

offset = .5;
nreals = length(xdata);
old_nreals = nreals;

if (old_nreals>1 && isequal(xdata(1),xdata(end)))
    nreals = 1;
end

first_last(1) = 1;
first_last(2) = num;

if (num==0) 
    min = nan;
    max = nan;
else
    first_last(1) = xdata(1);
    if (nreals>1) 
        first_last(2) = xdata(end);
    else
        first_last(2) = first_last(1) + num - 1;
    end
    
    % Data should be monotonically increasing
    if (first_last(2) < first_last(1)) 
        first_last = fliplr(first_last);
    end
    
    if (num > 1) 
       offset = (first_last(2) - first_last(1)) / (2 * (num-1));
    elseif (nreals > 1)
           offset = xdata(end) - xdata(1);
    end
    min = first_last(1) - offset;
    max = first_last(2) + offset;
end
%----------------------------------
function result = allAxes(h)

result = (all(ishghandle(h)) && ...
          length(findobj(h,'type','axes','-depth',0)) == length(h));
