function BW = bwunpack(varargin) %#codegen
%Copyright 2013-2014 The MathWorks, Inc.

%#ok<*EMCA>

images.internal.coder.checkSupportedCodegenTarget(mfilename);

narginchk(1,2);
validateattributes(varargin{1}, {'uint32'}, {'real','2d','nonsparse'}, ...
              mfilename, 'BWP', 1);
BWP = varargin{1};
BITS_PER_WORD = 32; %Packing number

if nargin ~= 2
    M = BITS_PER_WORD * size(BWP,1);
else
    validateattributes(varargin{2}, {'numeric'}, {'scalar','integer','nonnegative'}, ...
                mfilename, 'M', 2);
    M = varargin{2};
end

if isempty(BWP)
    BW = false(M,size(BWP,2));
    return;
else
    BW = coder.nullcopy(false(M,size(BWP,2)));
end

% number of threads (obtained at compile time)
singleThread = images.internal.coder.useSingleThread();

if singleThread || coder.isRowMajor
    BW = images.internal.coder.buildable.BwunpackBuildable.bwunpackc(...
                                                                    BWP,  ...
                                                                    BW);
else
    BW = images.internal.coder.buildable.BwunpacktbbBuildable.bwunpackc(...
                                                                    BWP,  ...
                                                                    BW);      
end

