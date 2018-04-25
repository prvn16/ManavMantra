function dbl = double(opaque_array)
%DOUBLE Convert a Java object to DOUBLE

%   Chip Nylander, June 1998
%   Copyright 1984-2007 The MathWorks, Inc.

%
% For opaque types other than those programmed here, just run the default
% builtin double function.
%
if ~isjava(opaque_array)
  dbl = builtin('double', opaque_array);
  return;
end

%
% Convert opaque array to cell array to get the items in it.
%

try
  cel = cell(opaque_array);
catch exception %#ok
  dbl = [];
  return;
end


sz = builtin('size', cel);
psz = prod(sz);

%
% An empty Java array becomes an empty double array.
%
if psz == 0
  try
    dbl = reshape([],size(cel));
  catch
    dbl = [];
  end
  return;
end;

%
% A java.lang.Number array becomes a double array.
%
dbl = zeros(sz);
t = opaque_array(1);
c = class(t);

while ~isempty(findstr(c,'[]'))
  t = t(1);
  c = class(t);
end

if psz == 1 && isnumeric(t)
  dbl = double(t);
  return;
end

if isa(t,'java.lang.Number')
  for i=1:psz
    if isa(cel{i}, 'java.lang.Object')
        dbl(i) = doubleValue(cel{i});
    else
        dbl(i) = cel{i};
    end
  end
  return;
end

%
% Run toDouble on each Java object in the MATLAB array.  This will error
% out if a toDouble method is not available for the Java class of the object.
%
if psz == 1
  if ~isjava(opaque_array(1))
    dbl = builtin('double', opaque_array(1));
  else
    dbl = toDouble(opaque_array(1));
  end
else
  for i = 1:psz
    if ~isjava(cel{i})
      dbl(i) = toDouble(cel{i});
    else
      dbl(i) = toDouble(cel{i});
    end;
  end;
end;
