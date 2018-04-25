classdef FileBasedSplitter < matlab.io.datastore.splitter.Splitter
%FILEBASEDSPLITTER   Abstract splitter class for file based datastores.
% This class is the super class for all file based splitters. This class
% enforces subclasses to implement a function to indicate if a given
% splitter has whole file splits or chunked splits.

%   Copyright 2015 The MathWorks, Inc.

    properties (Abstract, GetAccess = 'public', SetAccess = 'private')
        %FILES Files pointed to by the splitter
        %   Every file based splitter needs to implement a files property
        %   which indicates the files the splitter points to.        
        Files;
    end

    methods (Access = 'public', Abstract = true)
        %isFullFileSplitter Returns true if a splitter has whole file splits.
        %   Returns a logical scalar indicating whether a given splitter
        %   has whole file splits or chunked splits.
        tf = isFullFileSplitter(splitter);
        
        %isSplitsOverAllOfFiles Returns true if a splitter splits is guaranteed to cover all of Files property.
        % A FileBasedSplitter that has been partitioned cannot guarantee that
        % the contained collection of splits is equivalent to creating a new
        % splitter from the Files property. This method allows clients of
        % FileBasedSplitter to guard against this.
        tf = isSplitsOverAllOfFiles(splitter);
    end

    methods (Hidden)
        function setFilesOnSplits(splitter, files)
            t = struct2table(splitter.Splits);
            t.Filename = files;
            splitter.Splits = table2struct(t);
        end
    end
end
