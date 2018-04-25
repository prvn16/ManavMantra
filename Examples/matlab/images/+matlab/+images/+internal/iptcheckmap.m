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

%   Copyright 2017 The MathWorks, Inc.

%#ok<*EMCA>

coder.extrinsic('num2str');

if isempty(coder.target)
    % Right now, MATLAB coder doesn't support strings. Make the simulation
    % mode execution work with strings.
    function_name = matlab.images.internal.stringToChar(function_name);
    variable_name = matlab.images.internal.stringToChar(variable_name);
end

validateattributes(function_name,{'char'},{'nonempty'},mfilename,...
    'FUNC_NAME',2);

validateattributes(variable_name,{'char'},{'nonempty'},mfilename,...
    'VAR_NAME',3);

validateattributes(argument_position,{'numeric'},{'integer','positive'},...
    mfilename,'ARG_POS',4);

if (~isa(map,'double') || isempty(map) || (~ismatrix(map)) || (~isreal(map))||...
        (size(map,2) ~= 3) || issparse(map))
    coder.internal.errorIf(true,'MATLAB:images:validate:badMapMatrix', ...
        upper( function_name ), num2str(argument_position), variable_name);
end

if (any(map(:) < 0) || any(map(:) > 1))
    coder.internal.errorIf(true, 'MATLAB:images:validate:badMapValues', ...
        upper( function_name ), num2str(argument_position), variable_name);
end
