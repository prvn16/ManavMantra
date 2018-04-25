classdef SerialMapReducer < matlab.mapreduce.MapReducer
%SERIALMAPREDUCER A non-parallel execution environment for mapreduce.
%   mapreducer(0) sets the mapreduce execution environment to be the local
%   MATLAB session and a SERIALMAPREDUCER will be used as the default
%   mapreducer.
%
%   MR = mapreducer(0) sets the default mapreducer to be SERIALMAPREDUCER
%   and MR is a SERIALMAPREDUCER, which can be used as the fourth input
%   argument to mapreduce.
%   Example:
%        mr = mapreducer(0);
%        outds = mapreduce(inputds, @mapfun, @reducefun, mr);
%
%   See also mapreduce, mapreducer.

%   Copyright 2014-2017 The MathWorks, Inc.

    properties (Access = private)
        BinaryOutput;
        DisplayOn;
        Serializer;
    end

    properties (Constant, Access = private)
        OUTPUT_FILE_PREFIX = 'results';
        OUTPUT_TYPE_NV_STRINGS = {'Binary', 'TabularText'};
        DISPLAY_NV_STRINGS = {'On', 'Off'};
    end

    methods (Access = private)

        function settings = checkSettings(obj, settings)
            import matlab.mapreduce.SerialMapReducer;
            import matlab.io.datastore.internal.PathTools;
            if isempty(settings.OutputFolder)
                settings.OutputFolder = pwd;
            else
                try
                    settings.OutputFolder = PathTools.ensureIsLocalPath(settings.OutputFolder);
                catch e
                    % We translate this error message to add context.
                    if strcmp(e.identifier, 'MATLAB:datastoreio:pathlookup:unsupportedIRIScheme')
                        error(message('MATLAB:mapreduceio:serialmapreducer:unsupportedOutputIriScheme', settings.OutputFolder));
                    end
                    rethrow(e);
                end
            end
            matlab.mapreduce.internal.validateFolderForWriting(settings.OutputFolder);
            ot = strcmpi(settings.OutputType, SerialMapReducer.OUTPUT_TYPE_NV_STRINGS);
            obj.BinaryOutput = ot(1);
            dispon = strcmpi(settings.Display, SerialMapReducer.DISPLAY_NV_STRINGS);
            obj.DisplayOn = dispon(1);
        end

        function [kvs, bb, tempResourceDir] = getMapKVS(~)
            import matlab.mapreduce.internal.*;
            tempResourceDir = createTempLocalFolder;
            [~, basename] = fileparts(tempname);
            tempResource = fullfile(tempResourceDir, basename);
            bb = KeyValueStore(tempResource, 'create', 'delete');
            kvs = matlab.mapreduce.KeyValueStore(MapKVSerializer(bb), ...
                MapKVProcessor(bb), KeyValueVector());
            createStore(bb, 'SerialMapStore');
            selectStoreToWrite(bb, 'SerialMapStore');
        end

        function kvs = getReduceKVS(obj, bb, settings)
            import matlab.mapreduce.internal.*;
            f = settings.OutputFolder;
            if obj.BinaryOutput
                kvp = KeyValueProcessor();
                obj.Serializer = ReduceKVSerializer(...
                    matlab.mapreduce.SerialMapReducer.OUTPUT_FILE_PREFIX, f, datestrnow);
            else
                kvp = TextKeyValueProcessor();
                obj.Serializer = ReduceTextKVSerializer(...
                    matlab.mapreduce.SerialMapReducer.OUTPUT_FILE_PREFIX, f, datestrnow);
            end
            kvv = KeyValueVector();
            kvs = matlab.mapreduce.KeyValueStore(obj.Serializer, kvp, kvv);
            createStoreKeyIndex(bb, 'SerialMapStore');
            selectStoreToRead(bb, 'SerialMapStore');
        end
    end

    methods (Hidden)
        function outputds = execMapReduce(obj, inputds, mapFcn, redFcn, settings)
            import matlab.mapreduce.internal.*;
            import matlab.mapreduce.*;
            % Parse Name-Value pairs
            %settings = SerialMapReducer.parseSettings(varargin{:});
            % Check the settings from Name-Value pairs
            settings = checkSettings(obj, settings);

            % Get map phase KeyValueStore and IKeyValueStore.
            [kvs, bb, resourceDir] = getMapKVS(obj);

            c = onCleanup(@() iCleanupResources(bb, resourceDir));
            % reset the input datastore, since it could have been used to
            % read.
            try
                reset(inputds);
            catch e
                SerialMapReducer.datastoreReadError(inputds, 1, e);
            end

            % Only SplittableDatastores can provide granular progress for
            % map phase
            import matlab.io.datastore.internal.shim.isPartitionable;
            mapProgressOn = obj.DisplayOn && isPartitionable(inputds);
            numMapCalls = 1;
            
            % MapReduce Progress object
            mrprogress = MapReduceProgress(obj.DisplayOn);

            % Display progress header
            mrprogress.PrintHeader();

            mrprogress.PrintZero();

            setReduceProgress(mrprogress, 0);
            % Aha! Map phase.
            while hasdata(inputds)
                try
                    [data, info] = read(inputds);
                catch e
                    SerialMapReducer.datastoreReadError(inputds, numMapCalls, e);
                end               
                clearCache(kvs);
                try
                    mapFcn(data, info, kvs);
                catch e
                    mapFcnStr = SerialMapReducer.createFuncStrWithErrorLine(mapFcn, e);
                    error(message('MATLAB:mapreduceio:serialmapreducer:cannotApplyMap', ...
                          numMapCalls, mapFcnStr, e.message))
                end

                numMapCalls = numMapCalls + 1;
                if mapProgressOn
                    % update progress
                    mrprogress.Progress(progress(inputds)*100);
                end
            end

            % reset the input datastore back.
            reset(inputds);

            % add any buffered key-value pairs
            flush(kvs);
            delete(kvs);

            % Get reduce phase key value store
            kvs = getReduceKVS(obj, bb, settings);
            numKeys = numUniqKeys(bb);

            % Map phase is complete
            setMapProgress(mrprogress, 100);
            mrprogress.PrintMapHundred();

            % Reduce phase
            numReduceCalls = 1;
            for i = 1:numKeys
                if (hasNextKey(bb))
                    key = getNextKey(bb);
                    valList = ValueIterator(key, bb);
                    clearCache(kvs);
                    try
                        redFcn(key, valList, kvs);
                    catch e
                        redFcnStr = SerialMapReducer.createFuncStrWithErrorLine(redFcn, e);
                        error(message('MATLAB:mapreduceio:serialmapreducer:cannotApplyReduce', ...
                              numReduceCalls, redFcnStr, e.message))
                    end
                    delete(valList);
                end
                numReduceCalls = numReduceCalls + 1;
                % update progress
                if i ~= numKeys
                    mrprogress.Progress(i*100/numKeys);
                end                
            end
            % add any buffered key-value pairs
            flush(kvs);
            delete(kvs);

            % Print progress for completion
            mrprogress.PrintHundred();
            delete(mrprogress);

            outputds = constructDatastore(obj.Serializer);
        end
    end

    methods (Static, Hidden, Access = private)                           
        function funcStr = createFuncStrWithErrorLine(func, e)
            funcStr = func2str(func);
            withLine = '';
            for ii = 1:numel(e.stack)
                if strcmp(funcStr, e.stack(ii).name)
                    import matlab.mapreduce.SerialMapReducer;
                    withLine = SerialMapReducer.lineHotLinkFromStack(e.stack(ii));
                    break;
                end
            end
            if feature('hotlinks')
                funcStr = ['<strong>' funcStr '</strong>'];
            end
            if ~isempty(withLine)
                funcStr = [funcStr ' ' withLine];
            end
        end
        
        function withLine = lineHotLinkFromStack(stackElement)
            withLine = '(';
            lineNoStr = num2str(stackElement.line);
            lineStr = ['line ' lineNoStr];
            if feature('hotlinks')
                withLine = [withLine '<a href="'];
                withLine = [withLine 'matlab: opentoline(''' stackElement.file ''',' lineNoStr, ',0)">'];
                withLine = [withLine lineStr '</a>'];
            else
                withLine = [withLine lineStr];
            end
            withLine = [withLine ')'];
        end

        function datastoreReadError(inputds, nMapCalls, e)
            dsClsName = class(inputds);
            dotIdcs = strfind(dsClsName, '.');
            if ~isempty(dotIdcs)
                dsClsName = dsClsName((dotIdcs(end)+1):end);
            end
            if feature('hotlinks')
                dsClsName = ['<strong>' dsClsName '</strong>'];
            end            
            msg = message('MATLAB:mapreduceio:serialmapreducer:cannotReadDatastore', ...
                nMapCalls, dsClsName, e.message);
            eex = MException(msg);
            for ii = 1:numel(e.cause)
                eex = addCause(eex, e.cause{ii});
            end
            throw(eex);
        end

        function resStruct = parseSettings(input)
            persistent p;
            if isempty(p)
                p = inputParser;
                addParameter(p, 'OutputFolder', []);
                addParameter(p, 'OutputType', 'binary');
                addParameter(p, 'Display', 'on');
                p.FunctionName = 'mapreduce';
            end
            p.parse(input{:});
            resStruct = p.Results;
        end
    end

    methods (Access = protected)
        function executor = createPartitionedArrayExecutor(~)
            executor = matlab.bigdata.internal.serial.SerialExecutor();
        end
    end
    
    methods (Access = protected, Static)
        % An override of doCreateFromMemento that constructs a
        % SerialMapReducer from a memento.
        function obj = doCreateFromMemento(m)
            obj = matlab.mapreduce.SerialMapReducer;
            obj.ObjectVisibility = m.ObjectVisibility;
        end
    end
end

function iCleanupResources(bb, resourceDir)
close(bb);
delete(bb);
[status, msg, msgID] = rmdir(resourceDir, 's');
if ~status && ~strcmp(msgID, 'MATLAB:RMDIR:NotADirectory')
    warning(message('MATLAB:mapreduceio:serialmapreducer:cannotRemoveTempResource', msg, resourceDir));
end
end
