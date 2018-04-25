function Value = get(h,varargin)
%GET  Access/Query event property values.
%
%   VALUE = GET(H,'PropertyName') returns the value of the 
%   specified property of the qualmetadata object.  An equivalent
%   syntax is 
%
%       VALUE = H.PropertyName 
%   
%   GET(E) displays all properties of E and their values.  
%
%   See also QUALMETADATA\SET.

%   Copyright 2006-2009 The MathWorks, Inc.

Value = uttsget(h,varargin{:}); 