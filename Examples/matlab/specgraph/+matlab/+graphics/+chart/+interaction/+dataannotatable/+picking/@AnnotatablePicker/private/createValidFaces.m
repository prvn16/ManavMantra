function [faces, validFaces] = createValidFaces(faces, validVerts)
%createValidFaces Create an array of faces that have valid vertices
%
%  createValidFaces(faces, validVerts) returns a modified faces array that
%  only contains faces where all the vertices are valid and also has its
%  vertex indices shifted to account for the invalid vertices that will be
%  removed.  A boolean vector that indicates which of the original faces
%  are valid is also returned.

%  Copyright 2014-2015 The MathWorks, Inc.

anyInvalid = ~all(validVerts);
if anyInvalid
    % Faces with invalid points need to be filtered out
    validFaces = findValidFaces(validVerts, faces);
    
    faces = faces(validFaces, :);
    
    % Remaining faces need to shift their non-NaN vertex indices to account
    % for the missing invalid data
    validMap = zeros(size(validVerts));
    validMap(validVerts) = 1:sum(validVerts);
    facenotnans = ~isnan(faces);
    faces(facenotnans) = validMap(faces(facenotnans));
else
    validFaces = true(size(faces, 1), 1);
end


function validFaces = findValidFaces(valid, faces)
validFaces = false(size(faces, 1), 1);
for n = 1:numel(validFaces)
    used_face = ~isnan(faces(n,:));
    validFaces(n) = all(valid(faces(n,used_face)));
end
