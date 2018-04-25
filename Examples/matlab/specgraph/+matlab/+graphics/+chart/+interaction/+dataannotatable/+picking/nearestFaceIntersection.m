function [faceind, intPoint] = nearestFaceIntersection(point, verts, faces)
%nearestFaceIntersection Find the index of the face with the closest intersection
%
%  [faceind, intpoint] = nearestFaceIntersection(point, data, faces)
%  returns the index of the face whose intersection with the ray that
%  passes through the given point and is parallel to the z-axis, is
%  closest. It also returns a three-element vector that contains the 
%  [x y z] values of the intersection point.
%
%  It is assumed that the described ray does in fact intersect
%  each provided face: if this is not the case then faces will be
%  extrapolated and results may not be as expected.
%
%  It is also assumed that the faces are all planar.  If non-planar
%  polygons are provided then it will be assumed that they are planar and
%  the plane is defined by the first three vertices.  If you need to
%  perform hit-testing against non-planar polygons then you should first
%  triangulate with an appropriate algorithm before calling this function.
%
%  If the provided point only contains X and Y values then the Z value is
%  assumed to be a value smaller than that of any of the vertices, so that
%  the face picked is the one with the lowest intersection in the
%  direction of positive-Z.
%
%  If the provided data only contains X and Y values then the first face is
%  returned.
%
%  See also: intersectedFaces

%  Copyright 2013-2014 The MathWorks, Inc.

faceind = [];
intPoint = [];

if isempty(faces)
    return
end

point = point(:).';

if size(verts,1)==2 
    % We only have 2D face data, so we cannot work out which face is on top
    % of which other ones.
    faceind = 1;
    if numel(point)==2
        intPoint = [point 0];
    else
        intPoint = point;
    end
    
else
    TestAbsT = true;
    if numel(point)==2
        % Assume that Z values increase away from the viewer and take the
        % hittest point as the minimum vertex Z value. 
        point = [point 0];
        TestAbsT = false;
    end
    
    % Plane/ray intersection test
    
    % Perform plane/ray intersection with the faces. Grab the only the
    % first three vertices since that is all we need to define a plane,
    % assuming planar polygons.
    [v1, nplane] = getVertexAndNormal(verts, faces);
   
    % Compute intersection between plane and ray
    % t = (v1 - point) . nplane  / d.nplane.
    
    v1(1,:) = v1(1,:) - point(1);
    v1(2,:) = v1(2,:) - point(2);
    v1(3,:) = v1(3,:) - point(3);
    
    num = sum(v1.*nplane,1);
    
    % In this test, d = [0 0 -1], so we can calculate d.nplane very
    % efficiently
    denom = -nplane(3,:);
    
    t = num./denom;
    
    if TestAbsT
        % Find the intersection that is closest to the hit test point
        [~, faceind] = min(abs(t));
    else
        % Find the intersection with the lowest value.  This corresponds to
        % the largest t because we are looking down the negative z
        % direction.
        [~, faceind] = max(t);
    end
    
    % Determine intersection point
    intPoint = point;
    intPoint(3) = point(3) - t(faceind);
end



function [v1, nplane] = getVertexAndNormal(verts, faces)

% If triangle vertices (v1,v2,v3) are
% identical, results will be nan and will not be considered.

v1 = verts(:, faces(:,1));

% Get two vectors in the plane
% vec1 = (v2-v1);
% vec2 = (v3-v2);
vec1 = verts(:, faces(:,2));
vec2 = verts(:, faces(:,3));
vec2 = vec2-vec1;
vec1 = vec1-v1;

% Get normal to face plane.
nplane = cross(vec1,vec2);
