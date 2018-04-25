classdef FunctionHandleHolder
    % This class is undocumented.
    
    % FunctionHandleHolder holds onto a function handle and performs
    % save/load in a way that is robust to the defining class being off the
    % path at load time.
    
    % Copyright 2014 The MathWorks, Inc.
    
    
    properties (SetAccess=immutable)
        Function
    end
    
    properties (Constant, Access=private)
        Serializer = matlab.unittest.internal.FunctionHandleSerializer;
    end
    
    methods
        function holder = FunctionHandleHolder(fcn)
            holder.Function = fcn;
        end
        
        function serialized = saveobj(holder)
            import matlab.unittest.internal.FunctionHandleHolder;
            
            serialized.function = holder.Function;
            
            % Also save the file where the function is defined and a serialized
            % representation of the function handle. In the case where the file
            % is off-path at load time, we can use this information to modify
            % the path to try to load the function correctly.
            fcnInfo = functions(holder.Function);
            serialized.file = fcnInfo.file;
            serialized.data = FunctionHandleHolder.Serializer.serialize(holder.Function);
        end
    end
    
    methods (Static)
        function holder = loadobj(serialized)
            import matlab.unittest.internal.FunctionHandleHolder;
            
            fcn = serialized.function;
            fcnInfo = functions(fcn);
            
            % If the function did not load correctly but its defining file
            % exists (meaning we still have some chance for being able to load
            % the function correctly), try adding the function's defining
            % file's folder to the path and loading the function handle again.
            if strcmp(fcnInfo.function, 'UNKNOWN Function') && exist(serialized.file, 'file')
                folder = fileparts(serialized.file);
                
                % Remove class and package folders
                idx = regexp(folder, '[\\/][\+@]', 'once');
                if ~isempty(idx)
                    folder = folder(1:idx-1);
                end
                
                originalPath = path;
                c = onCleanup(@()path(originalPath));
                addpath(folder);
                
                fcn = FunctionHandleHolder.Serializer.deserialize(serialized.data);
            end
            
            holder = FunctionHandleHolder(fcn);
        end
    end
end

