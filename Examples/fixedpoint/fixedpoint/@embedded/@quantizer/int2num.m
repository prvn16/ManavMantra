function varargout = int2num(q, varargin)
%INT2NUM Integer to numeric array conversion
%   Y = INT2NUM(Q,X) converts numeric matrix X containing integers to a matrix Y
%   containing the equivalent "real-world values" when Q is a fixed-point
%   quantizer.  The relationship between X and Y is Y = X*2^-fractionlength(Q).
%   The class of X is double, but the numeric values will be integers (i.e.,
%   floating-point integers, or flints).
%
%   If Q is a floating-point quantizer, then X is returned unchanged:
%   Y=X.
%
%   If X is a cell array containing numeric matrices, then Y will be a
%   cell array of the same dimension.
%
%   [Y1,Y2,...] = INT2NUM(Q,X1,X2,...) converts floating-point integer matrices
%   X1, X2, ... to numeric matrices Y1, Y2, ....
%
%   For example, all of the 4-bit fixed-point two's complement numbers in
%   integer form are given by:
%     x = [7   3  -1  -5
%          6   2  -2  -6
%          5   1  -3  -7
%          4   0  -4  -8];
%     q = quantizer([4 3]);
%     y = int2num(q,x)       % Convert to fractional form.
%
%   Note that int2num and num2int are inverses of one another.
%     num2int(q,y)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/HEX2NUM, 
%            EMBEDDED.QUANTIZER/NUM2HEX, EMBEDDED.QUANTIZER/BIN2NUM, 
%            EMBEDDED.QUANTIZER/NUM2BIN, EMBEDDED.QUANTIZER/NUM2INT

%   Thomas A. Bryan
%   Copyright 1999-2011 The MathWorks, Inc.
%     

varargout = varargin;
nargs = length(varargin);

switch lower(mode(q))
  case {'float','double','single','none'}
    warning(message('fixed:quantizer:invalidMode', 'INT2NUM', mode(q)));
    return  % Early return
end

if isa(q,'embedded.unitquantizer')
  % When converting to int with a unitquantizer, there is a chance to get
  % a number out of range (e.g., +1).  Hence, we change to a quantizer
  % object that uses the same quantizer as the input.  Using the same
  % quantizer preserves the states of the quantizer.
  q = quantizer(q);
end

for k=1:nargs
  x=varargin{k};
  
  % INT2NUMERIC numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x)
      % INT2NUMERIC numeric arrays
      x = int2numeric(q,x);
    elseif iscell(x)
      % Recursively INT2NUM the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = int2num(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call INT2NUM with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = int2num(q,values); % INT2NUM the field values
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


function x = int2numeric(q,x);
switch q.mode
  case {'fixed','ufixed'}
    x = x*2^-fractionlength(q);
end
x = quantize(q,x);

