%COPYOBJ Make copies of graphics object and its children.
%   C = COPYOBJ(H,P) copies each graphics object specified by 
%   the handle vector H, parented to the corresponding objects
%   specified in the vector P, and returns handles to the new 
%   objects in vector C, yielding length(H) new objects. The
%   copies are identical to the objects referred to by H
%   except that the 'Parent' property is changed to correspond
%   to P, as follows:
%       C(i) contains a copy of H(i) parented under P(i).
%   H and P must be the same length, and each pair
%   H(i) P(i) must be valid types for a parent/child
%   relationship, or no copies will be made.
%
%   C = COPYOBJ(H, p)
%   If H is a vector and p is a scalar, each object in H is
%   copied and parented under the object specified by p,
%   yielding length(H) new objects.
%
%   C = COPYOBJ(h, P)
%   If h is a scalar and P is a vector, copies of object h
%   are created as children of each object in vector P, yielding
%   length(P) new objects.
%   
%   C = COPYOBJ(..., 'legacy')
%   Copies the callbacks and application data of the objects. This
%   behavior is consistent with MATLAB releases prior to R2014b.
%
%   See also FINDOBJ.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   Built-in function.
