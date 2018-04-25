classdef WholeFileCustomReadSplitter < matlab.io.datastore.splitter.WholeFileSplitter
% WHOLEFILECUSTOMREADSPLITTER Splitter for creating full file splits with custom reader.
%
% See also - matlab.io.datastore.ImageDatastore

%   Copyright 2015-2017 The MathWorks, Inc.

    properties (Hidden)
        % Custom read function
        ReadFcn;
    end

    methods (Static, Hidden)
        function splitter = create(files, fileSizes, includeSubfolders)
            import matlab.io.datastore.splitter.WholeFileSplitter;
            import matlab.io.datastore.splitter.WholeFileCustomReadSplitter;
            narginchk(1,3);
            switch nargin
                case 1
                    fileSizes = [];
                    includeSubfolders = false;
                case 2
                    includeSubfolders = false;
            end
            % Use WholeFileSplitter to create splits.
            splits = WholeFileSplitter.createArgs(files, fileSizes, includeSubfolders);
            splitter = WholeFileCustomReadSplitter(splits);
        end
        function splitter = createFromSplits(splits)
            import matlab.io.datastore.splitter.WholeFileSplitter;
            import matlab.io.datastore.splitter.WholeFileCustomReadSplitter;
            % Use WholeFileSplitter to create splits.
            splits = WholeFileSplitter.createFromSplitsArgs(splits);
            splitter = WholeFileCustomReadSplitter(splits);
        end
    end

    methods (Access = protected)
        function splitter = WholeFileCustomReadSplitter(splits)
            splitter@matlab.io.datastore.splitter.WholeFileSplitter(splits);
        end
    end

    methods (Hidden)
        % Return file names as a cellstr for specific indices
        function files = getFilesAsCellStr(splitter, idxes)
            if splitter.NumSplits == 0
                files = {};
                return;
            end
            if nargin == 1
                files = {splitter.Splits.Filename};
            else
                files = {splitter.Splits(idxes).Filename};
            end
            files = files(:);
        end

        % Return file sizes as a column vector for specific indices
        function fileSizes = getFileSizes(splitter, idxes)
            if splitter.NumSplits == 0
                fileSizes = [];
                return;
            end
            if nargin == 1
                fileSizes = [splitter.Splits.FileSize];
            else
                fileSizes = [splitter.Splits(idxes).FileSize];
            end
            fileSizes = fileSizes(:);
        end

        % Return a reader for the ii-th split.
        function rdr = createReader(splitter, ii)
            rdr = matlab.io.datastore.splitreader.WholeFileCustomReadSplitReader;
            rdr.ReadFcn = splitter.ReadFcn;
            rdr.Split = splitter.Splits(ii);
        end

        % Create Splitter from existing Splits
        %
        % Splits passed as input must be of identical in structure to the
        % splits used by this Spltiter class.
        function splitterCopy = createCopyWithSplits(splitter, splits)
            splitterCopy = splitter.createFromSplits(splits);
            splitterCopy.ReadFcn = splitter.ReadFcn;
        end

        function setSplitsWithInfo(splitter, splitsSetterFcn, varargin)
            % Set any additional information to each of the splits.
            %
            % This is useful, when each of the splits need any additional metadata needed
            % for later computation, but not necessary during construction.
            %
            % splitsSetterFcn needs to be a function handle, that can take atleast 1 input argument.
            %  - The first input argument will be the splits.
            %  - Any additional input arguments in varargin are passed to splitsSetterFcn.
            if ~isa(splitsSetterFcn, 'function_handle') || nargin(splitsSetterFcn) == 0
                msg = 'Input must be a function handle';
                error('MATLAB:datastoreio:wholefilecustomreadsplitter:invalidSplitsSetFcn', msg);
            end
            splitter.Splits = splitsSetterFcn(splitter.Splits, varargin{:});
        end
    end
end
