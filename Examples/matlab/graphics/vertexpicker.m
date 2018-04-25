function varargout = vertexpicker(varargin)
% This internal helper function may change in a future release.

% [P V I PFACTOR] = VERTEXPICKER(OBJ,TARGET,MODE) 
% OBJ is an axes child.
% TARGET is an axes ray as if produced by the 'CurrentPoint' axes
%        property.
% MODE is optional, '-force' will find closest vertex even if the
%        TARGET ray does not intersect OBJ. This option is used by
%        the data cursor feature as the mouse drags away from the 
%        object
%                   
% P is the projected mouse position on OBJ.
% V is the nearest vertex to P.
% I is the index to V.
% PFACTOR is the amount of interpolation between P and V.
%
% [P V I PFACTOR] = VERTEXPICKER(OBJ,MODE) Assumes TARGET 
%                   is the axes current point                     

%   Copyright 1984-2014 The MathWorks, Inc.

% Output variables

pout = {}; % interpolated point (1x3)
vout = {}; % closest data vertex  point (1x3)
viout = {}; % index into vertex array representing vout (1x1)
pfactor = {}; % interpolation factor
facevout = {}; % intersected face polygon 

% parse input
[obj,target,mode] = local_parseargs(nargin,varargin);

if any( isempty(obj) )
    varargout = {pout,vout,viout,pfactor,facevout};
    return;
end

len = length(obj);
% scalar input
if len==1
   [pout,vout,viout,pfactor,facevout] = ...
                                local_main(obj,target,mode);
