function varargout = hex2num(q, varargin)
%HEX2NUM Hexadecimal string to numeric array conversion
%   X = HEX2NUM(Q,H) converts hexadecimal string H to numeric matrix X.
%   The attributes of the number are specified by quantizer object Q.
%   If H is a cell array containing hexadecimal strings, then X will be
%   a cell array of the same dimension containing numeric matrices.
%   The fixed-point hexadecimal representation is two's complement.  The
%   floating-point hexadecimal representation is IEEE style.
%
%   If there are fewer hex digits than are necessary to represent the
%   number, then fixed-point zero-pads on the left, and floating-point
%   zero-pads on the right.
%
%   [X1,X2,...] = HEX2NUM(Q,H1,H2,...) converts hexadecimal strings H1,
%   H2, ... to numeric matrices X1, X2, ....
%
%   HEX2NUM and NUM2HEX are inverses of each other, except that NUM2HEX
%   always returns a column.
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   fractional form are given by:
%     q = quantizer([4 3]);
%     h = ['7  3  F  B'
%          '6  2  E  A'
%          '5  1  D  9'
%          '4  0  C  8'];
%     x = hex2num(q,h)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/NUM2HEX, 
%            EMBEDDED.QUANTIZER/BIN2NUM, EMBEDDED.QUANTIZER/NUM2BIN

%   Thomas A. Bryan
%   Copyright 1999-2017 The MathWorks, Inc.

if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

varargout = varargin;
nargs = length(varargin);

for k=1:nargs
  x=varargin{k};
  
  % HEX2NUM numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if isempty(x)
    % Return numeric empty
    x = [];
  else
    if ischar(x)
      % HEX2NUM character arrays
      x = hexstring2numeric(q,x);
    elseif iscell(x)
      % Recursively HEX2NUM the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = hex2num(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call HEX2NUM with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = hex2num(q,values); % HEX2NUM the field values
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


function y = hexstring2numeric(q,x)
[m,n] = stringsize(q,x);
xr = stringvectorize(q,stringreal(q,x));
xi = stringvectorize(q,stringimag(q,x));
if isfloat(q)
  y = hex2float(q,xr);
else
  y = base2num(q,xr,16);
end

if ~isempty(xi)
  % Complex
  if isfloat(q)
    y = y+i*hex2float(q,xi);
  else
    y = y+i*base2num(q,xi,16);
  end
end
y = reshape(y,m,n);
