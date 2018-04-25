function s = tostring(u)
%TOSTRING  UNITQUANTIZER object to string.
%   S = TOSTRING(Q) converts UNITQUANTIZER object Q to a string.
%
%   Example:
%     q = unitquantizer
%     s = tostring(q)

%   Thomas A. Bryan, 6 May 1999
%   Copyright 1999-2010 The MathWorks, Inc.

% Convert to a regular quantizer object first, and then use the
% base class TOSTRING method with 'unit' prepended.
q = quantizer(get(u));
s = ['unit',tostring(q)];
