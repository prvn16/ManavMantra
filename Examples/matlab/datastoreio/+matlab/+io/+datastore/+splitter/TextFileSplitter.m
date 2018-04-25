classdef TextFileSplitter < matlab.io.datastore.splitter.FileSizeBasedSplitter
%TEXTFILESPLITTER   Class for creating splits from text files.

%   Copyright 2015 The MathWorks, Inc.

    properties (Dependent)
        % FileEncoding to use for the stream.
        FileEncoding;
    end
    
    properties
        % End of record (line) to use for reading correctly.
        EOR = [];
    end
    
    properties (Access = 'private')
        PrivateFileEncoding = 'UTF-8';
    end
    
    properties (Constant, Access = 'private')
        DEFAULT_FILE_ENCODING = 'UTF-8';
        DEFAULT_EOR = '\r\n';
    end
    
    methods (Static)
        function this = create(files, splitSize, fileEncoding, eor, fileSizes)
        %CREATE Create a TextFileSplitter.
        
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            import matlab.io.datastore.splitter.TextFileSplitter;
            
            narginchk(1,5);
            
            if nargin < 2
                splitSize = FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE;
                fileEncoding = TextFileSplitter.DEFAULT_FILE_ENCODING;
                eor = TextFileSplitter.DEFAULT_EOR;
                fileSizes = [];
            end
            
            if nargin < 3
                fileEncoding = TextFileSplitter.DEFAULT_FILE_ENCODING;
                eor = TextFileSplitter.DEFAULT_EOR;
                fileSizes = [];
            end
            
            if nargin < 4
                eor = TextFileSplitter.DEFAULT_EOR;
                fileSizes = [];
            end
            
            if nargin < 5
                fileSizes = [];
            end
            
            % make fileEncoding, splitSize compatible
            [fileEncoding, newSplitSize] = ...
                           TextFileSplitter.validateProps(fileEncoding, ...
                                                          splitSize, true);
            % get FileSizeBasedSplitter constructor args
            [splits, newSplitSize] = ...
                              FileSizeBasedSplitter.createArgs(files, newSplitSize, fileSizes);
            
            % construct TextFileSplitter
            this = TextFileSplitter(splits, newSplitSize, fileEncoding, eor);
        end
        
        function this = createFromSplits(splits)
        %CREATEFROMSPLITS Create a TextFileSplitter given existing splits.
        %   This method is usally called from loadobj.
        
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            import matlab.io.datastore.splitter.TextFileSplitter;
            
            narginchk(1,2);
            
            fileEncoding = TextFileSplitter.DEFAULT_FILE_ENCODING;
            eor = TextFileSplitter.DEFAULT_EOR;
            
            [splits, splitSize] = FileSizeBasedSplitter.createFromSplitsArgs(splits);

            this = TextFileSplitter(splits, splitSize, fileEncoding, eor);
        end
    end
    
    methods (Access = 'protected')
        function this = TextFileSplitter(splits, splitSize, fileEncoding, eor)
            this@matlab.io.datastore.splitter.FileSizeBasedSplitter(splits, splitSize);
            this.PrivateFileEncoding = fileEncoding;
            this.EOR = eor;
        end
    end

    methods
        % FileEncoding setter
        function set.FileEncoding(this, fileEncoding)
            import matlab.io.datastore.splitter.TextFileSplitter;
            if ~isempty(this.Splits)
                [fileEncoding, splitSize] = ...
                     TextFileSplitter.validateProps(fileEncoding, this.SplitSize);
                 % does nothing if the splitsize did not change.
                changeSplitSize(this, splitSize);
                this.PrivateFileEncoding = fileEncoding;
            end
        end
        
        % EOR setter
        function set.EOR(this, eor)
            this.EOR = validateEOR(eor);
        end
        
        % FileEncoding getter
        function fileEncoding = get.FileEncoding(this)
            fileEncoding = this.PrivateFileEncoding;
        end
    end
    
    methods
        function cp = createCopyWithSplits(this, splits)
        %CREATECOPYWITHSPLITS Create Splitter from existing Splits.
        %   Creates a splitter that is identical except for the splits it
        %   contains. Splits passed as input must be of identical in
        %   structure to the splits used by this Spltiter class.
        
            cp = copy(this);
            cp.Splits = splits;
        end
        
        function rdr = createReader(this, ii)
        %CREATEREADER Create a reader for the ii-th split.
        
            rdr = matlab.io.datastore.splitreader.TextFileSplitReader;
            rdr.Split = this.Splits(ii);
            rdr.FileEncoding = this.FileEncoding;
            rdr.EOR = this.EOR;
        end
        
        function useFullFile(this, isFullFile)
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            resizeSplits(this, isFullFile, FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE, false);
        end

        function resizeHadoopSplits(this, splitSize)
            % resize hadoop splits to the provided splitSize
            % We want to force the resizing of splits for Hadoop splits
            isFullFile = isFullFileSplitter(this);
            resizeSplits(this, isFullFile, splitSize, true);
        end
    end

    methods (Access = private)
        function resizeSplits(this, isFullFile, splitSize, forceChange)
            if isFullFile
                % Full file assumes reading all of the data from the file
                % Resize to the maximum available from FileSize
                this.changeSplitSize(Inf, forceChange);
            else
                import matlab.io.datastore.splitter.TextFileSplitter;
                % Validate based on FileEncoding, etc
                [~, splitSize] = ...
                    TextFileSplitter.validateProps(this.FileEncoding, splitSize);
                this.changeSplitSize(splitSize, forceChange);
            end
        end
    end
    
    methods (Static, Access = 'private')
        function [fileEncoding, splitSize] = validateProps(fileEncoding, splitSize, forSplitSizeForSeekableEnc)
        %VALIDATEPROPS Updates file encoding and split size.
        %   This function returns a splitSize of Inf if the given
        %   fileEncoding is non-seekable. For seekable encodings a non-Inf
        %   splitSize is returned based on the input splitSize and
        %   useGiveSplitSize. This function additionally returns the
        %   canonical name.

            import matlab.io.datastore.internal.encodingStats;
            import matlab.io.datastore.splitter.FileSizeBasedSplitter;
            
            % do not enforce using the given split size by default
            if nargin < 3
                forSplitSizeForSeekableEnc = false;
            end
            
            % get the canonical name
            encStats = encodingStats(fileEncoding);
            fileEncoding = encStats.CanonicalName;
            
            % non-seekable -> whole file splits.
            % seekable encoding -> 32 MB splits only when splitSize
            % provided is Inf and splitSize is allowed to be modified.
            if ~encStats.IsSeekable 
                splitSize = Inf;
            elseif isinf(splitSize) && ~forSplitSizeForSeekableEnc
                splitSize = FileSizeBasedSplitter.DEFAULT_SPLIT_SIZE;
            end
        end
    end
