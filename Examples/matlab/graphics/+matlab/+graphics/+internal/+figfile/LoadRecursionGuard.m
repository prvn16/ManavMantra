classdef LoadRecursionGuard < handle
    % This class is undocumented and will change in a future release
    
    %LoadRecursionGuard Class that tracks recursive file loading
    %
    %  LoadRecursionGuard is a class that is used to track files that are
    %  in the process of being loaded, and check whether a file recursively
    %  tries to load itself again.
    
    %  Copyright 2011-2013 The MathWorks, Inc.

    
    properties(Access=private)
        % Cell array of filenames
        LoadingStack = cell(1, 0);
    end
      
    methods(Access=private)
        function obj = LoadRecursionGuard
            %LoadRecursionGuard Constructor for LoadRecursionGuard class
            %
            %  obj = LoadRecursionGuard constructs a new instance of this
            %  class.  This constructor is private and cannot be called
            %  externally: use the getInstance() method to access a
            %  singleton copy of it.
        end
    end
    
    methods
        function add(obj, file)
            %add Add a new file to the list of those being loaded 
            %
            %  add(obj, file) adds the specified file to the list of those
            %  currently being loaded.  If the file is already in the list
            %  then a load recursion error is thrown.
            
            if obj.isInStack(file)
                error(message('MATLAB:graphics:internal:figfile:LoadRecursionGuard:RecursionError', file));
            end
            obj.LoadingStack{end+1} = file;
        end
        
        function remove(obj, file)
            %remove Remove a file from the list of those being loaded
            
            idx = strcmp(file, obj.LoadingStack);
            obj.LoadingStack(idx) = [];
        end
        
        function guard = addAndRemove(obj, file)
            %addAndRemove Add a file and return an object for auto-removal
            %
            %  remover = addAndRemove(obj, file) adds the specified file to
            %  the list of those being loaded, and returns an object that
            %  will automatically remove the file from the recursion guard
            %  when it is destroyed.
            
            obj.add(file);
            guard = onCleanup(@() obj.remove(file));
        end
    end
    
    methods(Access=private)
        function ret = isInStack(obj, file)
            %isInStack Check whether a file is already being loaded
            ret = any(strcmp(file, obj.LoadingStack));
        end
    end
    
    methods(Static)
        function obj = getInstance()
            %getInstance Get shared instance of the object
            persistent theInstance
            if isempty(theInstance) || ~isvalid(theInstance)
                theInstance = matlab.graphics.internal.figfile.LoadRecursionGuard;
            end
            
            obj = theInstance;
        end
    end
end
