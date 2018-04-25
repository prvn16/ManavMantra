classdef (Hidden) CustomReadDatastore < matlab.io.datastore.FileBasedDatastore &...
                  matlab.io.datastore.mixin.HadoopFileBasedSupport
%CUSTOMREADDATASTORE A File based datastore that supports a custom reader.
%   This class inherits from FileBasedDatastore and uses the mixin
%   HadoopFileBasedSupport. This will be the superclass for all file based
%   datatores that needs a custom reader to be set in the datastore and
%   eventually to its splitter and splitreader. Hadoop file based support
%   is also implemented with methods - areSplitsWholeFile() and
%   areSplitsOverCompleteFiles(). All subclasses must implement
%   validateReadFcn() method to validate the custom reader ReadFcn.
%
%   See also datastore, mapreduce, matlab.io.datastore.ImageDatastore.

%   Copyright 2015-2016 The MathWorks, Inc.
    properties (Dependent)
        %ReadFcn -
        % A custom reader function handle used by read methods.
        ReadFcn;
    end

    properties (Access = protected)
        %SplitterName -
        % Name of a file based splitter used by the CustomReadDatastore.
        SplitterName;
    end

    properties (Constant, Access = private)
        FILE_BASED_SPLITTER_NAME = 'matlab.io.datastore.splitter.FileBasedSplitter';
        CREATE_COPY_WITH_SPLITS_METHOD = 'createCopyWithSplits';
        CREATE_BASIC_SPLIT_METHOD = '.createBasicSplit';
        CREATE_SPLITTER_METHOD = '.create';
    end

    methods
        % Set ReadFcn
        function set.ReadFcn(ds, readFcn)
            try
                validateReadFcn(ds, readFcn);
                ds.Splitter.ReadFcn = readFcn;
                ds.SplitReader.ReadFcn = readFcn;
            catch e
                throw(e);
            end
        end
        % Get ReadFcn
        function readFcn = get.ReadFcn(ds)
            readFcn = ds.Splitter.ReadFcn;
        end
        % Set SplitterName
        function set.SplitterName(ds, splitterName)
            % Make sure the splitter is a concrete subclass of FileBasedSplitter
            % for HadoopFileBasedSupport to work.
            import matlab.io.datastore.CustomReadDatastore;
            import matlab.io.datastore.internal.validators.isConcreteSubclassOf;
            import matlab.io.internal.validators.isString;

            if isString(splitterName) &&...
                    isConcreteSubclassOf(splitterName, CustomReadDatastore.FILE_BASED_SPLITTER_NAME)
                ds.SplitterName = splitterName;
                return;
            end
            error(message('MATLAB:datastoreio:customreaddatastore:invalidSplitterName'));
        end
    end

    methods (Access = protected, Abstract)
        % Validate ReadFcn function handle.
        validateReadFcn(ds, readFcn);
    end

    methods (Access = protected)
        function initFromReadFcn(ds, readFcn, varargin)
            %INITFROMREADFCN -
            %   Initializes datastore by creating a new Splitter and setting the
            %   ReadFcn on to the Splitter.
            import matlab.io.datastore.CustomReadDatastore;

            ds.Splitter = feval([ds.SplitterName, CustomReadDatastore.CREATE_SPLITTER_METHOD],...
                varargin{:});
            ds.Splitter.ReadFcn = readFcn;
            reset(ds);
        end
    end

    methods (Hidden)
        % return true if the splits of this datastore are file at a time
        function tf = areSplitsWholeFile(ds)
            tf = ds.Splitter.isFullFileSplitter();
        end

        % return true if the splits of this datastore span all the files
        % in the Files property in their entirety (non-paritioned)
        function tf = areSplitsOverCompleteFiles(ds)
            tf = ds.Splitter.isSplitsOverAllOfFiles();
        end

        function initFromFileSplit(ds, filename, offset, len)
            %INITFROMFILESPLIT -
            %   Initializes datastore by creating a simple split using filename
            %   offset and length, and creating a new Splitter using that split.
            import matlab.io.datastore.CustomReadDatastore;

            basicSplit = feval([ds.SplitterName, CustomReadDatastore.CREATE_BASIC_SPLIT_METHOD],...
                filename, offset, len);
            ds.Splitter = feval(CustomReadDatastore.CREATE_COPY_WITH_SPLITS_METHOD,...
                ds.Splitter, basicSplit);
            reset(ds);
        end

    end
end
