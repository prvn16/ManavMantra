function varargout = reducep(varargin)
%REDUCEP  Polygon reduction.
%   [VOUT, FOUT] = reduce(VERTICES, FACES, TARGETFACES, VERBOSE)
%   reduces the number of faces in the model describes by VERTICES
%   and FACES to TARGETFACES. 
%
%   Example:
%       [v f] = isosurf(flow, [], -3, 0, 1);
%       v = v'; f = f'; length(f)
%       [v f] = reducep(v, f, 700, 1); length(f)
%       p = patch('Vertices', v, 'Faces', f, 'FaceColor', 'red');
%       view(3); daspect([1 1 1])
%
%   See also REDUCEPATCH.

%   Copyright 1984-2007 The MathWorks, Inc. 
%#mex

error('MATLAB:reducep:MissingMexFile', ...
    'Missing MEX-file %s', upper(mfilename));


