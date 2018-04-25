classdef WsdlObject
    % WsdlObject - Base class of all derived objects created by createWsdlClient
    %   This class is for internal use only and may change in a future release.
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties 
    end
    
    methods (Abstract, Access = protected, Hidden)
        jobj = getOneObj(obj)
    end
    
    methods (Hidden)
        function jobj = getObj(obj)
            % Return the Java object corresponding to this object.
            % If invoked on an array, return java.util.List of them, ordered by column
            if numel(obj) > 1
                jobj = matlab.wsdl.internal.WsdlObject.getDerivedList(obj);
            else
                jobj = getOneObj(obj);
            end
        end
    end
    
    methods (Access = protected, Hidden)
        function checkFields(obj, fields, names, derivedFields)
            % Error out if an element in fields is empty and call validate on each
            % derivedField.  Called to validate fields in the object that are
            % required in a transmitted message.  These are fields that the XML
            % Schema says not nillable and minOccurs > 0.
            for i = 1 : length(fields)
                % We only look for true nulls, i.e. [], indicating the caller never
                % set them.  If the field is a an empty char, then it's really a
                % 0-length string so it's OK.
                if isempty(fields{i}) && ~ischar(fields{i})
                     error(message('MATLAB:webservices:RequiredFieldNotSet', ...
                         names{i}, class(obj), regexprep(class(obj),'^.*\.','')));
                end
            end
            for i = 1 : length(derivedFields)
                derivedFields{i}.validate
            end
        end
    end
    
    methods (Static, Hidden)
        function list = getDerivedList(objArray, list)
            % getDerivedList(objArray, list) - Get or populate java.util.List of objects
            %
            % Convert each element in objArray (which must be a WsdlObject) to a Java
            % object by calling its getObj method, and return as java.util.List.
            %
            %   objArray    MATLAB object, or array of objects, with getObj method that
            %   list        (optional) If specified, an existing java.util.list to be
            %               cleared and populated.
            %

            if nargin < 2
                list = java.util.ArrayList(numel(objArray));
            else
                list.clear;
            end
            arrayfun(@(x) list.add(x.getObj), objArray);
        end
        
        function list = getBasicList(name, arr, type, list)
            % getBasicList([arr, type, list) - Get or populate java.util.List of primitive values
            %     
            % Convert each element in arr, to a Java object and return as
            % java.util.List.  Elements expected to be primitive MATLAB types that
            % map to XML Schema basic types, convertible to Java objects using
            % matlab.wsdl.internal.fromMATLAB.
            %
            %   name        2-element cell array of object name, parameter name
            %   arr         MATLAB array of primitive types or cell array of strings
            %   type        XML type of the field
            %   list        (optional) If specified, an existing java.util.list to be
            %               cleared and populated.
            %

            if nargin < 3
                list = java.util.ArrayList(numel(arr));
            else
                list.clear;
            end
            if iscell(arr)
                cellfun(@(x) list.add(matlab.wsdl.internal.fromMATLAB(name,x,type,true)), arr);
            else
                arrayfun(@(x) list.add(matlab.wsdl.internal.fromMATLAB(name,x,type,true)), arr);
            end
        end
        
        function res = getMATLABObject(jobj, pkg)
            % Return an instance of the MATLAB class constructed from the Java
            % object.  This looks for a MATLAB class in the specified package with
            % the same name as the Java class.  If that class is an instance of
            % WsdlObject, call getInstance on it.  The pkg argument a string is of
            % the form "wsdl.pkgname".
            jclass = jobj.getClass.getSimpleName;
            mclass = [pkg '.' char(jclass)];
            try
                if meta.class.fromName(mclass) <= ?matlab.wsdl.internal.WsdlObject
                    res = feval([mclass '.getInstance'], jobj, false);
                end
            catch e
                res = [];
            end
        end
        
    end
end

    

