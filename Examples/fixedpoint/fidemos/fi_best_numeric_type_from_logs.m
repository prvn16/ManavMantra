function T = fi_best_numeric_type_from_logs(x, is_signed, word_length)
%FI_BEST_NUMERIC_TYPE_FROM_LOGS  Best fixed-point numeric type from min/max logs.
%    T = FI_BEST_NUMERIC_TYPE_FROM_LOGS(X, IS_SIGNED, WORD_LENGTH)
%    returns the best-precision fixed-point NUMERICTYPE object T based
%    on the min/max logs of FI object X, and whether the target
%    fixed-point data type IS_SIGNED (true/false) and the target
%    fixed-point WORD_LENGTH.
%
%    See FI_DATATYPE_OVERRIDE_DEMO for an example of use.

%    Copyright 2005 The MathWorks, Inc.

% Compute the range of the min/max logs.
A = max(abs(double(minlog(x))),abs(double(maxlog(x))));

% Compute the integer part such that the range will not overflow.
integer_part = ceil(log2(A));

% Compute the fraction length.
fraction_length = word_length - integer_part - double(logical(is_signed));

% Construct the fixed-point numeric type object.
T = numerictype(is_signed, word_length, fraction_length);


