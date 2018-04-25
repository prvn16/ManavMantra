function [Ty,Fy,fimathSpecified,methodName,errMsg] = eml_fisqrt_helper(x,varargin)
% EML_FISQRT_HELPER Helper function for fixed-point square root
% library function that parses the inputs and returns with a numerictype
% fimath and square root method

% Copyright 2006-2012 The MathWorks, Inc.
    
% Set up default return values
Ty = getNumericTypeForSqrt(x); Fy = fimath(x);
fimathSpecified = false;
methodName = 0; % bisection

switch nargin
  case 1 % sqrt(x)
    errMsg = '';
    return;
  case 2 % sqrt(x,T) or sqrt(x,F)
    var1 = varargin{1};
    if isnumerictype(var1)
        Ty = varargin{1};
        errMsg = '';
    elseif isfimath(var1)
        Fy = varargin{1};
        fimathSpecified = true;
        errMsg = '';
    else
        errMsg = getString(message('fixed:coder:fiInvalidMethodSignature','SQRT'));
    end
  case 3 % sqrt(x,T,F), sqrt(x,T,method) or sqrt(x,F,method)
    var1 = varargin{1};
    var2 = varargin{2};
    if ischar(var2) % sqrt(x,T,method) or sqrt(x,F,method)
        [methodName,errMsg] = parseCharInput(var2);
        if isnumerictype(var1)
            Ty = varargin{1};
        elseif isfimath(var1)
            Fy = varargin{1};
            fimathSpecified = true;
        end
    else % sqrt(x,T,F)
        Ty = var1;
        Fy = var2;
        fimathSpecified = true;
        errMsg = '';
    end
  case 4 % sqrt(x,T,F,methodname)
    var1 = varargin{1}; var2 = varargin{2};
    var3 = varargin{3};
    if isnumerictype(var1) && isfimath(var2) && ischar(var3)
        Ty =var1; Fy =var2; fimathSpecified = true;
        [methodName,errMsg] = parseCharInput(var3);
    else
        errMsg = getString(message('fixed:coder:fiInvalidMethodSignature','SQRT'));
    end
end

if isscaledtype(Ty) && isempty(Ty.SignednessBool)
    % fixedpoint:fi:sqrt:unspecifiedsign
    errMsg = getString(message('fixed:fi:sqrtUnspecifiedSign'));
end

%----------------------------------------------------------------------------
function [methodName,errMsg] = parseCharInput(varChar)
% Local function that parses a character input and returns
% the right method name or an error message
    
% Set up possible sqrt method names
sqrtMethodNames = {'bisection'};

validName = strmatch(lower(varChar),sqrtMethodNames);
 
if isempty(validName)
    methodName = [];
    errMsg = getString(message('fixed:fi:sqrtMethodNotFound', varChar));
    return;
elseif ~isscalar(validName)
    errMsg = getString(message('fixed:fi:sqrtMethodAmbiguous'));
    methodName = [];
else
    errMsg = '';
    methodName = validName-1;
end    

%-------------------------------------------------------------------------
function Ty = getNumericTypeForSqrt(x)
% Internal rule for output numerictype
xWL = x.WordLength;
xFL = x.FractionLength;
xIntL = xWL-xFL;
yIntL = ceil(xIntL/2);
yWL = ceil(xWL/2);
yFL = yWL-yIntL;
Ty = numerictype(x.Signed,yWL,yFL);
%----------------------------------------------------------------------
