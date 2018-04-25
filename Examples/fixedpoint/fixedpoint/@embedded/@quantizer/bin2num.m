function varargout = bin2num(q, varargin)
%BIN2NUM Binary string to numeric array conversion
%   X = BIN2NUM(Q,B) converts binary string B to numeric matrix X.  The
%   attributes of the number are specified by quantizer object Q.  If B is a
%   cell array containing binary strings, then X will be a cell array of the
%   same dimension containing numeric matrices.  The fixed-point binary
%   representation is two's complement.  The floating-point binary
%   representation is IEEE style.
%
%   If there are fewer binary digits than are necessary to represent the number,
%   then fixed-point zero-pads on the left, and floating-point zero-pads on the
%   right.
%
%   [X1,X2,...] = BIN2NUM(Q,B1,B2,...) converts binary strings B1, B2,... to
%   numeric matrices X1, X2, ....
%
%   BIN2NUM and NUM2BIN are inverses of each other, except that NUM2BIN
%   always returns a column.
%
%   For example, all of the 3-bit fixed-point two's-complement numbers in
%   fractional form are given by:
%     q = quantizer([3 2]);
%     b = ['011  111'
%          '010  110'
%          '001  101'
%          '000  100'];
%     x = bin2num(q,b)
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/NUM2BIN, 
%            EMBEDDED.QUANTIZER/HEX2NUM, EMBEDDED.QUANTIZER/NUM2HEX

%   Thomas A. Bryan
%   Copyright 1999-2017 The MathWorks, Inc.


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

varargout = varargin;
nargs = length(varargin);

if isfixed(q) % Use fi to compute bin2num
    tempfi = fi(0,q);
end


for k=1:nargs
    x=varargin{k};
    
    % BIN2NUM numeric arrays, the elements of cell arrays, and the fields of
    % structures, and skip anything else without warning or error.  The reason we
    % are skipping the rest without warning or error is so that strings can be
    % inserted into cells or structures.
    if isempty(x)
        % Return numeric empty
        x = [];
    else
        if ischar(x)
            % BIN2NUM character arrays
            if isfixed(q) % If fixed-point quantizer use the fi created outside this for loop 
                tempfi.bin = x;
                x = double(tempfi);
            else
                x = binstring2numeric(q,x);
            end
        elseif iscell(x)
            % Recursively BIN2NUM the elements of cell arrays
            for i=1:length({x{:}})
                x{i} = bin2num(q,x{i});
            end
        elseif isstruct(x)
            % Convert structures into cell arrays, call BIN2NUM with the cell array
            % syntax, and re-assemble the structure.
            for i=1:length(x)
                names = fieldnames(x(i));
                values = struct2cell(x(i));
                values = bin2num(q,values); % BIN2NUM the field values
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
    
    

function y = binstring2numeric(q,x)
[m,n] = stringsize(q,x);
xr = stringvectorize(q,stringreal(q,x));
xi = stringvectorize(q,stringimag(q,x));
y = base2num(q,xr,2);

if ~isempty(xi)
  % Complex
  y = y+i*base2num(q,xi,2);
end
y = reshape(y,m,n);
