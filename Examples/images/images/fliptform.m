function tflip = fliptform( t )
%FLIPTFORM Flip input and output roles of TFORM structure.
%   TFLIP = FLIPTFORM(T) creates a new spatial transformation structure (a
%   "TFORM struct") by flipping the roles of the inputs and outputs in an
%   existing TFORM struct.
%
%   Example
%   -------
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       T2 = fliptform(T);
%
%   The following are equivalent:
%       x = tformfwd([-3 7],T)
%       x = tforminv([-3 7],T2)
%
%   See also MAKETFORM, TFORMFWD, TFORMINV.

%   Copyright 1993-2015 The MathWorks, Inc.

if ~istform(t) || (length(t) ~= 1)
    error(message('images:fliptform:tMustBeSingleTformStruct'))
end

tflip = maketform('custom', t.ndims_out, t.ndims_in, t.inverse_fcn, ...
                  t.forward_fcn, t.tdata);
