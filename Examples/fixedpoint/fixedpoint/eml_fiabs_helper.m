function [ntp_out, fmth_out, fimathSpecified] = eml_fiabs_helper(A,varargin)
%MATLAB Code Generation Library Function

%   Copyright 2007-2013 The MathWorks, Inc.

% fmth_out = A.fimath;
% ntp_out = A.numerictype;
fimathSpecified = false;
ntp_out = [];
fmth_out = [];

if isempty(varargin)
    % abs(A)                                                                                                                                
    fmth_out = A.fimath;
    ntp_out = A.numerictype;

elseif (nargin == 2)&&(isnumerictype(varargin{1}))
    % abs(A,T)
    fmth_out = A.fimath;
    ntp_out = varargin{1};

elseif (nargin == 2)&&(isfimath(varargin{1}))
    % abs(A,F)
    fmth_out = varargin{1};
    fimathSpecified = true;
    ntp_out = A.numerictype;

elseif (nargin == 3)&&(isnumerictype(varargin{1}))&&(isfimath(varargin{2}))
    % abs(A,T,F)
    ntp_out = varargin{1};
    fmth_out = varargin{2};
    fimathSpecified = true;
    
elseif (nargin == 3)&&(isnumerictype(varargin{2}))&&(isfimath(varargin{1}))
    % abs(A,F,T)
    fmth_out = varargin{1};    
    ntp_out = varargin{2};
    fimathSpecified = true;
else
    if isempty(coder.target)
        error(message('fixed:fi:invalidSyntax','ABS'));
    else
        eml_invariant(false, eml_message('fixed:fi:invalidSyntax','ABS'));
    end
end

if (isslopebiasscaled(A.numerictype) || isslopebiasscaled(ntp_out))
    if isempty(coder.target)
        error(message('fixed:fi:binaryPointOnlyFi_NT','ABS'));
    else
        eml_invariant(false, eml_message('fixed:fi:binaryPointOnlyFi_NT','ABS'));
    end
end

if isscaledtype(ntp_out) && isempty(ntp_out.SignednessBool)
    % If Signedness is Auto (e.g. unspecified), then set the output type to
    % Unsigned. 
    ntp_out.SignednessBool = false;
end
