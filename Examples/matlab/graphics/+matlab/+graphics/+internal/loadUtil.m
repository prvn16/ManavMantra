function loadUtil(obj)

%   Copyright 2014 The MathWorks, Inc.

    isFig = ishghandle(obj, 'figure');
    if (~isFig)
        % UNEXPECTED code path
        return;
    end

    loadDataProps = get(obj,'LoadData');
    
    if isempty(loadDataProps)
        % UNEXPECTED code path
        return;
    end
    
    
    propNames = fieldnames(loadDataProps);

    Props = [];
    OldProps = [];

    for n = 1:length(propNames)
        if localIsProp(obj, propNames{n})
            % Move the override property value into the list for this object
            Props.(propNames{n}) = loadDataProps.(propNames{n});

            if ~isempty(findprop(obj, propNames{n})) ...
                    && (isempty(findprop(obj, [propNames{n} 'Mode'])) ...
                    || strcmp(get(obj, [propNames{n} 'Mode']), 'manual'))

                % Return the current property value if
                %   (a) The property name was exactly specified
                %   (b) Either (i)  there is no Mode property.
                %       Or     (ii) the Mode is set to Manual.
                OldProps.(propNames{n}) = get(obj, propNames{n});  
            end
        end
    end
    
    set(obj, 'LoadData', OldProps);
    
    if ~isempty(Props)
        set(obj, Props)
    end
end

function ret = localIsProp(h, PropName)
% Check whether a property name is a valid property on an object.  This is
% a replacement for isprop that also allows partial and case-insensitive
% matches to property names

% @TODO This helper function is copied from hgload.m

% First do a quick check for an exact match. 
ret = true;
if ~isprop(h, PropName)
    % We have to attempt to access the property in order to determine if it
    % is a partial match
    try
        get(h, PropName);
    catch E %#ok<NASGU>
        ret = false;
    end
end
end