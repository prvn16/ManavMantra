function [pointCoords,triangles]=removeSteepTriangles(pointCoords,triangles,subdivide,dim,ds)

%   Copyright 2015-2017 The MathWorks, Inc.

  [pointCoords,triangles,~] = matlab.graphics.function.internal.removeUnusedPoints(pointCoords,triangles,[]);
  if isempty(triangles)
    return;
  end

  % viewing box size approximation
  vbox = max(pointCoords(1:3,:),[],2) - min(pointCoords(1:3,:),[],2);
  if ~isempty(ds) && isa(ds,'matlab.graphics.axis.dataspace.CartesianDataSpace')
    vbox = [ds.XLim; ds.YLim; ds.ZLim];
    vbox = max(vbox(:,2)-vbox(:,1),[],2);
  end
  vbox(vbox < 100*eps) = 100*eps;
  % scale to uniform width of 1 in each direction (ignoring translation)
  scaledPointCoords = bsxfun(@rdivide,double(pointCoords(1:3,:)),double(vbox));

  TR = triangulation(double(triangles),scaledPointCoords.');

  % We remove triangles that are adjacent to a feature edge (in particular, a sharp edge)
  % and with a normal pointing very close to the x/y axis
  edges = featureEdges(TR,pi/2-0.01);
  nodes = unique(edges(:));
  candidateTriangles = find(all(ismember(triangles,nodes),2));
  normals = faceNormal(TR,candidateTriangles);

  if isempty(normals)
    return;
  end

  steep = abs(normals(:,dim)) < 5e-2;

  % To avoid false positives, check each candidate for removal:
  % Triangles are removed if and only if for two of the three sides,
  % subdivision results in a point drastically closer to one end-point than the other.
  function b=doubleCheck(tri)
    pts = triangles(tri,:);
    pts = pointCoords(:,pts(1:3));
    newMid = [subdivide(pts(:,1),pts(:,2),[]), ...
              subdivide(pts(:,2),pts(:,3),[]), ...
              subdivide(pts(:,3),pts(:,1),[])];
    dist = @(i,j) sqrt(sum((newMid(1:3,i)-pts(1:3,j)).^2));
    reldists = [dist(1,1)/dist(1,2), dist(2,2)/dist(2,3), dist(3,3)/dist(3,1)];
    offCenter = (reldists < 0.4) | (reldists > 2.5);
    b = sum(offCenter) > 1 || any(isnan(newMid(:)));
  end

  steep(steep) = arrayfun(@doubleCheck,candidateTriangles(steep));

  triangles(candidateTriangles(steep),:) = [];
  [pointCoords,triangles,~] = matlab.graphics.function.internal.removeUnusedPoints(pointCoords,triangles,[]);
end
