function varargout = num2hex(q, varargin)
%NUM2HEX Number to hexadecimal string
%   H = NUM2HEX(Q,X) converts numeric matrix X to hexadecimal string H.
%   The attributes of the number are specified by Quantizer object Q.
%   If X is a cell array containing numeric matrices, then H will be a
%   cell array of the same dimension containing hexadecimal strings.
%   The fixed-point hexadecimal representation is two's complement.  The
%   floating-point hexadecimal representation is IEEE style.
%
%   [H1,H2,...] = NUM2HEX(Q,X1,X2,...) converts numeric matrices X1, X2,
%   ... to hexadecimal strings H1, H2, ....
%
%   NUM2HEX and HEX2NUM are inverses of each other, except that NUM2HEX
%   always returns a column.
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([4 3]);
%     x = [0.875    0.375   -0.125   -0.625
%          0.750    0.250   -0.250   -0.750
%          0.625    0.125   -0.375   -0.875
%          0.500        0   -0.500   -1.000];
%     h = num2hex(q,x)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/HEX2NUM, 
%            EMBEDDED.QUANTIZER/BIN2NUM, EMBEDDED.QUANTIZER/NUM2BIN

%   Thomas A. Bryan
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

varargout = varargin;
nargs = length(varargin);

if isa(q,'embedded.unitquantizer')
  % When converting to hex with a unitquantizer, there is a chance to get
  % a number out of range (e.g., +1).  Hence, we change to a quantizer
  % object that uses the same quantizer as the input.  Using the same
  % quantizer preserves the states of the quantizer.
  q = quantizer(q);
end

for k=1:nargs
  x=varargin{k};
  
  % NUMERIC2HEX numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x)
      % NUMERIC2HEX numeric arrays
      x = numeric2hex(q,x(:));
    elseif iscell(x)
      % Recursively NUM2HEX the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = num2hex(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call NUM2HEX with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = num2hex(q,values); % NUM2HEX the field values
        n = length({names{:}});
        c = cell(2,n);
        for j=1:n
          c{1,j} = names{j};
          c{2,j} = {values{j}};
        end
        x(i) = struct(c{:});
      end
    end
  end
  % Set the output
  varargout{k} = x;
end