else
   pout = {};
   vout = {};
   viout = {};
   pfactor = {};
   facevout = {};   
   % Loop through every object and select the vertex closest 
   % to the mouse pointer in relative view space
   xdist = inf(len,1);
   
   for n = 1:len
      ax = ancestor(obj(n),'axes');
      if isempty(ax)
          continue;
      end
      [pout{n},vout{n},viout{n},pfactor{n},facevout{n}] = local_main(obj(n),target,mode); %#ok<AGROW>
      if ~isempty(pout{n})
          targetViewer = specgraphhelper('convertDataSpaceCoordsToViewerCoords',ax,target(1,:)');
          poutViewer = specgraphhelper('convertDataSpaceCoordsToViewerCoords',ax,pout{n}');
          xdist(n) = norm(poutViewer-targetViewer);
      end
   end
    % Get closest vertex to mouse pointer
   [~,ind] = min(xdist);
   if ~isempty(ind)
       pout = pout{ind};
       vout = vout{ind};
       viout = viout{ind};
       pfactor = pfactor{ind};
       facevout = facevout{ind};
   end
end
varargout = {pout,vout,viout,pfactor,facevout};

function [pout, vout, viout, pfactor, facevout] = local_main(obj,target,mode)

% Output variables

pout = {}; % interpolated point (1x3)
vout = {}; % closest data vertex  point (1x3)
viout = {}; % index into vertex array representing vout (1x1)
pfactor = {}; % interpolation factor
facevout = []; % intersected face polygon 

% If necessary obtain a chartMixin.DataAnnotatable for the supplied 
% by wrapping it in a chartMixin adaptor
cObj = matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(obj);
if isempty(cObj)
    return
end

% DataAnnotatable methods such as getInterpolatedPoint and
% getReportedPosition may use the DataCursor behavior object update method.
% This will create a recursive loop if vertexpicker is called from inside
% a DataCursor behavior object update method. To prevent this, temporarily
% remove the DataCursor behavior object.
dataCursorBehavior = hggetbehavior(obj,'DataCursor','-peek');
if ~isempty(dataCursorBehavior)
    obj.Behavior = rmfield(obj.Behavior,lower(dataCursorBehavior.Name));
end

% Get the target in figure pixels and use it to find the closest index
% and interpolation factor.
ax = ancestor(obj,'axes');

% % if some values are not valid in the log space
if isa(ax.ActiveDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
    ds = ax.ActiveDataSpace;
    invalid_x = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(ds.XScale, ds.XLim, target(1,1));
    invalid_y = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(ds.YScale, ds.YLim, target(1,2));   
    invalid_z = matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(ds.ZScale, ds.ZLim, target(1,3));    
    if invalid_x || invalid_y || invalid_z
        return
    end
end

panelpixpos = specgraphhelper('convertDataSpaceCoordsToViewerCoords',...
    ax,target(1,:)');
panelpixpos = panelpixpos(:).';
figpixpos = localTranslateToFigure(obj, panelpixpos);
[viout,pfactor] = cObj.getInterpolatedPoint(figpixpos);

 % If all the x,y,z datapoints contain a NaN value, viout will be empty.	 
 if isempty(viout)	 
     facevout = [];	 
     return	 
 end
 
% Find the closest point on the object and convert it back to figure
% pixels.
pout = cObj.getReportedPosition(viout,pfactor);
pout.Is2D = false;
pout = pout.getLocation(obj);
panelpixinterppos = specgraphhelper('convertDataSpaceCoordsToViewerCoords',...
    ax,pout(1,:)');
panelpixinterppos = panelpixinterppos(:).';

% If we are not in force mode and the projected point is > 2 pixels
% away from the target we did not click on the object and so quick
% return.
if ~ishghandle(obj,'line') && ~strcmpi(mode,'-force') && ...
        max(abs(panelpixinterppos-panelpixpos))>2
    return
end

if isnumeric(pfactor) && isscalar(pfactor) && pfactor>0.5
    % The scalar interpolation factors returned by the DataAnnotatable
    % interface are in [0 1].  We want to return [-0.5 0.5].
    viout = viout+1;
    pfactor = pfactor-1;
end

% Find the closest vertex.
vout = cObj.getReportedPosition(viout); 
vout.Is2D = false;
vout = vout.getLocation(obj);   

if ~isempty(dataCursorBehavior)
    hgaddbehavior(obj,dataCursorBehavior);
end

if ishghandle(obj,'patch') 
    % Work out which face the annotatable index is inside.  Patches use a
    % row-major index model
    [~, faceIndex] = ind2sub(size(obj.Faces.'), viout);
    faceVertIndices = obj.Faces(faceIndex,:);
    faceVertIndices = faceVertIndices(~isnan(faceVertIndices));
    facevout = obj.Vertices(faceVertIndices, :).';
    
    % The annotatable index is a row-based index into the face list and not a vertex
    % index.  This converts to the required vertex index
    faces = obj.Faces.';
    viout = faces(viout);

else % "face" is ill-defined for non-patches.  Return empty.
    facevout = [];
end


function position = localTranslateToFigure(hObj, position)
% Transform local panel point into the figure's coordinate system

% Get the figure->panel offset by calling the brushing utility with a
% figure location of [0 0], then apply this in the opposite direction to
% our position.
OffSet = brushing.select.translateToContainer(hObj, [0 0]);
position = position - OffSet;

%--------------------------------------------------------%
function [obj,target,mode] = local_parseargs(nin,vargin)
% Parse input arguments

if nin == 3
   obj = vargin{1};
   target = vargin{2};
   mode = vargin{3};
elseif nin==2
   obj = vargin{1};
   arg2 = vargin{2};
   if ischar(arg2)
      mode = arg2;
      ax = ancestor(obj,'axes');
      target = get(ax,'CurrentPoint');
   else
      mode = '-default';
      target = arg2;
   end
elseif nin==1
   obj = vargin{1};   
   ax = ancestor(obj,'axes');
   target = get(ax,'CurrentPoint');
   mode = '-default';
else
  error(message('MATLAB:vertexpicker:InvalidInputs'))
end

obj = handle(obj);

if any(isempty(obj)) || any(~ishghandle(obj))
    errmsg = message('MATLAB:uistring:vertexpicker:InputArgumentMustBeAValidGraphicsHandle');
    error(errmsg);
end






