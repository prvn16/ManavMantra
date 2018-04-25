function q = quantizer(varargin)
%QUANTIZER Constructor for QUANTIZER object
%   Q = QUANTIZER creates a quantizer with all default values.
%   Q = QUANTIZER('Property1',Value1, 'Property2',Value2,...) assigns
%   values associated with named properties.
%
%   Refer to QUANTIZER for a detailed help
%
%   See also QUANTIZER

%   Thomas A. Bryan
%   Copyright 1999-2010 The MathWorks, Inc.


% Built-in UDD constructor
q = embedded.quantizer;

if nargin > 0
  setquantizer(q,varargin{:});
end

