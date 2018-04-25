function Y = reshape(this,varargin)
%RESHAPE Reshape array 
%   Refer to the MATLAB RESHAPE reference page for more information. 
%
%   See also RESHAPE 

%   Thomas A. Bryan, 6 February 2003
%   Copyright 1999-2012 The MathWorks, Inc.
%     

narginchk(2, inf);

if nargin==2
    if isnumeric(varargin{1})
        newsize = double(varargin{1});
    else
        error(message('fixed:fi:reshapeDimsNotRealInt'));
    end
else
  newsize = ones(1,length(varargin));
  nUnknownDims = 0;
  for k=1:length(varargin)
    if isscalar(varargin{k})
      newsize(k) = varargin{k};
    elseif isempty(varargin{k})
      nUnknownDims = nUnknownDims + 1;
      if nUnknownDims>1
        error(message('MATLAB:getReshapeDims:unknownDim'));
      end
      uknownIndex = k;
    else
      error(message('fixed:fi:reshapeDimsNotRealInt'));
    end
  end

  % Fill in the missing dimension, if there is one
  if nUnknownDims>0
    prodKnownDim = prod(double(newsize));
    unknownDim = numberofelements(this)/prodKnownDim;
    if fix(unknownDim) ~= unknownDim
        error(message('MATLAB:getReshapeDims:notDivisible',...
              prodKnownDim, numberofelements(this)));
    end
    newsize(uknownIndex) = unknownDim;
  end
end

% Validate the size vector
if length(newsize)==1
  error(message('MATLAB:getReshapeDims:sizeVector'));
end
if ~isvector(newsize)
  error(message('MATLAB:checkDimRow:rowSize'));
end
if ~all(newsize>=0)
  error(message('MATLAB:checkDimCommon:nonnegativeSize'));
end
if prod(double(newsize))~=numberofelements(this)
  error(message('MATLAB:getReshapeDims:notSameNumel'));
end

% Remove any trailing N-D singleton dimensions
if length(newsize)>2
  ntrailing_singletons = 0;
  for k=length(newsize):-1:3
    if newsize(k)~=1
      break
    end
    ntrailing_singletons = ntrailing_singletons + 1;
  end
  newsize((end-ntrailing_singletons+1):end) = [];
end

Y = fi_reshape(this,newsize);
