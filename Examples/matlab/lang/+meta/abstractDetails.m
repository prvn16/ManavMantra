function abstractMembers = abstractDetails(classReference)
    %abstractDetails   List abstract methods and properties of class
    %    meta.abstractDetails(classname) displays a list of abstract 
    %    methods and properties for the class with name classname.
    %    classname can be specified as a string scalar or character vector.  
    %    Use the fully specified name for classes in packages. All public 
    %    and protected abstract methods and properties are displayed, 
    %    including those declared hidden.
    %
    %    meta.abstractDetails(mc) displays the abstract methods and 
    %    properties for the class represented by the meta.class object mc.
    %
    %    absMembers = meta.abstractDetails(mc) returns an array of 
    %    metaclass objects corresponding to the abstract members of the 
    %    class represented by meta.class object mc. If the class has both 
    %    abstract methods and abstract properties, absMembers will be a 
    %    heterogeneous array containing meta.method and meta.property 
    %    objects.
    %
    %    Examples:
    %    Given the following class definition:
    %
    %    classdef AbsClass
    %        methods(Abstract)
    %            result = absMethodOne(obj)
    %            output = absMethodTwo(obj)
    %        end
    %        properties(Abstract, Hidden)
    %            PropOne
    %        end
    %    end
    %
    %    %Example 1: Use class name to obtain list of abstract methods and
    %    %properties
    %    meta.abstractDetails('AbsClass')
    %
    %    %Example 2: Use meta.class instance
    %    mc = ?AbsClass;
    %    ab = meta.abstractDetails(mc);
    %
    %    See also: meta.class, meta.class.fromName
    
    % Copyright 2012-2017  The Mathworks, Inc.
    
    if ischar(classReference) || isStringScalar(classReference)
        mc = meta.class.fromName(classReference);
        classname = classReference;
    elseif isa(classReference, 'meta.class')
        mc = classReference;
        classname = mc.Name;
    else
        error(message('MATLAB:class:AbstractInvalidInput','meta.class'));
    end
    
    methodList = [];
    propertyList = [];
    
    if ~isempty(mc)
        methodList = findobj(mc.MethodList,'Abstract',true);
        propertyList = findobj(mc.PropertyList,'Abstract',true);
    end
    
    numMethods = numel(methodList);
    numProps = numel(propertyList);
    
    if nargout > 0
        %Output requested - return heterogeneous array of meta.method and
        %meta.property instances
        abstractMembers = [methodList; propertyList];
    else
        %Respect format spacing - if loose, insert extra newlines
        loose = strcmp(matlab.internal.display.formatSpacing,'loose');
        if loose
            fprintf('\n');
        end
        
        if numMethods == 0 && numProps == 0
            %Input class has no abstract members
            fprintf('%s\n',getString(message('MATLAB:ClassText:NoAbstractMembers', classname, classname)));
        else
            %Class exists and has at least one abstract member       
            if numMethods > 0
                displayList('AbstractMethodsLabel', mc.Name, numMethods, methodList);
            end
            
            if numProps > 0
                if loose && numMethods
                    fprintf('\n');
                end
                displayList('AbstractPropertiesLabel', mc.Name, numProps, propertyList);
            end
        end
        
        if loose
            fprintf('\n');
        end
    end
end

function displayList(messageID, className, numMembers, memberList )
    %Create padded char array of abstract member names
    memberNames = char({memberList.Name});
    definingClasses = [memberList.DefiningClass];
    fprintf('%s:\n',getString(message(['MATLAB:ClassText:' messageID],className)));
    for k=1:numMembers
        fprintf('    %s\t%% %s\n', ...
            memberNames(k,:), ...
            getString(message('MATLAB:ClassText:AbstractDefinedIn', definingClasses(k).Name)));
    end
end
