classdef Utility < handle
    % Base class for managing MCOS toolstrip component hierarchy.
    
    % Author(s): Rong Chen
    % Revised:
    % Copyright 2010-2017 The MathWorks, Inc.
    % $Revision: 1.1.4.1 $ $Date: 2014/03/26 02:40:47 $
    
    % ----------------------------------------------------------------------------
    % Public methods
    methods (Static)
        
        function convertedMap = convertJavaMapToStruct(javaMap)
            % Helper Method to convert a java Map into a struct
            convertedMap = struct;
            keyNamesJavaArray = javaMap.keySet.toArray();
            for idx = 1:javaMap.size()
                % Get name from the key set
                propertyStringName = keyNamesJavaArray(idx);
                % Use key name to get value out
                propertyValue = javaMap.get(propertyStringName);
                % Stuff into struct
                convertedMap.(char(propertyStringName)) = propertyValue;
            end
        end

        function hash = convertStructToJavaMap(structure)
            % Helper Method to convert a struct into a java hashmap
            names = fieldnames(structure);
            for ct=1:length(names)
                property = names{ct};
                value = structure.(property);
                if ischar(value)
                    if isempty(value)
                        data.(property) = java.lang.String;
                    else
                        data.(property) = java.lang.String(value);
                    end
                elseif islogical(value)
                    data.(property) = java.lang.Boolean(value);
                elseif isnumeric(value)
                    if isempty(value)
                        data.(property) = java.lang.String;
                    else
                        data.(property) = java.lang.Double(value);
                    end
                elseif iscell(value)
                    if isempty(value)
                        data.(property) = java.lang.String;
                    else
                        data.(property) = javaArray('java.lang.String',length(value));
                        for i=1:length(value)
                            data.(property)(i) = java.lang.String(value{i});
                        end
                    end
                else
                    data.(property) = value;
                end
            end
            hash = java.util.HashMap;
            names = fieldnames(data);
            for ct=1:length(names)
                hash.put(names{ct}, data.(names{ct}));
            end
        end
        
        function eventdata = processPeerEventData(peerData)
            structure = peermodel.internal.Utility.convertJavaMapToStruct(peerData.getData());
            eventdata = peermodel.internal.PeerModelEventData(structure);
        end

        function value = convertValueFromMatlabToJava(value)
            if ischar(value)
                value = java.lang.String(value);
            elseif islogical(value)
                value = java.lang.Boolean(value);
            elseif isnumeric(value)
                if length(value) > 1
                    tmp = javaArray('java.lang.Double',length(value));
                    for i=1:length(value)
                        tmp(i) = java.lang.Double(value(i));
                    end
                    value = tmp;
                else
                    value = java.lang.Double(value);
                end
            elseif iscell(value)
                if isempty(value)
                    value = java.lang.String;
                else
                    tmp = javaArray('java.lang.String',length(value));
                    for i=1:length(value)
                        tmp(i) = java.lang.String(value{i});
                    end
                    value = tmp;
                end
            end
        end

    end

end

