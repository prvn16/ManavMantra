function varargout = iswt(varargin)
%ISWT Inverse discrete stationary wavelet transform 1-D.
%   ISWT performs a multilevel 1-D stationary wavelet 
%   reconstruction using either a specific orthogonal wavelet  
%   ('wname', see WFILTERS for more information) or specific 
%   reconstruction filters (Lo_R and Hi_R).
%
%   X = ISWT(SWC,'wname') or X = ISWT(SWA,SWD,'wname') 
%   or X = ISWT(SWA(end,:),SWD,'wname') reconstructs the 
%   signal X based on the multilevel stationary wavelet   
%   decomposition structure SWC or [SWA,SWD] (see SWT).
%
%   For X = ISWT(SWC,Lo_R,Hi_R) or X = ISWT(SWA,SWD,Lo_R,Hi_R),  
%   or X = ISWT(SWA(end,:),SWD,Lo_R,Hi_R),
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%
%   See also IDWT, SWT, WAVEREC.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 08-Dec-97.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
nbIn = nargin;
narginchk(2,4);
switch nbIn
  case 2 , argstr = 1; argnum = 2;
  case 4 , argstr = 0; argnum = 3;
  case 3
      if ischar(varargin{3})
          argstr = 1; argnum = 3;
      else
          argstr = 0; argnum = 2;
      end
end

% Compute reconstruction filters.
if argstr && ischar(varargin{argnum})
    wtype = wavemngr('type',varargin{argnum});
    if ~any(wtype == [1 2])
        error(message('Wavelet:FunctionInput:OrthorBiorthWavelet'));
    end
    [lo_R,hi_R] = wfilters(varargin{argnum},'r');
else
    if nargin < argnum+1
        error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
    end
    lo_R = varargin{argnum};
    hi_R = varargin{argnum+1};

    validateattributes(lo_R,{'numeric'},...
        {'vector','finite','real'},'iswt','Lo_R',argnum);
    validateattributes(hi_R,{'numeric'},...
        {'vector','finite','real'},'iswt','Hi_R',argnum+1);

    % The filters must have an even length greater than 2.
    if (length(lo_R) < 2) || (length(hi_R) < 2) || ...
            mod(length(lo_R),2) || mod(length(hi_R),2)
        error(message('Wavelet:FunctionInput:Invalid_Filt_Length'));
    end
end

% Get inputs.
if argnum == 2
    validateattributes(varargin{1}, {'numeric'}, {'2d', 'real'}, ...
        'iswt', 'SWC', 1);
    p = size(varargin{1},1);
    n = p-1;
    d = varargin{1}(1:n,:);
    a = varargin{1}(p,:);
else
    validateattributes(varargin{1}, {'numeric'}, {'2d', 'real'}, ...
        'iswt', 'SWA', 1);
    validateattributes(varargin{2}, {'numeric'}, {'2d', 'real'}, ...
        'iswt', 'SWD', 2);
    a = varargin{1};
    d = varargin{2};
end
a      = a(size(a,1),:);
[n,lx] = size(d);
for k = n:-1:1
    step = 2^(k-1);
    last = step;
    for first = 1:last
      ind = first:step:lx;
      lon = length(ind);
      subind = ind(1:2:lon);
      x1 = idwtLOC(a(subind),d(k,subind),lo_R,hi_R,lon,0);
      subind = ind(2:2:lon);
      x2 = idwtLOC(a(subind),d(k,subind),lo_R,hi_R,lon,-1);
      a(ind) = 0.5*(x1+x2);
    end
end
varargout{1} = a;


%===============================================================%
% INTERNAL FUNCTIONS
%===============================================================%
function y = idwtLOC(a,d,lo_R,hi_R,lon,shift)

y = upconvLOC(a,lo_R,lon) + upconvLOC(d,hi_R,lon);
if shift==-1
    y = y([end,1:end-1]);
end
%---------------------------------------------------------------%
function y = upconvLOC(x,f,l)

lf = length(f);
y  = dyadup(x,0,1);
y  = wextend('1D','per',y,lf/2);
y  = wconv1(y,f);
y  = wkeep1(y,l,lf);
%===============================================================%