end

function eor = validateEOR(eor)
%VALIDATEEOR Validates a given end of record
%   This function is only responsible for validating a given end of record
%   and returning the unescaped version of it, if it is one of the standard
%   delimiters.

    % empty eor is not allowed
    if isempty(eor) || ~ischar(eor)
        error(message('MATLAB:datastoreio:tabulartextdatastore:invalidRowDelimiter'));
    end

    % check if its a standard eor, return the unsprintfed version
    [stdFlag, eor] = isStandardEOR(eor);

    % if non-standard, it must be a single character
    if ~stdFlag && 1 ~= numel(eor)
        error(message('MATLAB:datastoreio:tabulartextdatastore:invalidRowDelimiter'));
    end
end

function [ tf, eor ] = isStandardEOR(eor)
%ISSTANDARDEOR checks if the given eor is standard.
%   This function compares the specified eor with the supported standard
%   eor's. It returns a flag indicating whether the given eor was valid. It
%   also returns a valid (un sprintffed) eor back for easy display in the
%   object.

    tf = true;

    if any(strcmp(eor, {'\r\n', sprintf('\r\n')}))
       eor = '\r\n';    
    elseif any(strcmp(eor, {'\n', sprintf('\n')}))
        eor = '\n';
    elseif any(strcmp(eor, {'\r', sprintf('\r')}))
        eor = '\r';
    else
        tf = false;
    end
end
