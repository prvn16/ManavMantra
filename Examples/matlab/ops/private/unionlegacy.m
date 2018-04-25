function [c,ia,ib] = unionlegacy(a,b,isrows)
% UNIONLEGACY 'legacy' flag implementation for union.
%   Implements the 'legacy' behavior (prior to R2012a) of UNION.

%   Copyright 1984-2014 The MathWorks, Inc.


if nargin==3 && isrows
    flag = 'rows';
else
    isrows = 0;
    flag = [];
end

rowsA = size(a,1);
colsA = size(a,2);
rowsB = size(b,1);
colsB = size(b,2);

rowvec = ~((rowsA > 1 && colsB <= 1) || (rowsB > 1 && colsA <= 1) || isrows);

numelA = numel(a);
numelB = numel(b);
nOut = nargout;

if isempty(flag)
  
  if length(a)~=numelA || length(b)~=numelB
    error(message('MATLAB:UNION:AandBvectorsOrRowsFlag'));
  end
  
  % Handle empty: no elements.
  
  if (numelA == 0 || numelB == 0)
    
    % Predefine outputs to be of the correct type.
    c = [a([]);b([])];
    
    if (numelA == 0 && numelB == 0)
      ia = []; ib = [];
      if (max(size(a)) > 0 || max(size(b)) > 0)
        c = reshape(c,0,1);
      end
    elseif (numelB == 0)
      % Call UNIQUE on one list if the other is empty.
      [c, ia] = unique(a(:),'legacy');
      ib = zeros(0,1);
    else
      [c, ib] = unique(b(:),'legacy');
      ia = zeros(0,1);
    end
    
    % General handling.
    
  else        
    % Convert to columns.
    a = a(:);
    b = b(:);
    
    if nOut <= 1
      % Call UNIQUE to do all the work.
      c = unique([a;b],'legacy');
    else
      [c,ndx] = unique([a;b],'legacy');
      % Indices determine whether an element was in A or in B.
      d = ndx > numelA;
      ia = ndx(~d);
      ib = ndx(d)-numelA;
    end
  end
  
  % If row vector, return as row vector.
  if rowvec
    c = c.';
    if nOut > 1
        ia = ia.';
        ib = ib.';
    end
  end
  
else    % 'rows' case
  % Automatically pad strings with spaces
  if ischar(a) && ischar(b)
    if colsA > colsB
      b = [b repmat(' ',rowsB,colsA-colsB)];
    elseif colsA < colsB 
      a = [a repmat(' ',rowsA,colsB-colsA)];
    end
  elseif colsA ~= colsB
    error(message('MATLAB:UNION:AandBColnumAgree'));
  end
  
  if nOut <= 1
    % Call UNIQUE to do all the work.
    c = unique([a;b],flag,'legacy');
  else
    [c,ndx] = unique([a;b],flag,'legacy');
    % Indices determine whether an element was in A or in B.
    d = ndx > rowsA;
    ia = ndx(~d);
    ib = ndx(d) - rowsA;
  end
end
end
