function [pointCoords,triangles,innerBorders]=removeUnusedPoints(pointCoords,triangles,innerBorders)
  % remove infinite points

%   Copyright 2015 The MathWorks, Inc.

  badPoints = find(any(~isfinite(pointCoords),1));
  badTriangles = any(ismember(triangles,badPoints),2);
  triangles(:,badTriangles) = [];
  % remove all points that are not used in any triangle
  % (happens for small lines between non-real regions)
  pointsUsed = unique(triangles);
  if isempty(pointsUsed)
    pointCoords = pointCoords(:,[]);
    return;
  end
  if numel(pointsUsed) ~= pointsUsed(end)
    renumber(pointsUsed) = uint32(1:numel(pointsUsed));
    pointCoords = pointCoords(:,pointsUsed);
    triangles = arrayfun(@(k)renumber(k),triangles);
    if ~isempty(innerBorders)
      innerBorders(:,1:2) = arrayfun(@(k)renumber(k),innerBorders(:,1:2));
    end
  end
end
