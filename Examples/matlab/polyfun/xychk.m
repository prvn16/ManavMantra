function [msg,x,y,xi] = xychk(varargin)
%XYCHK  Check arguments to 1-D and 2-D data routines.
%   [MSG,X,Y] = XYCHK(Y), or
%   [MSG,X,Y] = XYCHK(X,Y), or
%   [MSG,X,Y,XI] = XYCHK(X,Y,XI) checks the input arguments and returns
%   either an error structure in MSG or valid X,Y (and XI) data.  MSG is
%   empty when there is no error.  X must be a vector and Y must have
%   length(x) rows (or be a vector itself).
%
%   [MSG,X,Y] = XYCHK(X,Y,'plot') allows X and Y to be matrices by
%   treating them the same as PLOT does.

%   Copyright 1984-2016 The MathWorks, Inc.

narginchk(1,3);

nin = nargin; x = []; y = []; xi = [];

msg.message = '';
msg.identifier = '';
msg = msg(zeros(0,1));

if nin > 1 && (ischar(varargin{end}) || (isstring(varargin{end}) && isscalar(varargin{end})))
  plot_flag = 1;
  nin = nin - 1;
else
  plot_flag = 0;
end

if nin==1 % xychk(y)
  if (ischar(varargin{1}) || (isstring(varargin{1}) && isscalar(varargin{1})))
    msg(1).identifier = 'MATLAB:xychk:nonNumericInput'; 
    msg(1).message = getString(message(msg(1).identifier));
    return
  end
  y = varargin{1};
  if ndims(y)>2
      msg(1).identifier = 'MATLAB:xychk:non2DInput'; 
      msg(1).message = getString(message(msg(1).identifier));
      return, 
  end
  if isnumeric(y) && ~isreal(y) % Deal with complex data case.
    if min(size(y))>1 && plot_flag
      msg(1).identifier = 'MATLAB:xychk:nonComplexVectorInput';
      msg(1).message = getString(message(msg(1).identifier));
    end
    x = real(y); y = imag(y);
    return
  end
  if plot_flag==1 && min(size(y))==1, y = y(:); end
  if min(size(y))==1
    x = reshape(1:length(y),size(y));
  else
    x = (1:size(y,1))';
  end
  if plot_flag==1 && min(size(y))>1
      x = x(:,ones(1,size(y,2))); 
  end

elseif nin>=2 % xychk(x,y) or xychk(x,y,xi) or xychk(x,y,flag)
  x = varargin{1};
  y = varargin{2};
  if ndims(x)>2 || ndims(y)>2 
    msg(1).identifier = 'MATLAB:xychk:non2DInput';
    msg(1).message = getString(message(msg(1).identifier));
    return 
  end
  if nin==3, xi = varargin{3}; end
  if ~plot_flag % xychk(x,y,...)
      if min(size(x))>1
          msg(1).identifier = 'MATLAB:xychk:XNotAVector';
          msg(1).message = getString(message(msg(1).identifier));
          return, 
      end
      if min(size(x))==1, x = x(:); end
      if min(size(y))>1 % y is a matrix
        if length(x)~=size(y,1)
          msg(1).identifier = 'MATLAB:xychk:lengthXDoesNotMatchNumRowsY';
          msg(1).message = getString(message(msg(1).identifier));
          return
        end
      else % y is a vector
        if length(x) ~= length(y)
          msg(1).identifier = 'MATLAB:xychk:XAndYLengthMismatch';
          msg(1).message = getString(message(msg(1).identifier));
          return
        end
        % Make sure x has the same orientation as y.
        x = reshape(x,size(y));
      end
  else % xychk(x,y,'plot')
      isvectorY = min(size(y)) == 1;    % false when y empty
      if min(size(x))==1, x = x(:); end
      if isvectorY,       y = y(:); end
      % Copy x as columns.
      if size(x,2)==1, x = x(:,ones(1,size(y,2))); end
      if ~isvectorY && (size(x,1) ~= size(y,1))
        msg(1).identifier = 'MATLAB:xychk:lengthXDoesNotMatchNumRowsY';
        msg(1).message = getString(message(msg(1).identifier));
        return
      elseif isvectorY && length(x) ~= length(y)
        msg(1).identifier = 'MATLAB:xychk:XAndYLengthMismatch';
        msg(1).message = getString(message(msg(1).identifier));
        return
      end
      if ~isequal(size(x),size(y))
        msg(1).identifier = 'MATLAB:xychk:XAndYSizeMismatch';
        msg(1).message = getString(message(msg(1).identifier));
        return
      end
  end
end


