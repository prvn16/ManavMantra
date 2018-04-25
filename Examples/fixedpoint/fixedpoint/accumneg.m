function c = accumneg(a,b,varargin)
%ACCUMNEG Subtract two fi objects or values
%   C = accumneg(A,B) subtracts A and B using the data type of A 
%   and B is cast into A's type. It uses a default 'Floor' rounding method
%   and a default 'Wrap' overflow action when A is a fi object or an integer.
%   A and/or B can be fi objects or variables of class double, single,
%   logical or an integer. The fimath properties of A and B are ignored.
%
%   C = accumneg(A,B,RM) uses the specified rounding method RM and the
%   default 'Wrap' overflow action. Valid values of RM are 'Ceiling',
%   'Convergent', 'Floor', 'Nearest', 'Round', and 'Zero'.
%   RM is ignored when A is floating-point.
%   
%   C = accumneg(A,B,RM,OA) uses the specified rounding method RM and the
%   specified overflow action OA.  Valid values of RM are 'Ceiling',
%   'Convergent', 'Floor', 'Nearest', 'Round', and 'Zero'. Valid values of OA
%   are 'Saturate' and 'Wrap'. RM and OA are ignored when A is floating-point.
%
%   % Example
%   a = fi(pi,1,16,13);
%   b = fi(1.5,1,16,14);
%   c = accumneg(a,b);
%   d = accumneg(a,b,'Nearest','Saturate');
% 
%   See also ACCUMPOS, FI, FIMATH, FIXED.QUANTIZER

%#codegen

%   Copyright 2011-2012 The MathWorks, Inc.

if ~( (isnumeric(a) || islogical(a)) && (isnumeric(b) || islogical(b)) )
    if isempty(coder.target)
        error(message('fixed:fi:InvalidInputNotNumeric'));
    else
        eml_invariant(false, ...
            eml_message(message('fixed:fi:InvalidInputNotNumeric')));
    end
elseif isfi(a)
    c = accumulatefi(a, b, 'neg', varargin{:});
elseif isinteger(a)
    % BUILTIN integer (int8/16/32/64, uint8/16/32/64).
    % Cast b into a's equivalent FI class and do the subtraction using
    % FI's arithmetic rules (i.e., obey rounding and overflow settings).
    nt_a = numerictype(class(a));
    c_fi = accumulatefi(fi(a, nt_a), b, 'neg', varargin{:});
    c    = storedInteger(c_fi);
else
    % Cast b into a's class and do the subtraction
    c = cast((a - cast(b, class(a))), class(a));
end

