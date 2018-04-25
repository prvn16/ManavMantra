function varargout = ndgrid(varargin)
%NDGRID Generate arrays for N-D functions and interpolation
%   Refer to the MATLAB NDGRID reference page for more information.
%
%   See also NDGRID

%   Copyright 2010-2012 The MathWorks, Inc.


if nargin==0 || (nargin > 1 && nargout > nargin)
   error(message('MATLAB:ndgrid:NotEnoughInputs'));
end
if nargin==1
    if nargout == 1 || nargout == 0
        tmpout = varargin{1};
        subsrefInput = struct('type','()','subs',{{':'}});
        tmpout = subsref(tmpout,subsrefInput);
        varargout{1} = tmpout;  
        return
    else
        varargin = repmat(varargin,[1 max(nargout,2)]); 
    end
end
nin = length(varargin);
nout = max(nargout,nin);

siz = zeros(1,nout);
for i=length(varargin):-1:1,
  varargin{i} = full(varargin{i}); % Make sure everything is full
  siz(i) = numberofelements(varargin{i});
end
if length(siz)<nout, siz = [siz ones(1,nout-length(siz))]; end

varargout = cell(1,nout);
for i=1:nout,
  x = reshape(varargin{i},siz(i),1);
  s = siz; s(i) = []; % Remove i-th dimension
  x1 = repmat(x,1,prod(s)); % expand x: step 1
  x = reshape(x1,[length(x) s]); % expand x: step 2
  varargout{i} = permute(x,[2:i 1 i+1:nout]); % Permute to i'th dimension
end

