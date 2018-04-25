function out = mkconstarray(class, value, size)
%MKCONSTARRAY creates a constant array of a specified numeric class.
%   A = MKCONSTARRAY(CLASS, VALUE, SIZE) creates a constant array 
%   of value VALUE and of size SIZE.

%   Copyright 1993-2003 The MathWorks, Inc.  

%out = repmat(feval(class, value), size);
if (value == 0)
  
  if (strcmp(class, 'logical'))
    out = gpuArray.false(size);
  else
    out = gpuArray.zeros(size, class);
  end
  
elseif (value == 1)
  
  if (strcmp(class, 'logical'))
    out = gpuArray.true(size);
  else
    out = gpuArray.ones(size, class);
  end
  
else
  if (strcmp(class,'logical'))
      out = gpuArray.true(size);
  else
      out = gpuArray.ones(size, class) .* value;
  end
  
end
