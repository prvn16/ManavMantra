function P = get(A, name)
    %GET Get property values of fi object
    %   v = get(h) returns all properties and property values for the fi
    %   object identified by h. v is a structure whose field names are the
    %   property names and whose values are the corresponding property values.
    %   If you do not specify an output argument, then MATLAB
    %   displays the information on the screen.
    %
    %   v = get(h,propertyName) returns the value for the specific property,
    %   propertyName. Use single quotes around the property name, for example,
    %   get(h,'Signedness'). If you do not specify an output argument, then MATLAB
    %   displays the information on the screen.
    %
    %   v = get(h,propertyArray) returns a 1-by-n cell array, where n is equal
    %   to the number of property names contained in propertyArray.
    
    %   Copyright 2012-2017 The MathWorks, Inc.
    
    if nargin > 1
        name = convertStringsToChars(name);
    end
    
    if nargin == 1
        % get(h)
        props = properties(A);
        S = cell2struct(cell(size(props)),props,1);
        for pn = props'
            S.(pn{1}) = A.(pn{1});
        end
        if nargout == 1
            P = S;
        else
            disp(S);
        end
        
    elseif nargin == 2
        % one fi object can have many data elements but they all share same property
        if iscellstr(name)
            % get(h,propertyArray)
            n = numel(name);
            P = cell(1, n);
            for i = 1:n
                [P{:,i}] = A.(name{i});
            end
        elseif ischar(name)
            % get(h,propertyName)
            P = A.(name);
        else
            error(message('MATLAB:class:InvalidArgument', 'get','get'));
        end
    end
    
end %function

