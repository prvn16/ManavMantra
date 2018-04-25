function iptcheckmap(map, function_name, variable_name, argument_position) %#codegen
%IPTCHECKMAP Check validity of colormap.
%   IPTCHECKMAP(MAP,FUNC_NAME,VAR_NAME,ARG_POS) checks to see if
%   MAP is a valid MATLAB colormap and issues a formatted error
%   message if it is invalid. 
%
%   FUNC_NAME is a string or character vector that specifies the name used
%   in the formatted error message to identify the function checking the
%   colormap.
%
%   VAR_NAME is a string or character vector that specifies the name used
%   in the formatted error message to identify the argument being checked.
%
%   ARG_POS is a positive integer that indicates the position of
%   the argument being checked in the function argument list. 
%   IPTCHECKMAP includes this information in the formatted error message.
%
%   Example
%   -------
%    
%       bad_map = ones(10);
%       iptcheckmap(bad_map,'func_name','var_name',2)
%
%   See also IPTCHECKHANDLE

%   Copyright 1993-2017 The MathWorks, Inc.

matlab.images.internal.iptcheckmap( ...
    map, function_name, variable_name, argument_position);
