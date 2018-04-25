function iptcheckconn(conn,function_name,variable_name,arg_position)
%IPTCHECKCONN Check validity of connectivity argument.
%   IPTCHECKCONN(CONN,FUNC_NAME,VAR_NAME,ARG_POS) checks if CONN
%   is a valid connectivity argument. If it is invalid, the function
%   issues a formatted error message.
%
%   A connectivity argument can be one of the following scalar
%   values, 1, 4, 6, 8, 18, or 26. A connectivity argument can also
%   be a 3-by-3-by- ... -by-3 array of 0s and 1s. The central element
%   of a connectivity array must be nonzero and the array must be
%   symmetric about its center.
%
%   FUNC_NAME is a string that specifies the name used in the formatted
%   error message to identify the function checking the connectivity
%   argument.
%
%   VAR_NAME is a string that specifies the name used in the formatted
%   error message to identify the argument being checked.
%
%   ARG_POS is a positive integer that indicates the position of
%   the argument being checked in the function argument list.
%   IPTCHECKCONN includes this information in the formatted error message.
%
%   Class Support
%   -------------
%   CONN must be of class double or logical and must be real and nonsparse.
%
%   Example
%   -------
%       % Create a 4-by-4 array and pass it as connectivity argument.
%       iptcheckconn(eye(4), 'func_name','var_name',2) 

%    Copyright 1993-2017 The MathWorks, Inc.

validateattributes(conn,{'double' 'logical'},{'real' 'nonsparse'},...
    function_name,variable_name,arg_position);

function_name = matlab.images.internal.stringToChar(function_name);
variable_name = matlab.images.internal.stringToChar(variable_name);

function_name = upper(function_name);

if numel(conn) == 1
    if (conn ~= 1) && (conn ~= 4) && (conn ~= 8) && (conn ~= 6) && ...
            (conn ~= 18) && (conn ~= 26)
        
        error(message('images:validate:badScalarConn',function_name,arg_position,variable_name));
    end
else
    if any(size(conn) ~= 3)
        error(message('images:validate:badConnSize',function_name,arg_position,variable_name));
    end
    
    if any((conn(:) ~= 1) & (conn(:) ~= 0))
        error(message('images:validate:badConnValue',function_name,arg_position,variable_name));
    end
    
    if conn((end+1)/2) == 0
        error(message('images:validate:badConnCenter',function_name,arg_position,variable_name));
    end
    
    if ~isequal(conn(1:end), conn(end:-1:1))
        error(message('images:validate:nonsymmetricConn',function_name,arg_position,variable_name));
    end
end
