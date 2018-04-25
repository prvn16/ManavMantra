classdef ClassHelpContainer < matlab.internal.language.introspective.containers.abstractHelpContainer
    % CLASSHELPCONTAINER - stores help and class information related to a
    % MATLAB Object System class
    %
    % Remark:
    % Creation of this object should be made by the static 'create' method
    % of matlab.internal.language.introspective.containers.HelpContainerFactory class.
    %
    % Example:
    % filePath = which('RandStream');
    % helpContainer = matlab.internal.language.introspective.containers.HelpContainerFactory.create(filePath);
    %
    % The code above constructs a ClassHelpContainer object.
    
    % Copyright 2009-2015 The MathWorks, Inc.
    
    properties (Access = private)
        % SimpleElementHelpContainers stores metadata & help comments
        % for simple elements in a struct where each field corresponds to
        % a simple element type, containing a struct in which each field has one
        % ClassMemberHelpContainer.
        SimpleElementHelpContainers;
        
        % StructMethodHelpContainers - stores metadata & help comments for
        % methods in a struct where each field corresponds to one
        % ClassMemberHelpContainer.
        StructMethodHelpContainers;
        
        % StructAbstractHelpContainers - stores metadata & help comments 
        % for abstract methods in a struct where each field corresponds to
        % one ClassMemberHelpContainer.
        StructAbstractHelpContainers;
        
        % ConstructorHelpContainer - stores metadata & help comments for constructor
        ConstructorHelpContainer;
        
        minimalPath; % minimal path to class
        
        classInfo; % used to extract help comments for class members
    end
    
    properties (SetAccess = private)        
        % onlyLocalHelp - boolean flag determines two things:
        % 1. To store entire help or just H1 line
        % 2. to store help information for inherited methods and properties
        onlyLocalHelp;

        superClassList; % used to assuage code analyzer
    end
    
    methods
        %% ---------------------------------
        function this = ClassHelpContainer(filePath, classMetaData, onlyLocalHelp)
            % constructor takes three input arguments:
            % 1. filePath - Full file path to MATLAB file
            % 2. classMetaData - ?className
            % 3. onlyLocalHelp - a boolean flag to determine whether to
            % include inherited methods/properties and methods defined
            % outside the classdef file.
            
            mFileName = classMetaData.Name;
            nameResolver = matlab.internal.language.introspective.resolveName(mFileName, '');
            ci = nameResolver.classInfo;
            helpStr = ci.getHelp;
            
            if ~onlyLocalHelp
                helpStr = matlab.internal.language.introspective.containers.extractH1Line(helpStr);
            end
            
            mainHelpContainer = matlab.internal.language.introspective.containers.ClassMemberHelpContainer(...
                'classHelp', helpStr, classMetaData, ~onlyLocalHelp);
            
            this = this@matlab.internal.language.introspective.containers.abstractHelpContainer(mFileName, filePath, mainHelpContainer);
            
            this.minimalPath = matlab.internal.language.introspective.minimizePath(filePath, false);

            this.classInfo = ci;
            this.superClassList = strjoin({classMetaData.SuperclassList.Name}, ' & ');
            
            this.onlyLocalHelp = onlyLocalHelp;
            
            this.buildStructMethodHelpContainers;
            this.buildSimpleElementHelpContainers;
        end
        
        %% ---------------------------------
        function elementIterator = getSimpleElementIterator(this, elementKeyword)
            % GETSIMPLEELEMENTITERATOR - returns iterator for simple help objects
            elementIterator = matlab.internal.language.introspective.containers.ClassMemberIterator(this.SimpleElementHelpContainers.(elementKeyword));
        end
                
        %% ---------------------------------
        function methodIterator = getMethodIterator(this)
            % GETMETHODITERATOR - returns iterator for method help objects
            methodIterator = matlab.internal.language.introspective.containers.ClassMemberIterator(this.StructMethodHelpContainers, this.StructAbstractHelpContainers);
        end

        %% ---------------------------------
        function methodIterator = getConcreteMethodIterator(this)
            % GETCONCRETEMETHODITERATOR - returns iterator for non-abstract method help objects
            methodIterator = matlab.internal.language.introspective.containers.ClassMemberIterator(this.StructMethodHelpContainers);
        end

        %% ---------------------------------
        function methodIterator = getAbstractMethodIterator(this)
            % GETABSTRACTMETHODITERATOR - returns iterator for abstract method help objects
            methodIterator = matlab.internal.language.introspective.containers.ClassMemberIterator(this.StructAbstractHelpContainers);
        end

        %% ---------------------------------
        function constructorIterator = getConstructorIterator(this)
            % GETCONSTRUCTORITERATOR - returns iterator for constructor helpContainer
            constructorStruct = struct;
            constructorHelpContainer = this.getConstructorHelpContainer;

            if ~isempty(constructorHelpContainer)
                constructorStruct.(this.classInfo.className) = constructorHelpContainer;
            end

            constructorIterator = matlab.internal.language.introspective.containers.ClassMemberIterator(constructorStruct);
        end
        %% ---------------------------------
        function conHelp = getConstructorHelpContainer(this)
            % GETCONSTRUCTORHELPOBJ - returns constructor help container object
            conHelp = this.ConstructorHelpContainer;
        end
        
        %% ---------------------------------
        function elementHelpContainer = getSimpleElementHelpContainer(this, elementKeyword, elementName)
            % GETSIMPLEELEMENTHELPCONTAINER - returns help container object for simple element
            elementHelpContainer = getMemberHelpContainer(this.SimpleElementHelpContainers.(elementKeyword), elementName);
        end
                
        %% ---------------------------------
        function methodHelpContainer = getMethodHelpContainer(this, methodName)
            % GETMETHODHELPCONTAINER - returns the help container object for method
            try
                methodHelpContainer = getMemberHelpContainer(this.StructMethodHelpContainers, methodName);
            catch %#ok<CTCH>
                methodHelpContainer = getMemberHelpContainer(this.StructAbstractHelpContainers, methodName);
            end
        end
        
        %% ---------------------------------
        function result = hasNoHelp(this)
            % ClassHelpContainer is considered empty if all of the
            % following have null help comments:
            % - Main class
            % - Constructor
            % - All properties and methods
            result = hasNoHelp@matlab.internal.language.introspective.containers.abstractHelpContainer(this);
            result = result && this.ConstructorHelpContainer.hasNoHelp;
            result = result && hasNoMemberHelp(this.getMethodIterator);
            for elementType = matlab.internal.language.introspective.getSimpleElementTypes            
                result = result && hasNoMemberHelp(this.getSimpleElementIterator(elementType.keyword));
            end
        end

        %% ---------------------------------
        function result = isClassHelpContainer(this) %#ok<MANU>
            % ISCLASSHELPCONTAINER - returns true because object is of
            % type ClassHelpContainer
            result = true;
        end
    end
    
    methods (Access = private)
        %% ---------------------------------
        function buildSimpleElementHelpContainers(this)
            % BUILDSIMPLEELEMENTHELPCONTAINERS - initializes the struct
            % SimpleElementHelpContainers to store all the
            % ClassMemberHelpContainer objects for simple elements that meet the
            % requirements as specified in the
            % matlab.internal.language.introspective.containers.HelpContainerFactory help comments.
            
            this.buildSimpleElementHelpContainer(this.mainHelpContainer.metaData.PropertyList, 'properties', this.onlyLocalHelp);
            this.buildSimpleElementHelpContainer(this.mainHelpContainer.metaData.EventList, 'events', this.onlyLocalHelp);
            this.buildSimpleElementHelpContainer(this.mainHelpContainer.metaData.EnumerationMemberList, 'enumeration', false);
        end

        function buildSimpleElementHelpContainer(this, metaData, elementKeyword, skipInherited)
            metaData = cullMetaData(metaData, elementKeyword);
            
            if ~isempty(metaData) && skipInherited
                % Remove any elements inherited from super classes
                metaData(arrayfun(@(c)~strcmp(c.DefiningClass.Name, this.mFileName), metaData)) = [];
            end
            
            this.SimpleElementHelpContainers.(elementKeyword) = this.getClassMembersStruct(elementKeyword, metaData);
        end
        
        %% ---------------------------------
        function buildStructMethodHelpContainers(this)
            % BUILDSTRUCTMETHODHELPCONTAINERS - does 2 things:
            %    1. Creates the struct StructMethodHelpContainers storing all
            %    the method ClassMemberHelpContainers.
            %    2. Creates the struct StructAbstractHelpContainers storing
            %    all the abstract method ClassMemberHelpContainers.
            %    3. Invokes buildConstructorHelpContainer to build a
            %    ClassMemberHelpContainer object for the constructor.
            %
            % Remark:
            % Refer to matlab.internal.language.introspective.XMLUtil.HelpContainerFactory help for details on
            % requirements for methods that give rise to
            % ClassMemberHelpContainer objects.
            
            % enable the directory hashtable
            matlab.internal.language.introspective.hashedDirInfo(true);
            
            methodMetaData = cullMetaData(this.mainHelpContainer.metaData.MethodList, 'methods');
            
            constructorMeta = methodMetaData(strcmp({methodMetaData.Name}, regexp(this.mFileName, '\w+$', 'match', 'once')));
            
            this.buildConstructorHelpContainer(constructorMeta);
            
            superConstructorIndices = arrayfun(@(c)~strcmp(c.Name, regexp(c.DefiningClass.Name, '\w+$', 'match', 'once')), methodMetaData);
            
            methodMetaData = methodMetaData(superConstructorIndices);
            
            if this.onlyLocalHelp
                % remove all inherited methods
                methodMetaData(arrayfun(@(c)~strcmp(c.DefiningClass.Name, this.mFileName), methodMetaData)) = [];
            end
            
            % filter methods which are not valid identifiers
            methodMetaData(arrayfun(@(c)~(isvarname(c.Name)||iskeyword(c.Name)), methodMetaData)) = [];
            
            % get abstract methods out before local methods are removed
            % since abstract methods are not recognized by which -subfun
            abstractIndices = [methodMetaData.Abstract];
            abstractMetaData = methodMetaData(abstractIndices);
            methodMetaData(abstractIndices) = [];
            
            if this.onlyLocalHelp
                classMethodNames = which('-subfun', this.minimalPath);
                localMethods = regexp(classMethodNames, '\w+$', 'match', 'once');
                
                % remove non-local methods
                [~, ia] = intersect({methodMetaData.Name}, localMethods);
                methodMetaData = methodMetaData(ia');
            end
            
            this.StructMethodHelpContainers = this.getClassMembersStruct('methods', methodMetaData);
            this.StructAbstractHelpContainers = this.getClassMembersStruct('methods', abstractMetaData);            
        end
        
        %% ---------------------------------
        function delete(~)
            % disable the directory hashtable
            matlab.internal.language.introspective.hashedDirInfo(false); 
        end
        
        %% ---------------------------------
        function classMemberStruct = getClassMembersStruct(this, memberKeyword, memberMetaArray)
            % GETCLASSMEMBERSSTRUCT - returns a 1x1 struct storing all the
            % ClassMemberHelpContainer objects individually as fields.
            
            classMemberStruct = struct;
            
            for memberMeta = memberMetaArray
                memberHelp = this.getMemberHelp(memberKeyword, memberMeta);
                memberName = memberMeta.Name;

                classMemberStruct.(memberName) = ...
                    matlab.internal.language.introspective.containers.ClassMemberHelpContainer(memberKeyword, ...
                    memberHelp, memberMeta, ~this.onlyLocalHelp);
            end
        end
        
        %% ---------------------------------
        function buildConstructorHelpContainer(this, constructorMeta)
            % BUILDCONSTRUCTORHELPOBJ - initializes constructor help
            % container object
            if ~isempty(constructorMeta)
                constructorMeta = constructorMeta(1);
                constructorHelp = this.getMemberHelp('constructor', constructorMeta);
                this.ConstructorHelpContainer = ...
                    matlab.internal.language.introspective.containers.ClassMemberHelpContainer('constructor', ...
                    constructorHelp, constructorMeta, ~this.onlyLocalHelp);
            else
                % create empty ClassMemberHelpContainer array
                this.ConstructorHelpContainer = matlab.internal.language.introspective.containers.ClassMemberHelpContainer;
                this.ConstructorHelpContainer(end) = [];
            end
        end
        
        %% ---------------------------------
        function helpStr = getMemberHelp(this, memberKeyword, memberMeta)
            % GETMEMBERHELP - this function centralizes all the methods of
            % extracting help for a particular class member.
            switch memberKeyword
            case 'methods'
                elementInfo = this.classInfo.getMethodInfo(memberMeta, ~this.onlyLocalHelp);

            case {'properties', 'events', 'enumeration'}
                elementInfo = this.classInfo.getSimpleElementInfo(memberMeta, memberKeyword);

            case 'constructor'
                elementInfo = this.classInfo.getConstructorInfo(true);
            end
            
            if ~isempty(elementInfo)
                helpStr = elementInfo.getHelp;
            else
                % True for built-in class members.
                % Eg: RandStream.advance method
                helpStr = '';
            end
        end
    end
end

%% ---------------------------------
function memberHelpContainer = getMemberHelpContainer(memberStruct, memberName)
    % GETMEMBERHELPCONTAINER - helper function to retrieve specific help
    % container for a class member
    if isfield(memberStruct, memberName)
        memberHelpContainer = memberStruct.(memberName);
    else
        error(message('MATLAB:introspective:classHelpContainer:UndefinedClassMember', mat2str( memberName )));
    end
    
end

%% ---------------------------------
function metaData = cullMetaData(metaData, elementKeyword)
    % CULLMETADATA - filters out members that are private:
    
    metaData = metaData';
    metaData(arrayfun(@(c)~matlab.internal.language.introspective.isAccessible(c, elementKeyword), metaData)) = [];
    [~, uniqueIndices] = unique({metaData.Name});
    metaData = metaData(uniqueIndices);
end

%% ---------------------------------
function result = hasNoMemberHelp(memberIterator)
    % HASNOMEMBERHELP - given an iterator to class member help
    % containers, hasNoMemberHelp returns false if at least one of the
    % class members has non-null help.  It returns true otherwise.
    result = true;
    
    while memberIterator.hasNext
        memberHelpContainer = memberIterator.next;
        
        if ~isempty(memberHelpContainer.getHelp)
            result = false;
            return;
        end
    end
end
