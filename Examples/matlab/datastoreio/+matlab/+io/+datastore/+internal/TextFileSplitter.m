classdef TextFileSplitter < matlab.io.datastore.internal.FileSplitter
%TextFileSplitter   Class for creating splits from text files.

%   Copyright 2015 The MathWorks, Inc.

    properties (Dependent = true, Access = 'public')
        FileEncoding;
    end
    
    properties (Access = 'private')
        PrivateFileEncoding = 'UTF-8';
    end
    
    properties (Constant = true, Access = 'private')
        DEFAULT_FILE_ENCODING = 'UTF-8';
    end
    
    methods (Static = true, Access = 'public')
        function this = create(files, fileEncoding, splitSize)
            import matlab.io.datastore.internal.FileSplitter;
            import matlab.io.datastore.internal.TextFileSplitter;
            
            narginchk(1,3);
            
            if nargin < 3
                splitSize = FileSplitter.DEFAULT_SPLIT_SIZE;
            end
            
            if nargin < 2
                fileEncoding = TextFileSplitter.DEFAULT_FILE_ENCODING;
            end
            
            [fileEncoding, splitSize] = ...
                                     updateEncodingSplitSize(fileEncoding, splitSize);
            
            [files, splits, splitSize] = ...
                                 FileSplitter.createArgs(files, splitSize);
            this = ...
                  TextFileSplitter(files, splits, splitSize, fileEncoding);
        end
        
        function this = createFromSplits(splits, fileEncoding)
            import matlab.io.datastore.internal.FileSplitter;
            import matlab.io.datastore.internal.TextFileSplitter;
            
            narginchk(1,2);
            
            if nargin < 2
                fileEncoding = TextFileSplitter.DEFAULT_FILE_ENCODING;
            end
            
            [files, splits, splitSize] = ...
                                 FileSplitter.createFromSplitsArgs(splits);

             % this fucntion is called only from partition on a splitter,
             % and we are rest assured that the encoding is canonical and
             % the splits are conformant to the encoding, so there is no
             % need to verify that they are conformant.
             %
             % [fileEncoding, splitSize] = ...
             %            updateEncodingSplitSize(fileEncoding, splitSize);
             % [files, splits, splitSize] = ...
             %                   FileSplitter.createArgs(files, splitSize);
             
            this = TextFileSplitter(files, splits, splitSize, fileEncoding);
        end
    end
    
    methods (Access = 'private')
        function this = TextFileSplitter(files, splits, splitSize, fileEncoding)
            this@matlab.io.datastore.internal.FileSplitter(files, ...
                                                        splits, splitSize);
            this.PrivateFileEncoding = fileEncoding;
        end
    end

    methods
        % FileEncoding setter
        function set.FileEncoding(this, fileEncoding)
            if ~isempty(this.Splits)
                [fileEncoding, splitSize] = ...
                     updateEncodingSplitSize(fileEncoding, this.SplitSize);
                 % does nothing if the splitsize did not change.
                changeSplitSize(this, splitSize);
                this.PrivateFileEncoding = fileEncoding;
            end
        end
        
        % FileEncoding getter
        function fileEncoding = get.FileEncoding(this)
            fileEncoding = this.PrivateFileEncoding;
        end
    end
    
    methods (Access = 'public')
        function changeSplitSize(this, splitSize)
            [~, splitSize] = ...
                     updateEncodingSplitSize(this.FileEncoding, splitSize);
            changeSplitSize@matlab.io.datastore.internal.FileSplitter(this, splitSize);
        end
    end
end

function [fileEncoding, splitSize] = updateEncodingSplitSize(fileEncoding, splitSize)
%UPDATEENCODINGSPLITSIZE Updates file encoding and split size.
%   This function returns a splitSize of Inf if the given fileEncoding is
%   non-seekable, otherwise returns the given splitSize. This function
%   additionally returns the canonical name.

import matlab.io.datastore.internal.encodingStats;

encStats = encodingStats(fileEncoding);

if ~encStats.IsSeekable % non-seekable must have whole file splits.
    splitSize = Inf;
     % this code needs to be commented out when Kalsi's change goes in this
     % change would also change setUpSplitter in TabularText and
     % validateReadSize to not special case for Inf, changeSplitSize can
     % now be protected in FileSplitter, changeSplitSize needs to be
     % implemented for now as we need to accomodate changes in ReadSize to
     % change SplitSize. In the future we do not need this, as ReadSize
     % will have no control on SplitSize
     %
     % elseif isinf(splitSize) % seekable must use default split size
     %     splitSize = FileSplitter.DEFAULT_SPLIT_SIZE;
end

fileEncoding = encStats.CanonicalName;
end