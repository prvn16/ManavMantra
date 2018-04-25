function varargout = quantize(q, varargin)
%QUANTIZE Quantize numeric data
%   Y = QUANTIZE(Q,X) uses the quantizer object Q to quantize X.  If X
%   is a cell array, then each numeric element of the cell array is
%   quantized.  If X is a structure, then each numeric field of X is
%   quantized.  Non-numeric elements or fields of X are left unchanged.
%
%   [Y1,Y2,...] = QUANTIZE(Q,X1,X2,...) is equivalent to
%   Y1=QUANTIZE(Q,X1), Y2=QUANTIZE(Q,X2), ....
%
%   Example:
%     warning on
%     q = quantizer('fixed', 'convergent', 'wrap', [3 2]);
%     x = (-2:eps(q)/4:2)';
%     y = quantize(q,x);
%     plot(x,[x,y],'.-'); axis square
%
%   See also QUANTIZER, EMBEDDED.QUANTIZER/ROUND

%   Thomas A. Bryan
%   Copyright 1999-2017 The MathWorks, Inc.
%     


if nargin > 1
    [varargin{:}] = convertStringsToChars(varargin{:});
end

varargout = varargin;
nargs = length(varargin);
oldnover = q.noverflows;
warn_state = warning;
warning('off');
for k=1:nargs
  x=varargin{k};
  
  % Quantize numeric arrays, the elements of cell arrays, and the fields of
  % structures, and skip anything else without warning or error.  The reason we
  % are skipping the rest without warning or error is so that strings can be
  % inserted into cells or structures.
  if ~isempty(x)
    if isnumeric(x) && ~isfi(x)
      % Quantize numeric arrays
      x = q.quantizenumeric(x);
    elseif iscell(x)
      % Recursively quantize the elements of cell arrays
      for i=1:length({x{:}})
        x{i} = quantize(q,x{i});
      end
    elseif isstruct(x)
      % Convert structures into cell arrays, call quantize with the cell array
      % syntax, and re-assemble the structure.
      for i=1:length(x)
        names = fieldnames(x(i));
        values = struct2cell(x(i));
        values = quantize(q,values); % Quantize the field values
        n = length({names{:}});
        c = cell(2,n);
        for j=1:n
          c{1,j} = names{j};
          c{2,j} = {values{j}};
        end
        x(i) = struct(c{:});
      end
    elseif isfi(x)
      warning(warn_state);
      error(message('fixed:quantizer:quantize_valueCannotBeFi'));
    end
  end
  % Set the output
  varargout{k} = x;
end

warning(warn_state)

% generates a warning message if
% Q.NOVERFLOWS > OLDNOVER (new overflows occurred
%   during a calculation)
newnover = q.noverflows-oldnover;
if newnover > 0
    warning(message('fixed:fi:overflow', newnover,'','quantize'));    
end
