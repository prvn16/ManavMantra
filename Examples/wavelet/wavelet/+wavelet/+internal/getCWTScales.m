function [scales,s0] = getCWTScales(wname,nbSamp,ga,be,nv,varargin)
%   This function is for internal use only. It may change in a future
%   release.
%   [s0,scales] = getCWTScales(WAV,nbSamp,ga,be,nv,numsd,cutoff)

if strcmpi(wname,'morse')
    cutoff = 50;
else
    cutoff = 10;
end

% Number of pulse widths
p = 2;

if numel(varargin) == 1
    p = varargin{1};
    
elseif numel(varargin) == 2
    p = varargin{1};
    cutoff = varargin{2};
end

[~,~,maxScale,s0] = wavelet.internal.cwtfreqlimits(...
    wname,nbSamp,cutoff,ga,be,[],p,nv);

numoctaves = max(log2(maxScale/s0), 1/nv);

a0 = 2^(1/nv);
scales = s0*a0.^(0:numoctaves*nv);

