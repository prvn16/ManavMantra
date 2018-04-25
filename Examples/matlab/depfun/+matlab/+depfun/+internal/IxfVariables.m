classdef IxfVariables < handle 
% IxfVariables provides a mechanism allowing database paths to use simple
% variable substitution. REQUIREMENTS uses variables to simultaneously 
% accomodate full paths (which make matching more accurate) and the need for
% the database to be free of reference to any individual sandbox. For example,
% IxfVariables can expand the stored path $MATLAB/toolbox/images into the 
% root of the Image Processing Toolbox in the current installation.

    properties (Access = private)
        Variables
        FileSep
        OrderedKeys
    end
    
    methods
        function ixf = IxfVariables(fs)
            ixf.FileSep = fs;
            initialize_path_variables(ixf);
        end

        function bound = bind(obj, free)
        % Given a cell array of strings, replace every variable in every
        % string with the variable's defined value. 
        % (See initialize_path_variables for the values.)

            function item = bind_all(item)
                ks = keys(obj.Variables);
                for k=1:numel(ks)
                    item = strrep(item, ks{k}, obj.Variables(ks{k}));
                end
            end

            if iscell(free)
                bound = cellfun(@(item)bind_all(item), free, ...
                                'UniformOutput', false);
            else
                bound = bind_all(free);
            end
        end

        function free = unbind(obj, bound)

            function item = unbind_all(item, ks)
            % Given a cell array of strings, replace every "variable value"
            % within the string with the variable's name.
            % (See initialize_path_variables for the values.)
            %
            % Unbinding is trickier than binding, because we have no markers
            % to determine the boundaries of the segment we're collapsing int
            % a variable. We must use heuristics to resolve conflict between
            % multiple matches; we take a cue from regular expression matchers
            % and try to replace the longest strings first. 

                for k=1:numel(ks)
                    item = strrep(item, filesep, obj.FileSep);
                    item = strrep(item, obj.Variables(ks{k}), ks{k});
                end
            end

            if iscell(bound)
                free = cellfun(@(item)unbind_all(item, obj.OrderedKeys), ...
                               bound, 'UniformOutput', false);
            else
                free = unbind_all(bound, obj.OrderedKeys);
            end
        end

    end

    methods(Access = private)
        function initialize_path_variables(obj)
        % Create a map to hold the variables used in defining an individual
        % path item. Define each known variable. Must be called by the
        % SearchPath constructor.
        %
        % For ease of maintanence, please keep the list in alphabetical
        % order. (By variable name.)
            obj.Variables = containers.Map;
            obj.Variables('$ARCH') = computer('arch');
            obj.Variables('$MATLAB') = strrep(matlabroot, filesep, obj.FileSep);
            obj.Variables('$MEXEXT') = mexext;
            if ispc
                obj.Variables('$SOEXT') = 'dll';
            elseif ismac
                obj.Variables('$SOEXT') = 'dylib';
            elseif isunix
                obj.Variables('$SOEXT') = 'so';
            else
                error(message('MATLAB:depfun:req:UnknownPlatform'))
            end

            % Create cell-array of keys ordered by value length.
            ks = keys(obj.Variables);
            vlen = cellfun(@(k)numel(obj.Variables(k)), ks);
            [~, ix] = sort(vlen,'descend');
            obj.OrderedKeys = ks(ix);

        end
    end
end
