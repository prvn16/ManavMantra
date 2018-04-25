function q = istform(t)
%ISTFORM True for valid geometric transformation structure.
%   ISTFORM(T) returns 1 if R is a valid geometric transformation structure,
%   such as one created by MAKETFORM, and 0 otherwise.
% 
%   See also MAKETFORM, TFORMFWD, TFORMINV, FLIPTFORM.

%   Copyright 1993-2003 The MathWorks, Inc.

if nargin > 0
    t = convertStringsToChars(t);
end

q = isa(t,'struct') ...
    & isfield(t,'ndims_in') ...
    & isfield(t,'ndims_out') ...
    & isfield(t,'forward_fcn') ...
    & isfield(t,'inverse_fcn') ...
    & isfield(t,'tdata');
