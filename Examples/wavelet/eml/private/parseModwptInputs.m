function [lev,Lo,Hi,FullTree,TimeAlign] = parseModwptInputs( ...
    defaultLev,defaultWave,varargin)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.internal.prefer_const(defaultLev,defaultWave,varargin);
coder.inline('always');
ZERO = coder.internal.indexInt(0);
TimeAlign = false; % default TimeAlign
FullTree = false; % default FullTree
wnameSupplied = false;
filterSupplied = false;
ignoreWname = false;
levSupplied = false;
ntffilters = ZERO;
readTimeAlign = false;
TimeAlignSupplied = false;
readFullTree = false;
FullTreeSupplied = false;
lev = coder.internal.indexInt(defaultLev);
for k = coder.unroll(1:length(varargin))
    % Check for 'reflection' boundary
    if readTimeAlign
        TimeAlign = varargin{k} ~= 0;
        readTimeAlign = false;
        TimeAlignSupplied = true;
    elseif readFullTree
        FullTree = varargin{k} ~= 0;
        readFullTree = false;
        FullTreeSupplied = true;
    elseif ischar(varargin{k})
        if nargout >= 5 && ~TimeAlignSupplied && ...
                strncmpi(varargin{k},'TimeAlign',length(varargin{k}))
            readTimeAlign = true;
        elseif nargout >= 4 && ~FullTreeSupplied && ...
                strncmpi(varargin{k},'FullTree',length(varargin{k}))
            readFullTree = true;
        elseif ~wnameSupplied
            wname = varargin{k};
            wnameSupplied = true;
        else
            % The number of wavelet names supplied must be exactly one, or
            % else we ignore it.
            ignoreWname = true;
        end
    elseif coder.internal.isConst(isscalar(varargin{k})) && ...
            isscalar(varargin{k}) && ~levSupplied
        % Any scalar input must be the level
        lev = coder.internal.indexInt(varargin{k});
        levSupplied = true;
    elseif isnumeric(varargin{k})
        % If the user specifies a filter, use that instead of default
        % wavelet.
        ntffilters = ntffilters + 1;
        coder.internal.assert(ntffilters <= 2, ...
            'Wavelet:modwt:Invalid_Numeric');
        % If there are at least two numeric inputs, the first two must be
        % the scaling and wavelet filters
        if ntffilters == 1
            Lo = varargin{k};
        elseif ntffilters == 2
            Hi = varargin{k};
            filterSupplied = true;
            ignoreWname = true;
        end
    end
end
if filterSupplied
    coder.internal.assert(~wnameSupplied, ...
        'Wavelet:FunctionInput:InvalidWavFilter');
    coder.internal.assert(ntffilters == 2, ...
        'Wavelet:modwt:Invalid_Numeric');
    coder.internal.assert(length(Lo) >= 2 && length(Hi) >= 2, ...
        'Wavelet:modwt:Invalid_Filt_Length');
    % Ensure that Lo and Hi satisfy the orthogonality conditions
    coder.internal.assert(checkModwtFilter(Lo,Hi), ...
        'Wavelet:modwt:Orth_Filt');
else
    if ~wnameSupplied || ignoreWname
        wname = defaultWave;
    end
    [~,~,Lo,Hi] = wfiltersConst(wname);
    wtype = coder.const(feval('wavemngr','type',wname));
    coder.internal.assert(wtype == 1,'Wavelet:modwt:Orth_Filt');
end

%--------------------------------------------------------------------------
