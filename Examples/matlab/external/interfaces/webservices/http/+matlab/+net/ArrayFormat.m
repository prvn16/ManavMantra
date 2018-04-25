classdef (Sealed) ArrayFormat
    % ArrayFormat Method used to convert arrays in HTTP queries
    %   ArrayFormat is used in conjunction with matlab.net.QueryParameter to control
    %   the format used to convert query values that represent multiple values in the
    %   Query property of a URI.
    %  
    %   The following properties list shows an example of the query generated for
    %   QueryParameter('parm','[1,2,3]'):
    %
    %   ArrayFormat properties:
    %     csv         - parm=1,2,3             (default)
    %     json        - parm=[1,2,3]
    %     repeating   - parm=1&parm=2&parm=3
    %     php         - parm[]=1&parm[]=2&parm[]=3
    %  
    %   A query value is considered to contain multiple values if it is:
    %     - a non-scalar number, string, logical or datetime (each element is a value)
    %     - an m-by-n character array, where each row is interpreted as a string
    %     - a cell vector, where each element is a value
    %
    %   Except for character arrays, query values with more than one dimension are
    %   not supported.  In cell vectors, each element must be a scalar or character
    %   vector.
    %
    % See also QueryParameter, URI
    
    % Copyright 2015 The Mathworks, Inc.
    
    enumeration
        csv        % format that generates a comma-separated list: parm=1,2,3
        json       % format that generates a JSON-like array: parm=[1,2,3]
        php        % format that generates name with brackets and multiple values: parm[]=1&parm[]=2&parm[]=3
        repeating  % format that generates repeating name/value pairs: parm=1&parm=2&parm=3
    end
    
    methods (Access=?matlab.net.QueryParameter)
        function tf = hasBrackets(obj)
            tf = obj == obj.json || obj == obj.php;
        end
        function tf = hasCommas(obj)
            tf = obj == obj.csv || obj == obj.json;
        end
    end
end
          
