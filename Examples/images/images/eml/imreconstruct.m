function im = imreconstruct(marker, mask, varargin) %#codegen
%IMRECONSTRUCT Morphological reconstruction.

% Copyright 2012-2015 The MathWorks, Inc.

%#ok<*EMCA>

%% Input parsing

validateattributes(marker,...
    {'numeric','logical'},...
    {'real','nonsparse', 'nonnan'},...
    'imreconstruct');
validateattributes(mask,...
    {'numeric','logical'},...
    {'real','nonsparse','nonnan'},...
    'imreconstruct');

% marker and mask must be of the same numeric class
coder.internal.errorIf(~isa(marker, class(mask)),...
    'images:imreconstruct:notSameClass');

coder.internal.errorIf(~isequal(size(marker), size(mask)),...
    'images:imreconstruct:notSameSize');

if nargin==3
    conn = varargin{1};
    eml_invariant(eml_is_const(conn),...
        eml_message('images:validate:connNotConst'));
    iptcheckconn(conn,'imreconstruct','CONN',3);
else
    conn = conndef(numel(size(marker)), 'maximal');
end

%% Core
connb = images.internal.getBinaryConnectivityMatrix(conn);

singleThread = images.internal.coder.useSingleThread();
coder.extrinsic('images.internal.coder.useSharedLibrary');

useSharedLibrary = coder.const(images.internal.coder.isCodegenForHost()) && ...
    coder.const(images.internal.coder.useSharedLibrary()) && ...
    coder.const(~singleThread) && ...
    coder.const(~(coder.isRowMajor && numel(size(marker))>2));

if (useSharedLibrary)
    % Shared libary
    modeFlag           = getModeFlag(marker, connb);
    
    if(modeFlag==0)
        % Default code path
        fcnName = ['imreconstruct_', images.internal.coder.getCtype(marker)];
        im = images.internal.coder.buildable.ImreconstructBuildable.imreconstructcore(...
            fcnName,...
            marker,...
            mask,...
            ndims(marker),...
            size(marker),...
            connb,...
            ndims(connb),...
            size(connb));
        
    else
        % IPP code path
        if(islogical(marker))
            % logical and uint8 share the same ipp code paths
            ctype = 'uint8';
        else
            ctype = images.internal.coder.getCtype(marker);
        end
        fcnName = ['ippreconstruct_', ctype];
        im = images.internal.coder.buildable.IppreconstructBuildable.ippreconstructcore(...
            fcnName,...
            marker,...
            mask,...
            size(marker),...
            modeFlag);
    end
    
else
    % Portable C code
    im = imreconstructSequentialAlgo(marker, mask, connb);
end

end

%--------------------------------------------------------------------------
function marker = imreconstructSequentialAlgo(marker, mask, nhconn) %#codegen
% Portable C code generating version

coder.inline('always');
coder.internal.prefer_const(mask);
coder.internal.prefer_const(nhconn);

% Constrain marker to be within the mask
marker(marker>mask) = mask(marker>mask);

np = images.internal.coder.NeighborhoodProcessor(size(marker), nhconn,...
    'NeighborhoodCenter', images.internal.coder.NeighborhoodProcessor.NEIGHBORHOODCENTER.TOPLEFT);
np.updateInternalProperties();

numPixels = coder.internal.indexInt(numel(marker));

% When marker and mark are row vectors, the neighborhood indices must also 
% be row vectors.
if isrow(marker)
    % Forward sequential propagation
    for pInd = 1:numPixels
        imnhInds     = np.getNeighborIndices(pInd);
        maxnh        = max(marker(imnhInds'));
        marker(pInd) = min(maxnh,mask(pInd));
    end
    
    % Stack of pixel locations. Max size is a heuristic.
    locationStack = coder.nullcopy(...
        zeros(1,2*numPixels,coder.internal.indexIntClass()));
    stackTop = coder.internal.indexInt(0);
    
    % Inverse sequential propagation and stack population
    for pInd = numPixels:-1:1
        imnhInds     = np.getNeighborIndices(pInd);
        maxnh        = max(marker(imnhInds'));
        marker(pInd) = min(maxnh,mask(pInd));
        
        % Stack
        for ind = 1:numel(imnhInds)
            imnhInd = imnhInds(ind);
            if( marker(imnhInd)<marker(pInd) ...
                    && marker(imnhInd)<mask(imnhInd))
                % push
                stackTop = stackTop+1;
                locationStack(stackTop) = pInd;
                break;
            end
        end
        
    end
else
    % Forward sequential propagation
    for pInd = 1:numPixels
        imnhInds     = np.getNeighborIndices(pInd);
        maxnh        = max(marker(imnhInds));
        marker(pInd) = min(maxnh,mask(pInd));
    end
    
    % Stack of pixel locations. Max size is a heuristic.
    locationStack = coder.nullcopy(...
        zeros(1,2*numPixels,coder.internal.indexIntClass()));
    stackTop = coder.internal.indexInt(0);
    
    % Inverse sequential propagation and stack population
    for pInd = numPixels:-1:1
        imnhInds     = np.getNeighborIndices(pInd);
        maxnh        = max(marker(imnhInds));
        marker(pInd) = min(maxnh,mask(pInd));
        
        % Stack
        for ind = 1:numel(imnhInds)
            imnhInd = imnhInds(ind);
            if( marker(imnhInd)<marker(pInd) ...
                    && marker(imnhInd)<mask(imnhInd))
                % push
                stackTop = stackTop+1;
                locationStack(stackTop) = pInd;
                break;
            end
        end
        
    end
end

% Process stack
while(stackTop>0)
    % pop
    pInd = locationStack(stackTop);
    stackTop = stackTop - 1;
    
    imnhInds = np.getNeighborIndices(pInd);
    for ind = 1:numel(imnhInds)
        imnhInd = imnhInds(ind);
        if(marker(imnhInd) < marker(pInd)...
                && marker(imnhInd) ~= mask(imnhInd))
            marker(imnhInd) = min(marker(pInd), mask(imnhInd));
            % push
            stackTop = stackTop + 1;
            locationStack(stackTop) = imnhInd;
        end
    end
end

end

%--------------------------------------------------------------------------
function modeFlag = getModeFlag(marker, connb)

modeFlag = 0; % Default code-path

% IPP preference obtained and set at compile time
myfun = 'ippl';
coder.extrinsic('eml_try_catch');
[errid,errmsg, ippFlag] = eml_const(eml_try_catch(myfun));
eml_lib_assert(isempty(errmsg),errid,errmsg);


if (    ippFlag...
        &&...
        ismatrix(marker)...         % 2D
        && (...
        isa(marker,'logical') ||...
        isa(marker,'uint8')   ||...
        isa(marker,'uint16')  ||...
        isa(marker,'single')  ||...
        isa(marker,'double')    ...
        ))
    
    if( isequal(connb, [ false true false
            true  true true
            false true false]))
        modeFlag = 1;                       % four connectivity
    elseif(isequal(connb, true(3,3)))
        modeFlag = 2;                       % eight connectivity
    end
    
end

myArchfun = 'computer';
[archErrid, archErrmsg, archStr] = eml_const(eml_try_catch(myArchfun,'arch'));
eml_lib_assert(isempty(archErrmsg),archErrid,archErrmsg);

if(strcmp(archStr,'win32') && isa(marker, 'double'))
    % force default-code path
    modeFlag = 0;
end

end

