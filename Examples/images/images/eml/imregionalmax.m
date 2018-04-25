function BW = imregionalmax(varargin) %#codegen
%IMREGIONALMAX Regional maxima.

%   Copyright 2012-2014 The MathWorks, Inc.

%#ok<*EMCA>


coder.internal.errorIf(nargin < 1,...
    'images:validate:tooFewInputs','IMREGIONALMAX');
coder.internal.errorIf(nargin > 2,...
    'images:validate:tooManyInputs','IMREGIONALMAX');

validateattributes(varargin{1}, {'numeric','logical'}, ...
    {'real','nonsparse','nonnan'}, 'imregionalmax', 'I', 1);
I = varargin{1};

if (nargin > 1)
    eml_invariant(eml_is_const(varargin{2}),...
        eml_message('images:validate:connNotConst'),...
        'IfNotConst','Fail');
    iptcheckconn(varargin{2},'imregionalmax','CONN',2);
    conn = varargin{2};
else
    conn = conndef(numel(size(I)), 'maximal');
end

connb = images.internal.getBinaryConnectivityMatrix(conn);

coder.extrinsic('images.internal.coder.useSharedLibrary');
if (coder.const(images.internal.coder.isCodegenForHost()) && ...
        coder.const(images.internal.coder.useSharedLibrary()) && ...
    coder.const(~(coder.isRowMajor && numel(size(I))>2)))
    % Shared libary
    BW    = coder.nullcopy(logical(I));
    fcnName = ['imregionalmax_', images.internal.coder.getCtype(I)];
    BW = images.internal.coder.buildable.ImregionalmaxBuildable.imregionalmaxcore_logical(...
        fcnName,...
        I,...
        BW,...
        ndims(I),...
        size(I),...
        connb,...
        ndims(connb),...
        size(connb));
    
else
    % Portable C
    BW = imregionalmaxAlgo(I, connb);
end
end


% Portable C code version
function bw = imregionalmaxAlgo(im, connb)
coder.inline('always');
coder.internal.prefer_const(im);
coder.internal.prefer_const(connb);

np = images.internal.coder.NeighborhoodProcessor(size(im), connb);
bw = true(size(im));

continuePropagation = true;
while(continuePropagation)
    bwpre     = bw;
    imParams.bw = bw;
    bw = np.process(im, @nhRegionalMaxAlgo, bw, imParams);
    % Repeat till there is no change
    continuePropagation = ~isequal(bwpre, bw);
end
end

% Process each pixel and its neighborhood
function pixelout = nhRegionalMaxAlgo(imnh, nhParams)
coder.inline('always');
pixelout = nhParams.bw(nhParams.ind);
if(nhParams.bw(nhParams.ind))
    %> Pixel has not already been set as non-max
    for pixelInd = 1:numel(imnh)
        if imnh(pixelInd)>nhParams.pixel
            %> Set pixel to zero if any neighbor is greater
            pixelout = false;
            return;
        end
        if (imnh(pixelInd)==nhParams.pixel ...
                && nhParams.bw(nhParams.imnhInds(pixelInd)) == false)
            %> Set pixel to zero if any equal neighbor is already set to zero
            pixelout = false;
            return;
        end
    end
end
end