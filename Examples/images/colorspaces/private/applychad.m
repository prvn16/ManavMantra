function out = applychad(in, adapter)
%APPLYCHAD Apply chromatic-adaptation transform.
%   OUT = applychad(IN, ADAPTER) applies a linear chromatic-adaptation
%   transform, ADAPTER, to XYZ data.  IN and OUT are n-by-3 arrays
%   representing n colors in CIE 1931 XYZ space in double precision.
%   ADAPTER is a 3-by-3 matrix depending on two white points, as is
%   computed by makecform('adapt', ... ).

%   Copyright 2009-2015 The MathWorks, Inc.
%   Original author:  Robert Poe 02/11/09


validateattributes(in, {'double'}, {'real', '2d', 'nonsparse', 'finite'}, ...
              'applychad', 'IN', 1);
if size(in, 2) ~= 3
    error(message('images:applychad:inColumns'));
end

% Check the chromatic-adaptation matrix:
validateattributes(adapter, {'double'}, {'nonempty', '2d', 'finite'}, ...
                'applychad', 'ADAPTER', 2);
if ~isequal(size(adapter), [3 3])
    error(message('images:applychad:adapterNot33'));
end

% Process data:
out = in * adapter';

