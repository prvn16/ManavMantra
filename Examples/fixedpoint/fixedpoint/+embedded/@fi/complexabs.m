function Y = complexabs(A,varargin)
%COMPLEXABS Absolute value of complex fi object
%   The absolute value (Y) of a complex input (A) is related to its 
%   real and imaginary parts by
%       Y = sqrt(real(A)*real(A) + imag(A)*imag(A))
%
%   COMPLEXABS supports the following syntaxes:
%
%   Y = COMPLEXABS(A) returns a fi object with a value equal to the absolute
%   value of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using the fimath associated with A. 
%
%   Y = COMPLEXABS(A,T) returns a fi object with a value equal to the 
%   absolute value of A and numerictype object T. 
%   Intermediate quantities are calculated using the fimath associated with
%   A. Data type propagation rules are followed (see Data Type Propagation 
%   Rules in 'help EMBEDDED.FI/ABS').
%
%   Y = COMPLEXABS(A,F) returns a fi object with a value equal to the
%   absolute value of A and the same numerictype object as A. 
%   Intermediate quantities are calculated using fimath object F.
%
%   Y = COMPLEXABS(A,T,F) returns a fi object with a value equal to the 
%   absolute value of A and with a numerictype object T. 
%   Intermediate quantities are calculated using fimath object F. Data type 
%   propagation rules are followed (see Data Type Propagation Rules in 
%   'help EMBEDDED.FI/ABS').
%
%
%   Example:
%     The following example illustrates typical usage of the COMPLEXABS
%     function.
%
%     a = fi(-1-i,1,16,15,'OverflowAction','Wrap')
%     t = numerictype(a.numerictype,'Signed',false)
%     complexabs(a,t)
%     % Returns a fi object with a value of 1.4142, the specified unsigned
%     % numerictype, and the same fimath object as a. Intermediate 
%     % quantities are also calculated using the same fimath object as 
%     % a.
%
%   See also EMBEDDED.FI/ABS, EMBEDDED.FIMATH/ABS, 
%            EMBEDDED.NUMERICTYPE/ABS, FI, EMBEDDED.FI/ABS

%   Copyright 1999-2012 The MathWorks, Inc.

[ntp, fmth, fimathSpecified] = parse_cabs_inputs(A,varargin{:});

if isscaledtype(ntp) && isempty(ntp.SignednessBool)
    % If Signedness is Auto (e.g. unspecified), then set the output type to
    % Unsigned. 
    ntp.SignednessBool = false;
end

if isfloat(ntp)
    if isdouble(ntp) || isdouble(A)
        Y = embedded.fi(abs(double(A)),ntp,fmth);
        Y.fimathislocal = false;
    else
        Y = embedded.fi(abs(single(A)),ntp,fmth);
        Y.fimathislocal = false;
    end
    return    
elseif isempty(A)
    Y = embedded.fi(double(real(A)),ntp,fmth);
    return
end

A_re = real(A); 
A_im = imag(A);

A_re_sq = fmth.mpy(A_re,A_re);
A_im_sq = fmth.mpy(A_im,A_im);

if isscaledtype(A) && issigned(A)
    ntp1 = numerictype(A_re_sq.numerictype,'Signed',false);
    A_re_sq = reinterpretcast(A_re_sq,ntp1);
    A_im_sq = reinterpretcast(A_im_sq,ntp1);
end

A_abs_sq = fmth.add(A_re_sq,A_im_sq);

% Turn off fixed:fi:sqrtOutputRangeTooSmall warning because it does not make sense in this context 
warning('off','fixed:fi:sqrtOutputRangeTooSmall');
Y = sqrt(A_abs_sq,ntp,fmth);
if ~(A.fimathislocal) || fimathSpecified
    Y.fimathislocal = false;
else
    Y.fimath = A.fimath;
end
warning('on','fixed:fi:sqrtOutputRangeTooSmall');


function [ntp_out, fmth_out, fimathSpecified] = parse_cabs_inputs(A,varargin)

fimathSpecified = false;

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
    ntp_out = A.numerictype;
    fimathSpecified = true;
    
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
    error(message('fixed:fi:invalidSyntax','abs'));
end

if (isboolean(A) || isboolean(ntp_out))
    error(message('fixed:fi:unsupportedComplexBoolean','abs'));
end

if (isslopebiasscaled(A.numerictype) || isslopebiasscaled(ntp_out))
    error(message('fixed:fi:unsupportedSlopeBias','abs'));    
end

if isfloat(A)&&(~isfloat(ntp_out))
    ntp_out = A.numerictype;
end

if isscaleddouble(A)&&isfixed(ntp_out)
    ntp_out.DataType = 'ScaledDouble';
end
