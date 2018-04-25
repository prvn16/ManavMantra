function [pointCoords,triangles,innerBorders]=triangulateOnRegularMesh(fn,uRange,vRange,uNum,vNum)
  % internal function for function surface plotting

  % triangulateOnRegularMesh -- evaluate function on regular mesh, taking care of holes
  %
  %  fn - a (vectorized) function such that fn(u,v) returns a column vector p
  %  such that p(1:3) are xyz coordinates. When called with vectors u,v,
  %  p(1:3,:) should be such.
  %
  %  uRange, vRange - two-element increasing vectors specifying the range for u and v
  %
  %  uNum, vNum - integers specifying the number of values along each axis for the grid
  %
  %
  %  pointCoords: the point coordinates as returned by fn, horizontally concatenated
  %
  %  triangles: n*3 int32 array of indices into the columns of pointCoords.
  %  Oriented counterclockwise.
  %
  %  innerBorders: m*2 int32 array of indices into the columns of pointCoords.
  %  These indicate edges bordering regions where the function is not real-valued,
  %  i.e., borders of the triangulation apart from the outer edge of the ranges.

  % Copyright 2015 The MathWorks, Inc.

  % splitting a single square:
  pattern = [0 1 uNum, uNum+1 uNum 1].';
  % lower left corners of rectangles:
  rects = bsxfun(@plus,1:(uNum-1),uNum*(0:(vNum-2)).');

  [U,V] = meshgrid(linspace(uRange(1), uRange(2), uNum), linspace(vRange(1),vRange(2),vNum));
  pointCoords = fn(U(:),V(:));
  badPoints = any(~isfinite(pointCoords(1:3,:)) | imag(pointCoords(1:3,:))~=0,1);
  innerBorders = zeros(0,6);

  if ~any(badPoints)
    % frequent and simple, special case for performance
    pts = bsxfun(@plus,reshape(rects,1,[]),pattern);
    triangles = uint32(reshape(pts,3,[]));
    return;
  end

  function idx=addPointBetween(goodPoint,badPoint)
    newCoords = findRealBetween(fn,...
      pointCoords(1,goodPoint),pointCoords(2,goodPoint),...
      pointCoords(1,badPoint),pointCoords(2,badPoint));
    if isequal(newCoords, pointCoords(:,goodPoint)) || any(isnan(newCoords))
      idx = goodPoint;
    else
      pointCoords(:,end+1) = newCoords;
      idx = size(pointCoords,2);
    end
  end

  % around each bad point, find real values on the lines to real-valued neighbors
  right = zeros(uNum,vNum);
  up = zeros(uNum,vNum);
  for badPoint=find(badPoints)
    [u,v]=ind2sub([uNum,vNum],badPoint);
    if u > 1 && ~badPoints(badPoint-1)
      right(u-1,v) = addPointBetween(badPoint-1,badPoint);
    end
    if u < uNum && ~badPoints(badPoint+1)
      right(u,v) = addPointBetween(badPoint+1,badPoint);
    end
    if v > 1 && ~badPoints(badPoint-uNum)
      up(u,v-1) = addPointBetween(badPoint-uNum,badPoint);
    end
    if v < vNum && ~badPoints(badPoint+uNum)
      up(u,v) = addPointBetween(badPoint+uNum,badPoint);
    end
  end  

  triangles = zeros(3,0,'uint32');
  function addTriangle(p1,p2,p3)
    if p1==p2 || p1==p3 || p2 ==p3
      return;
    end
    assert(~any(any(isnan(pointCoords(:,[p1,p2,p3])))));
    triangles(:,end+1) = uint32([p1;p2;p3]);
  end

  function addInnerBorder(p1,p2,xymin,xymax)
    if p1==p2
      return;
    end
    innerBorders(end+1,:) = [p1,p2,pointCoords(1,xymin),pointCoords(1,xymax),pointCoords(2,xymin),pointCoords(2,xymax)];
  end

  % For each rectangle, add triangles
  for rect=rects(:).'
    corners = rect+[0 uNum uNum+1 1];
    undefs = badPoints(corners);
    switch sum(undefs.*[1 2 4 8])
    case 0 % no undefined corners
      addTriangle(corners(1),corners(2),corners(4));
      addTriangle(corners(4),corners(2),corners(3));
    case 1
      %  *----------*
      %  |       . /|
      %  |     .   ||
      %  |   .    / |
      %  | .     |  |
      %  *      /   |
      %   \_   |    |
      %     \_/     |
      %  O    *-----*
      addTriangle(right(corners(1)),corners(3),corners(4));
      addTriangle(right(corners(1)),up(corners(1)),corners(3));
      addTriangle(up(corners(1)),corners(2),corners(3));
      addInnerBorder(right(corners(1)),up(corners(1)),corners(1),corners(3));
    case 2
      addTriangle(right(corners(2)),corners(4),corners(3));
      addTriangle(right(corners(2)),up(corners(1)),corners(4));
      addTriangle(corners(1),corners(4),up(corners(1)));
      addInnerBorder(right(corners(2)),up(corners(1)),corners(1),corners(3));
    case 4
      addTriangle(corners(1),right(corners(2)),corners(2));
      addTriangle(corners(1),up(corners(4)),right(corners(2)));
      addTriangle(corners(1),corners(4),up(corners(4)));
      addInnerBorder(up(corners(4)),right(corners(2)),corners(1),corners(3));
    case 8
      addTriangle(corners(1),right(corners(1)),corners(2));
      addTriangle(corners(2),right(corners(1)),up(corners(4)));
      addTriangle(corners(2),up(corners(4)),corners(3));
      addInnerBorder(right(corners(1)),up(corners(4)),corners(1),corners(3));
    case 3
      %  O    *-----*
      %       |    /|
      %       |    ||
      %       |   / |
      %      /   |  |
      %      |  /   |
      %      | |    |
      %      |/     |
      %  O   *------*
      addTriangle(right(corners(1)),corners(4),corners(3));
      addTriangle(right(corners(1)),corners(3),right(corners(2)));
      addInnerBorder(right(corners(1)),right(corners(2)),corners(1),corners(3));
    case 6
      addTriangle(corners(1),corners(4),up(corners(1)));
      addTriangle(up(corners(1)),corners(4),up(corners(4)));
      addInnerBorder(up(corners(1)),up(corners(4)),corners(1),corners(3));
    case 12
      addTriangle(corners(1),right(corners(2)),corners(2));
      addTriangle(corners(1),right(corners(1)),right(corners(2)));
      addInnerBorder(right(corners(1)),right(corners(2)),corners(1),corners(3));
    case 9
      addTriangle(up(corners(1)),up(corners(4)),corners(2));
      addTriangle(corners(2),up(corners(4)),corners(3));
      addInnerBorder(up(corners(1)),up(corners(4)),corners(1),corners(3));
    case 5
      % too many lines for ASCII art
      addTriangle(up(corners(1)),right(corners(1)),corners(2));
      addTriangle(right(corners(1)),corners(4),corners(2));
      addTriangle(corners(4),right(corners(2)),corners(2));
      addTriangle(corners(4),up(corners(4)),right(corners(2)));
      addInnerBorder(up(corners(1)),right(corners(1)),corners(1),corners(3));
      addInnerBorder(up(corners(4)),right(corners(2)),corners(1),corners(3));
    case 10
      addTriangle(corners(1),right(corners(1)),up(corners(4)));
      addTriangle(corners(1),up(corners(4)),corners(3));
      addTriangle(corners(1),corners(3),up(corners(1)));
      addTriangle(up(corners(1)),corners(3),right(corners(2)));
      addInnerBorder(right(corners(1)),up(corners(4)),corners(1),corners(3));
      addInnerBorder(up(corners(1)),right(corners(2)),corners(1),corners(3));
    case 7
      %  O       O
      %
      %          *
      %         /|
      %        / |
      %  O    *--*
      addTriangle(right(corners(1)),corners(4),up(corners(4)));
      addInnerBorder(up(corners(4)),right(corners(1)),corners(1),corners(3));
    case 14
      addTriangle(corners(1),right(corners(1)),up(corners(1)));
      addInnerBorder(right(corners(1)),up(corners(1)),corners(1),corners(3));
    case 13
      addTriangle(corners(2),right(corners(2)),up(corners(1)));
      addInnerBorder(right(corners(2)),up(corners(1)),corners(1),corners(3));
    case 11
      addTriangle(right(corners(2)),up(corners(4)),corners(3));
      addInnerBorder(right(corners(2)),up(corners(4)),corners(1),corners(3));
    % nothing to do in case 15
    end
  end

  [pointCoords,triangles,innerBorders] = matlab.graphics.function.internal.removeUnusedPoints(pointCoords,triangles,innerBorders);
end

function pointCoords=findRealBetween(fn,u1,v1,u2,v2)
  % assuming fn is real and finite at [u1,v1] and not at [u2,v2],
  % find a place between the two where it is.
  % Trying to get far away from [u1,v1] and obtain a long line, of course.

  for i=1:15
    uCenter = (u1+u2)/2;
    vCenter = (v1+v2)/2;
    pointCoords = fn(uCenter,vCenter);
    good = all(isfinite(pointCoords(1:3,:)) & imag(pointCoords(1:3,:))==0,1);
    u1(good) = uCenter(good);
    v1(good) = vCenter(good);
    u2(~good) = uCenter(~good);
    v2(~good) = vCenter(~good);
  end
  pointCoords(:,~good) = fn(u1(~good),v1(~good));
end
