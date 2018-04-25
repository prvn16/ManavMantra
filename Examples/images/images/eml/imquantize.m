function [quant_a, index] = imquantize(varargin) %#codegen

% Copyright 2014 The MathWorks, Inc. 

narginchk(2,3);

%% parse
A    = varargin{1};
validateattributes(A,{'numeric'},{'nonsparse','real', 'nonnan'}, mfilename,'A',1); 

levels = varargin{2};
validateattributes(levels,{'numeric'},{'nonsparse','real','vector','nonnan','increasing'},...
    mfilename,'LEVELS',2);

if (nargin == 3)
    values = varargin{3};    
    validateattributes(values,{'numeric', 'logical'},{'nonsparse','real','vector'}, ...
        mfilename,'VALUES',3);
    
    % Check if length of 'values' is one greater than length of 'levels'
    coder.internal.errorIf(length(values) ~= (length(levels) + 1),...
        'images:imquantize:levelValuesLengthMismatch','VALUES','LEVELS');
    
    % The elements in VALUES need not be unique.
else    
    values = [];
end

%% process
N = length(levels);

% Compute the index values
% index = ones(size(A)); 
% for i = 1:N
%     index = index + (A > levels(i));
% end
index = coder.nullcopy(zeros(size(A)));
for pInd=1:numel(A)    
    
    offset = 1;
    % unroll small loops
    for lIndx = coder.unroll(1:N, eml_is_const(N) && N<10)
        offset = offset+(A(pInd)>levels(lIndx));
    end
    
    index(pInd) =  offset;
end

% Populate the quantized output using specified VALUES
if nargin < 3 % If VALUES is not specified as input    
    quant_a = index; % Use default values
else    
    quant_a_temp = values(index);
    if (isvector(index) && xor(isrow(index),isrow(quant_a_temp)))
        % Special case - when index (and input image) is a vector, and
        % values is vector of different orientation.
        quant_a = reshape(quant_a_temp,size(index));
    else
        quant_a = quant_a_temp;
    end 
end

end



