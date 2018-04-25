function BWP = bwpack(varargin) %#codegen
%Copyright 2013-2017 The MathWorks, Inc.

%#ok<*EMCA>

images.internal.coder.checkSupportedCodegenTarget(mfilename);

narginchk(1,1);
validateattributes(varargin{1}, {'logical','numeric'}, {'real','2d','nonsparse'}, ...
              mfilename, 'BW', 1);

BW = varargin{1};

if ~islogical(BW)
    BW1 = BW ~= 0;
else
    BW1 = BW;
end

BITS_PER_WORD = 32; %how many to be packed
zerosBWP = zeros(ceil(size(BW,1)/BITS_PER_WORD),size(BW,2));
if isempty(BW)
    BWP = uint32(zerosBWP);
    return;
else
    BWP = coder.nullcopy(uint32(zerosBWP));
end

% number of threads (obtained at compile time)
singleThread = images.internal.coder.useSingleThread();

if singleThread || coder.isRowMajor
    BWP = images.internal.coder.buildable.BwpackBuildable.bwpackc(...
                                                                BW1,  ...
                                                                BWP);    
else
    BWP = images.internal.coder.buildable.BwpacktbbBuildable.bwpackc(...
                                                                    BW1,  ...
                                                                    BWP);  
end


