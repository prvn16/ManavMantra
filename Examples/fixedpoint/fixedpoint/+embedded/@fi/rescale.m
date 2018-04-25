function Y = rescale(this, varargin)
%RESCALE Change the scaling of a fixed-point number
%   B = RESCALE(A, FractionLength)
%   B = RESCALE(A, Slope, Bias)
%   B = RESCALE(A, SlopeAdjustmentFactor, FixedExponent, Bias)
%   B = RESCALE(A, ... , Parameter1,Value1, ...)
%   returns fi object B with the same stored-integer-value as A, but
%   with new scaling applied.  Only scaling parameters are allowed in
%   the parameter/value pairs.
%
%   RESCALE is similar to the FI copy constructor, except
%     (1) The FI constructor preserves the real-world-value, while RESCALE
%     preserves the stored-integer-value.
%     (2) RESCALE does not allow Signed and WordLength properties to be
%     changed.
%
%   Examples:
%
%     A = fi(10, 1, 8, 3);
%     B = rescale(A,1)
%     In this example, A's stored-integer-value is scaled by 2^-3, and 
%     B preserves the stored-integer-value of A, but changes the scaling to 2^-1. 
%     Thus, 
%       A has real-world-value 10 = (stored-integer-value 80)*2^-3
%       B has real-world-value 40 = (stored-integer-value 80)*2^-1
%
%   See also FI

%   Copyright 2004-2017 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

Y = this;

Y.data=0;  % No use re-quantizes all of the data.

% Find the number of leading numeric values.
nnumeric = 0;
for k=1:length(varargin)
  if ~isnumeric(varargin{k}) && ~islogical(varargin{k})
    break
  end
  nnumeric = nnumeric + 1;
end

% Find the position of the first char argument, which indicates the
% start of the parameter/value pairs.
nfirstchararg = realmax;
for k=1:length(varargin)
  if ischar(varargin{k})
    nfirstchararg = k;
    break
  end
end

switch nnumeric
  case 0
    % Nothing to be done.  No initial numeric arguments.
  case 1
    % 1   fi(A, fractionlength)
    Y.Scaling         = 'BinaryPoint';
    Y.FractionLength  = varargin{1};
  case 2
    % 5   fi(A, slope, bias)
    Y.Scaling         = 'SlopeBias';
    Y.Slope           = varargin{1};
    Y.Bias            = varargin{2};
  case 3
    % 6   fi(A, slopeadjustmentfactor, fixedexponent, bias)
    Y.Scaling               = 'SlopeBias';
    Y.SlopeAdjustmentFactor = varargin{1};
    Y.FixedExponent         = varargin{2};
    Y.Bias                  = varargin{3};
  otherwise
    error(message('fixed:fi:rescaleTooManyNumericArgs'));
end

% Process parameter/value pairs
setloopargs = varargin(nfirstchararg:end);
nsetloopargs = length(setloopargs);
if fix(nsetloopargs/2)~=nsetloopargs/2
  error(message('fixed:fi:rescaleInvalidParamValuePair'));
end
for k=1:2:nsetloopargs
  Y.(setloopargs{k}) = setloopargs{k+1};
  % LastPropertySet values are enumerated in fi.cpp
  switch LastPropertySet(Y)
    case 0
      % numerictype
      T = setloopargs{k+1};
      if strcmpi(T.Scaling,'Unspecified')
        error(message('fixed:fi:rescaleNoUnspecifiedScaling'));
      end
      if ~isequal(T.Signed, this.Signed)
        error(message('fixed:fi:rescaleNoSignChange'));
      end
      if ~isequal(T.WordLength, this.WordLength)
        error(message('fixed:fi:rescaleNoWordLengthChange'));
      end
      Y.numerictype = T;
    case {1,3,6,7,8,9,10,11}
      % DataTypeMode, Scaling
      % fractionlength, binarypoint, fixedexponent, slope, slopeadjustmentfactor, bias
      % One of the scaling properties has been set by a parameter/value pair.
      % All of these are allowed
    otherwise
      error(message('fixed:fi:rescaleInvalidPropertyChange',setloopargs{k}));
  end
end

% Copy over the stored integer after all the other parameters are set.
Y.intarray = this.intarray;
Y.fimathislocal = isfimathlocal(this);
