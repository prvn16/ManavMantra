function ret = getSystemObjectMetadata(className)

ret = struct('name', {}, 'stringSetValues', {}, 'isDiscreteState', {}, 'isScalarLogical', {});

try
    mc = meta.class.fromName(className);
    metaProperties = mc.PropertyList;
    metaPropertyNames = {metaProperties.Name};

    for p = 1:numel(metaPropertyNames)
        
        cur = struct('name', metaPropertyNames{p}, 'stringSetValues', '', 'isDiscreteState', false, 'isScalarLogical', false);
        addCur = false;

        % Determine if there is a matching 'Set' property.  If so, record the property and its allowed values (g1343082)
        matchingSetPropertyIdx = find(strcmp(metaPropertyNames, [metaPropertyNames{p} 'Set']), 1);
        if ~isempty(matchingSetPropertyIdx) && metaProperties(p).ConstrainedSet
            setProperty = metaProperties(matchingSetPropertyIdx);
            if isa(setProperty.DefaultValue, 'matlab.system.StringSet')
                stringSetValues = getAllowedValues(setProperty.DefaultValue);
                cur.stringSetValues = stringSetValues;
                addCur = true;
            end
        end

        % Record properties with the DiscreteState attribute (these are not to be tab completed, g1349863)
        if metaProperties(p).DiscreteState
            cur.isDiscreteState = true;
            addCur = true;
        end
        
        % Record properties with the Logical attribute ("true" and "false" should be value completions, g1351793)
        if metaProperties(p).Logical
            cur.isScalarLogical = true;
            addCur = true;
        end
        
        if addCur
            ret(end+1) = cur; %#ok<AGROW>
        end

    end
catch
end

end
