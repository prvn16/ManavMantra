function B = impyramid(A, direction) %#codegen

%   Copyright 2015 The MathWorks, Inc.

validateattributes(A, {'numeric', 'logical'}, {}, mfilename, 'A', 1);
direction = validatestring(direction, {'reduce', 'expand'}, ...
    mfilename, 'DIRECTION', 2);
coder.internal.prefer_const(direction);

M = size(A,1);
N = size(A,2);
coder.internal.prefer_const(M);
coder.internal.prefer_const(N);

switch(direction)
    case 'reduce'
        outputSize = ceil([M N]/2);
        B = imresize(A, 'Method', 'preduce', ...
            'OutputSize', outputSize, 'Antialiasing', false);
        
    case 'expand'
        outputSize = 2*[M N] - 1;
        B = imresize(A, 'Method', 'pexpand', ...
            'OutputSize', outputSize, 'Antialiasing', false);
    otherwise
        assert(false, 'Unsupported direction');
        B = A;
end

end

