function ph = plot(varargin)
% PLOT Plot a polyshape object
%
% PLOT(pshape) plots a polyshape object.
%
% h = PLOT(pshape) also returns a Polygon graphics object. Use the
% properties of this object to inspect and adjust the plotted graph.
%
% See also matlab.graphics.primitive.Polygon, polyshape, patch

% Copyright 2016-2017 The MathWorks, Inc.
%
[cax,args] = axescheck(varargin{:});
nameOffset = 1 + ~isempty(cax); % used in error messages

pshape = args{1};
validateattributes(pshape,{'polyshape'},{},nameOffset);
args = args(2:end); % discard AX and pshape
args = matlab.graphics.internal.convertStringToCharArgs(args);

nd = polyshape.checkArray(pshape);

axesParent =  isempty(cax) || isa(cax,'matlab.ui.control.UIAxes') || ...
    isa(cax,'matlab.graphics.axis.AbstractAxes');
if axesParent
    cax = newplot(cax);
end

%plot the polyshape
hObj = gobjects(nd);
for i=1:numel(pshape)
    nextColor = [0,0,0];
    if axesParent
        [~,nextColor,~] = specgraphhelper('nextstyle',cax,true,true,false);
    end
    hObj(i) = matlab.graphics.primitive.Polygon('Shape',pshape(i),...
        'FaceColor',nextColor,'FaceAlpha',0.35,...
        'Parent',cax, args{:});
end

if nargout > 0
    ph = hObj;
end

end
