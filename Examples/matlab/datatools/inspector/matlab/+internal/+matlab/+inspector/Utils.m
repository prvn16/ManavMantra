classdef Utils
    % This class is unsupported and might change or be removed without
    % notice in a future version.
    
    % Utilities class used by the Property Inspector.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    methods (Static = true)
        function s = createStructForObject(obj)
            % Creates a structure from a given object.  This is used
            % instead of calling struct(obj) directly, because some objects
            % lie about their properties.  For example, calling
            % properties(obj) is different than getting the metaclass
            % information for the class and looking at the public
            % properties in its PropertyList.  The inspector looks at the
            % properties of the object, as if calling properties(obj).
            s = struct;
            p = properties(obj);
            for i = 1:length(p)
                propName = p{i};
                try
                    s.(propName) = obj.(propName);
                catch
                    % Typically this won't fail, but it can sometimes with
                    % dependent properties that become invalid (for
                    % example, property d is determined by a+b, but b is a
                    % matrix and b is a char array).  Set to empty in this
                    % case.
                    s.(propName) = [];
                end
            end

            % The purpose of this method is to be used for object comparison --
            % but you can't compare tall objects.  If there are any tall
            % properties, set them to empty [].
            isTall = structfun(@istall, s);
            if any(isTall)
                f = fieldnames(s);
                fs = f(isTall);
                for j = 1:length(fs)
                    s.(fs{j}) = [];
                end
            end
        end
        
        %
        % The following functions are only used by the Java Desktop
        % Property Inspector
        %
        
        function state = compare(obj1,obj2,propName)
            % Java utility method for comparing a property shared by 2
            % objects to determine if the property values are the same.
            state = isequal(get(obj1,propName),get(obj2,propName));
        end
        
        function jobj = java(obj)
            
            if numel(obj)==1
                jobj = java(obj);
                return
            end
            jobj = javaArray(class(java(obj(1))),numel(obj));
            for k=1:numel(obj)
                jobj(k) = java(obj(k));
            end
        end
        
                
        function outStr = getPossibleMessageCatalogString(inStr)
            l = lasterror; %#ok<LERR>
            try
                outStr = getString(message(inStr));
            catch
                outStr = inStr;
            end
            lasterror(l); %#ok<LERR>
        end

        % Strips the trailing zeros from the text representation of an
        % array of numeric values.  For example, value will be something
        % like: editValue = '[0.010000000000000,500,0.025000000000000]'
        % The return value will be: '[0.01,500,0.025]'
        function val = getArrayWithZerosStripped(value)
            if (isstring(value) || ischar(value)) && ...
                    startsWith(value, '[') && endsWith(value, ']')
                if contains(value, ";")
                    % This is the case where there's multiple rows in the array.
                    % For example: [1.000,2.000,3.000; 4.000,5.000,6.000]
                    % Split on the , and ; and then reassemble
                    s = split(split(string(value(2:length(value)-1)), ";"), ",");
                    idx = contains(s, ".");
                    s(idx) = strip(s(idx), 'right', '0');
                    val = char("[" + join(join(s, ","), ";") + "]");
                else
                    % This is the case where there's a single row in the array.
                    % For example: [1.000,2.000,3.000]
                    s = split(string(value(2:length(value)-1)), ",");
                    idx = contains(s, ".");
                    s(idx) = strip(s(idx), 'right', '0');
                    val = char("[" + join(s, ",") + "]");
                end
            else
                % Just return the argument if this doesn't appear to be an
                % array representation
                val = value;
            end
        end
        
        %support new class defination, using validation to get acess the
        %property data type
        function PropDataType = getPropDataType(prop)
            if ~isempty(prop.Validation)
                PropDataType = prop.Validation.Class.Name;
            else
                PropDataType = prop.Type.Name;
            end
        end
        
        %support new class defination, using validation to get acess the property
        function Prop = getProp(prop)
            if ~isempty(prop.Validation)
                Prop = prop.Validation.Class;
            else
                Prop = prop.Type;
            end
        end        
        
        %support new class defination, using validation to get acess the
        %enumation property
        function isEnum = isEnumeration(prop)
            if ~isempty(prop.Validation)
                isEnum = prop.Validation.Class.Enumeration;
            else
                isEnum = isa(prop.Type, 'meta.EnumeratedType');
            end            
        end
        
        %support new class defination, using validation to get acess the
        %enumation property
        function isEnum = isEnumerationFrompropType(propType)
            if  isa(propType, 'meta.class')
                isEnum = propType.Enumeration;
            else
                isEnum = isa(propType, 'meta.EnumeratedType');
            end            
        end

        %get the help tooltip information
        function props = getObjectProperties(objName)
            %new function to get the property information from doc
            try
                results = internal.matlab.inspector.Utils.getHelpDocResults(objName);
                if results.size == 0 && contains(objName, '.tall')
                    % There are a set of graphics objects which are tall
                    % versions of the original object (tall line, tall scatter,
                    % etc...).  They have different class names, but are
                    % essentially the same in all other ways.  If we see one of
                    % these, look to its original object for help.
                    objName = replace(objName, '.tall', '');
                    results = internal.matlab.inspector.Utils.getHelpDocResults(objName);
                end

                props = struct('property', {}, 'description', {}, 'inputs', {});
                for i = 1:results.size
                    result = results.get(i-1);
                    % result.getTopic returns the format like 'Figure.Selected'
                    % we want the 'Selected' here
                    combineName = split(char(result.getTopic) , '.');
                    props(i).property = char(combineName(end));
                    props(i).description = char(result.getPurposeLine);
                    props(i).inputs = char(result.getInputValues);
                end
            catch
                props = [];
            end
        end

        function results = getHelpDocResults(objName)
            propertyType = com.mathworks.helpsearch.reference.RefEntityType.PROPERTY;
            request = com.mathworks.helpsearch.reference.ClassEntityListRequest(objName, propertyType);

            retriever = com.mathworks.mlwidgets.help.DocCenterReferenceRetrievalStrategy.createDataRetriever;
            oc = onCleanup(@() retriever.close);
            results = retriever.getReferenceData(request);
        end

        function flag = hasHelpInfo(applicationMap)
            for objectKey = keys(applicationMap)
                objectString = string(applicationMap(char(objectKey)));
                s = split(objectString, "tooltip");
                % check for tooltip information in any of the items (except the first
                % one since it has extra content at the beginning
                if any(~startsWith(extractAfter(s(2:end),5), "\"))
                    flag = true;
                    return;
                end
            end
            flag = false;
        end

    end
end
