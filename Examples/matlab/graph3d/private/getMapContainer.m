function mapContainer = getMapContainer(obj)
% getMapContainer(OBJECT), returns OBJECT
% If OBJECT has the AlphaMap/ColorMap property
% If OBJECT doesn't have AlphaMap/ColorMap as it's property but has a ColorSpace, then the ColorSpace is returned
% If OBJECT doesn't have either of the above,  EMPTY is returned.

% Does OBJ have a property called ColorMap or AlphaMap?
if isscalar(obj) && ( isprop(obj,'Colormap') || isprop(obj,'Alphamap') )
    mapContainer = obj;
    return;
end

% Does OBJ have a valid ColorSpace?
% ColorSpaces have the AlphaMap/ColorMap property,
if isscalar(obj) && isprop(obj, 'ColorSpace') && isa(get(obj,'ColorSpace'), 'matlab.graphics.axis.colorspace.ColorSpace')
    mapContainer = get(obj,'ColorSpace');
    return;
end

% object does not contain a map return empty;
mapContainer = [];
end