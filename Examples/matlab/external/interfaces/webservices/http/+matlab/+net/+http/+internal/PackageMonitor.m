classdef PackageMonitor
% PackageMonitor maintains information about classes in matlab.net.http.field
%
%   PackageMonitor methods, both static:
%
%     getClassForName  - return the class that implements a header field
%     getNamesForClass - return getSupportedNames for a class and subclasses
%     refresh          - refresh cache when package changes
%
%   FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%   and is intended for use only within the scope of functions and classes
%   in toolbox/matlab/external/interfaces/webservices/http. Its behavior
%   may change, or the function itself may be removed in a future release.

% Copyright 2015-2016 The MathWorks, Inc.

% TODO: Since we can't listen to the ClassList property in the meta.package object
% for changes, we require someone to call refresh when the package changes.  In the
% future if such listening is supported we wouldn't need the refresh method.
% This is only required in development because HeaderField and all its
% subclasses are currently sealed.

    methods (Static)
        function clazz = getClassForName(name)
        % Return the meta.class object for the class in matlab.net.http.field whose
        % getSupportedNames method returns name, or a cell array containing name.
        % If not found, returns [].
            name = char(lower(name));  % TBD string containers.Map requires char
            map = getMaps();
            try
                clazz = map(name);
                if ~isvalid(clazz)
                    % class found but may be deleted or changed, which invalidates
                    % the meta.class handle, so rebuild map and look again
                    map = getMaps(true);
                    clazz = map(name);
                end
            catch
                clazz = [];
            end
        end

        function refresh()
        % Refresh the map.  Must be called when something changes in the package.
            getMaps(true);
        end
        
        function names = getNamesForClass(clazz)
        % Return vector of getSupportedNames from clazz or subclasses.  This is not
        % necessarily the list of allowed names--that's the purpose of
        % getSupportedNames: if clazz.getSupportedNames is empty, the clazz
        % may allow any names besides these.
        % This throws an error if clazz isn't in our maps.
            [~, class2Names] = getMaps();
            try
                names = class2Names(clazz.Name);
            catch
                if clazz < ?matlab.net.http.HeaderField
                    % if we can't find it, but it's a subclass of HeaderField, maybe 
                    % the maps need a refresh, so try once more.
                    refresh();
                    [~, class2Names] = getMaps();
                    try 
                        names = class2Names(clazz.Name);
                        return;
                    catch
                        % still not found; must not be in the right package
                        % fall through
                    end
                end
                % not in the right package or not a HeaderField subclass
                error(message('MATLAB:http:NotHeaderFieldSubclass', clazz.Name));
            end
        end
    end
end

function [name2Class, class2Names] = getMaps(~)
% Return the maps, creating them and filling their contents if they don't exist yet.
% parameter supplied, create new maps and fill them. 

    persistent theMap     % map of lowercase name to meta.class
    persistent reverseMap % map of class name to vector of supported names
    % First time or when asked, create it. Need isnumeric to distinguish empty map
    % from [] because an empty map might just mean that there is nothing in the
    % package
    if nargin > 0 || (isempty(theMap) && isnumeric(theMap))
        theMap = containers.Map();
        reverseMap = containers.Map();
        fillMaps(theMap, reverseMap)
    end
    name2Class = theMap;
    class2Names = reverseMap;
end

function fillMaps(map, reverseMap)
% Fill the two containers.Maps with information about the classes in the
% matlab.net.http.field package. 
%   map: The key is a value returned from getSupportedNames in a class,
%        converted to lowercase, and the value is its meta.class.  
%   reverseMap: The key is the fully qualified class name and the value is a
%        vector of supported names for this class and its subclasses, lowercase.
% At the same time, verifies certain semantic correctness of the classes in
% matlab.net.http.field.
    pkg = meta.package.fromName('matlab.net.http.field');
    classes = pkg.ClassList;
    % loop through each class in the package
    for i = 1 : length(classes)
        clazz = classes(i);
        if ~(?matlab.net.http.HeaderField > clazz)
            % All members of the matlab.net.http.field package must be derived
            % from matlab.net.http.HeaderField
            if ~warned(clazz,'NotSuperclass')
                warning(message('MATLAB:http:NotSuperclass', clazz.Name));
            end
            continue;
        end
        % Call its getSupportedNames method
        method = clazz.MethodList(strcmp({clazz.MethodList.Name}, ...
                                         'getSupportedNames'));
        % Insure that the method is implemented in the class, not superclass.
        % Exception is that abstract classes don't need the implementation.
        assert(~isempty(method));
        if (method.DefiningClass ~= clazz || ~method.Static) && ~clazz.Abstract
            warning(message('MATLAB:http:MissingStaticMethod', ...
                            clazz.Name, 'getSupportedNames'));
            continue;
        end
        % Get all the field names that clazz supports
        supportedNames = string(feval([clazz.Name '.getSupportedNames']));
        if ~isempty(supportedNames)
            % If it directly implements any field names, make sure it (or a
            % superclass) overrides HeaderField.convert() in the base class.
            % Otherwise it could result in infinite recursion when
            % HeaderField.convert() calls convert() in a subclass.
            method = clazz.MethodList(strcmp({clazz.MethodList.Name}, ...
                                             'convert'));
            assert(~isempty(method));
            if method.DefiningClass == ?matlab.net.http.HeaderField
                warning(message('MATLAB:http:MissingConvertMethod', clazz.Name));
                continue;
            end
        end
        % add each supported name to the map
        for j = 1 : length(supportedNames)
            name = char(supportedNames(j)); % TBD string containers.Map requires char
            lname = lower(name);
            if map.isKey(lname)
                % Name is already in map.  If clazz is a subclass of that one,
                % replace it.  If a superclass, skip it.  If neither, error
                oldClass = map(lname);
                if isempty(oldClass) || oldClass > clazz
                    map(lname) = clazz;
                elseif ~(oldClass < clazz)
                    error(message('MATLAB:http:MoreThanOneClassImplements', ...
                                  name, oldClass.Name, clazz.Name));
                end
            else
                map(lname) = clazz;
            end
        end
        addNamesToClass(clazz, supportedNames);
    end
    
    function addNamesToClass(clazz, names)
    % Add names to the clazz and all its superclasses (that are HeaderFields) in
    % reverseMap, except HeaderField itself.
        className = clazz.Name;
        if reverseMap.isKey(className)
            oldNames = reverseMap(className);
            newNames = addIfMissing(oldNames, names);
        else
            newNames = string(names);
        end
        reverseMap(className) = newNames;
        for k = 1 : length(clazz.SuperclassList)
            superclass = clazz.SuperclassList(k);
            assert(~isempty(superclass)) % this should have been checked above
            if superclass < ?matlab.net.http.HeaderField
                % recurse on superclass
                addNamesToClass(superclass, names);
            end
        end
        
        function list = addIfMissing(list, names)
        % add names to list that aren't already in list
            for l = 1 : length(names)
                if ~any(list == names(l))
                    list(end+1) = names(l); %#ok<AGROW>
                end
            end
        end
    end
end

