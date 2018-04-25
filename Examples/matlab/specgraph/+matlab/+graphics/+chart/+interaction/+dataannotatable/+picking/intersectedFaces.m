function faceind = intersectedFaces(point, verts, faces)
%intersectedFaces Find the indices of the intersected faces
%
%  intersectedFaces(point, data, faces) returns the indices of the faces
%  that visually enclose the provided point.  The algorithm used is the
%  same one used by the graphics rendering system, so that results will
%  always match the appearance of objects.

%  Copyright 2013-2014 The MathWorks, Inc.

% Determine faces that enclose the target by performing the 2-D crossing
% test (Jordan Curve Theorem). A polygon is intersected if it traverses an
% odd number of polygon edges along any positive axis.

% Begin by subtracting out the point to normalize the coordinates:
% Store the old pixel locations:
verts(1,:) = verts(1,:) - point(1);
verts(2,:) = verts(2,:) - point(2);

% Remove NaNs from the faces definition
faces = local_fixFacesNaNs(faces);

finite = isFiniteFace(verts, faces);
if ~any(finite)
    % Set faces to empty so that the return will be empty
    faces = zeros(0,3);
elseif ~all(finite)
    % Set the affected faces to all use the first finite vertex for every
    % face vertex.  This will mean they cannot be intersected.
    faces(~finite,:) = find(finite,1);
end

% Find all vertices that have y components less than zero
neg_y_verts = verts(2,:)<0;
vert_with_negative_y = neg_y_verts(faces);
vert_with_negative_y_shifted = vert_with_negative_y(:, [2:end 1]);

% Find all the line segments that span the x axis
is_line_segment_spanning_x = xor(vert_with_negative_y, vert_with_negative_y_shifted);

% Find all the faces that have line segments that span the x axis
is_face_spanning_x = any(is_line_segment_spanning_x,2);

if any(is_face_spanning_x)
    % Ignore data that doesn't span the x axis
    candidate_faces = faces(is_face_spanning_x,:);
    vert_with_negative_y = vert_with_negative_y(is_face_spanning_x,:);
    is_line_segment_spanning_x = is_line_segment_spanning_x(is_face_spanning_x,:);
    
    % Create line segment arrays
    pt1 = candidate_faces;
    pt2 = candidate_faces(:,[2:end 1]);
    
    % Point 1
    x1 = reshape(verts(1,pt1),size(pt1));
    y1 = reshape(verts(2,pt1),size(pt1));
    
    % Point 2
    x2 = reshape(verts(1,pt2),size(pt2));
    y2 = reshape(verts(2,pt2),size(pt2));
    
    % Cross product of vector to origin with line segment
    cross_product_test = -x1.*(y2-y1) > -y1.*(x2-x1);
    
    % Special case for intersecting on a vertical edge
    vert_edge_test = (x1==0 & x2==0);
    
    % Find all line segments that cross the positive x axis
    crossing_test = ~xor(vert_edge_test | cross_product_test, vert_with_negative_y) & is_line_segment_spanning_x;
    
    % If the number of line segments is odd, then we intersected
    % the polygon (Jordan Curve Theorem)
    s = sum(crossing_test,2);
    s = mod(s,2);
    faceind = find(s>0);
    
    % Translate back to an index into the original faces
    if ~isempty(faceind) && ~all(is_face_spanning_x)
        tmp = find(is_face_spanning_x, max(faceind));
        faceind = tmp(faceind);
    end
    faceind = faceind(:).';
else
    faceind = zeros(1,0);
end


function finite = isFiniteFace(verts, faces)
% Check whether each face includes any non-finite vertices

finiteVerts = all(isfinite(verts), 1);
if all(finiteVerts)
    finite = true(size(faces,1),1);
else
    finite = all(reshape(finiteVerts(faces), size(faces)), 2);
end


function faces = local_fixFacesNaNs(faces)
% Nans in the faces matrix occur and are valid; they are used when there
% are faces with different numbers of vertices.  However the intersection
% algorithm needs a NaN-free matrix.  This function replaces NaNs with
% an adjacent vertex index from that face.  These repeated vertices do not
% alter the result of the intersection algorithm.

facenans = isnan(faces);
if any(facenans(:))
    % Check for rows that are all NaNs.  For these we'll just repeat the
    % first vertex - since repeated vertices don't cross any axis this will
    % not cause a false positive intersection.
    badRows = all(facenans, 2);
    faces(badRows,:) = 1;
    facenans(badRows,:) = false;
    
    % To handle NaNs in the first column we'll find the first non-NaN value
    % in each row and copy that into the first column
    [~,FirstNonNanIndex]=max(~facenans,[],2);
    faces(facenans(:,1),1) = FirstNonNanIndex(facenans(:,1));
    
    % For each remaining column, check for NaNs in each row, and change them
    % to be the same face index as the previous value in that row.
    for n = 2:size(faces, 2)
        faces(facenans(:,n),n) = faces(facenans(:,n),n-1);
    end
end
