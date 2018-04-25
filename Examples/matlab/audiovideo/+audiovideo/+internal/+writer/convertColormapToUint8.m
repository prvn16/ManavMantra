function cmap = convertColormapToUint8(cmap)
% Given a colormap, converts the entries to uint8.

%    Copyright 2012-2013 The MathWorks, Inc.

if isempty(cmap)
    cmap = uint8([]);
    return
end

if isa(cmap, 'uint8')
    return;
end

cmap = uint8( double(intmax('uint8'))*cmap );

end