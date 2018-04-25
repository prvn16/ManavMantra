function Value = get(e,varargin)
%GET  Access/Query event property values.
%
%   VALUE = GET(E,'PropertyName') returns the value of the 
%   specified property of the event object.  An equivalent
%   syntax is 
%
%       VALUE = E.PropertyName 
%   
%   GET(E) displays all properties of E and their values.  
%
%   See also EVENT\SET.

%   Copyright 2006 The MathWorks, Inc.

Value = uttsget(e,varargin{:});