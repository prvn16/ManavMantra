% HGLOAD  Loads Handle Graphics object from a file.
%
% H = HGLOAD('filename') loads handle graphics objects from the .fig
% file specified by 'filename,' and returns handles to the top-level
% objects. If 'filename' contains no extension, then the extension
% '.fig' is added.
%
% [H, OLD_PROPS] = HGLOAD(..., PROPERTIES) overrides the properties on
% the top-level objects stored in the .fig file with the values in
% PROPERTIES, and returns their previous values.  PROPERTIES must be a
% structure whose field names are property names, containing the
% desired property values.  OLD_PROPS are returned as a cell array the
% same length as H, containing the previous values of the overridden
% properties on each object.  Each cell contains a structure whose
% field names are property names, containing the original value of
% each property for that top-level object. Any property specified in
% PROPERTIES but not present on a top-level object in the file is
% not included in the returned structure of original values.
%
% See also HGSAVE, HANDLE2STRUCT, STRUCT2HANDLE.

%   Copyright 2011-2015 The MathWorks, Inc.
