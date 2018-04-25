function conn = conndef(num_dims,type)
%CONNDEF Default connectivity array.
%   CONN = CONNDEF(NUM_DIMS,TYPE) returns the connectivity array defined
%   by TYPE for NUM_DIMS dimensions.  TYPE can have either of the
%   following values:
%
%       'minimal'    Defines a neighborhood whose neighbors are touching
%                    the central element on an (N-1)-dimensional surface,
%                    for the N-dimensional case.
%
%       'maximal'    Defines a neighborhood including all neighbors that
%                    touch the central element in any way; it is
%                    ONES(REPMAT(3,1,NUM_DIMS)).
%
%   Several Image Processing Toolbox functions use CONNDEF to create the
%   default connectivity input argument.
%
%   Example
%   -------
%       conn2 = conndef(2,'min')
%       conn3 = conndef(3,'max')

%   Copyright 1993-2011 The MathWorks, Inc.

% I/O spec
% -------------
% Exactly two inputs required
%
% num_dims - a scalar integer >= 2.
% type - either 'minimal' or 'maximal', case-insensitive,
%        abbreviations OK.
%
% conn - connectivity

validateattributes(num_dims, {'numeric'}, {'integer', 'scalar',...
    '>=', 2}, 'conndef');

type = validatestring(type, {'minimal', 'maximal'},...
    'conndef');

switch type
    case 'minimal'
        conn = zeros(repmat(3,1,num_dims));
        conn((end+1)/2) = 1;
        stride = 3.^(0:num_dims-1);
        center = sum(stride)+1;
        for k = 1:num_dims
            conn(center-stride(k)) = 1;
            conn(center+stride(k)) = 1;
        end
        
    case 'maximal'
        conn = ones(repmat(3,1,num_dims));
end
