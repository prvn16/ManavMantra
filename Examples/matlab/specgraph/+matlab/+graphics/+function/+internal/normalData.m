function normals=normalData(pointCoords,triangles)
  % internal helper

%   Copyright 2015 The MathWorks, Inc.

  % compute a rough approximation to normals for a triangle mesh
  % For p = pointCoords(:,i), p(1:3) should be x,y,z values.
  % triangles: an n*3 indexing into the point list.

if isempty(triangles)
  normals = zeros(3,0,'single');
  return;
end
TR = triangulation(double(triangles),double(pointCoords(1:3,:)).');
normals = -single(vertexNormal(TR)).';
