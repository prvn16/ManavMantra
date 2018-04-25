function B = morphopAlgo(A, nhood , height, op_type, B) %#codegen

%   Copyright 2014-2017 The MathWorks, Inc.

nhood   = coder.const(nhood);
height  = coder.const(height);
op_type = coder.const(op_type);

if(isempty(A))
    return;
end

if(isfloat(A))
    minVal = -inf('like',A);
    maxVal =  inf('like',A);
elseif(islogical(A))
    minVal = false;
    maxVal = true;
else % integer
    minVal = intmin(class(A));
    maxVal = intmax(class(A));
end

%% Edge case - handle empty nhoods
if(isempty(nhood))
    switch(op_type)
        case 'dilate'
            val = minVal;
        case 'erode'
            val = maxVal;
        otherwise
            assert(false,'Unknown operation');
    end
    for lind = 1:numel(A)
        B(lind) = val;
    end
    return;
end

%% Core implementation
switch (op_type)
    case 'dilate'
        initVal = double(minVal);
        
        % Reflect nhood
        if(ismatrix(A))
            % If ndims(nhood)>2, then trailing nhood dimension dont count.
            % Effectively, reflect only the first plane. (the rest get
            % flipped, but they are 'dont-cares').
            nhood  = flip(flip(nhood,1),2);
            height = flip(flip(height,1),2);
        else
            nhood(1:end)  = nhood(end:-1:1);
            height(1:end) = height(end:-1:1);
        end
        
        if(all(height(:)==0))
            np = images.internal.coder.NeighborhoodProcessor(size(A),nhood);
        else
            np = images.internal.coder.NeighborhoodProcessor(size(A),nhood,...
                'NeighborhoodCenter', images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT);
        end
        
        params.initVal = initVal;
        params.height  = height;
        B = np.process(A, @dilateAlgo, B, params);
        
    case 'erode'
        initVal = double(maxVal);
        
        np = images.internal.coder.NeighborhoodProcessor(size(A),nhood,...
            'NeighborhoodCenter', images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT);
        
        params.initVal = initVal;
        params.height  = height;
        B = np.process(A, @erodeAlgo, B, params);
        
    otherwise
        assert(false,'Unknown operation');
end

end


function pixelout = dilateAlgo(imnh, params)
% Find maximum in pixel neighborhood
coder.inline('always');
for pind=1:numel(imnh)
    imnh(pind)     = double(imnh(pind)) + params.height(params.nhInds(pind));
end
pixelout = max([imnh(:); params.initVal]);
end

function pixelout = erodeAlgo(imnh, params)
% Find minimum in pixel neighborhood
coder.inline('always');
for pind=1:numel(imnh)
    imnh(pind)     = double(imnh(pind)) - params.height(params.nhInds(pind));
end
pixelout = min([imnh(:); params.initVal]);
end