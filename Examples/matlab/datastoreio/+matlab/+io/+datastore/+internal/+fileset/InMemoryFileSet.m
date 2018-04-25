classdef (Sealed) InMemoryFileSet < matlab.io.datastore.internal.fileset.ResolvedFileSet & ...
        matlab.io.datastore.mixin.CrossPlatformFileRoots
%INMEMORYFILESET A simple in-memory FileSet object for collecting files.
%
%   See also datastore, matlab.io.datastore.Partitionable.

%   Copyright 2017 The MathWorks, Inc.
    properties (Access = private)
        Files
    end

    methods (Access = {?matlab.io.datastore.internal.fileset.ResolvedFileSetFactory})
        function fs = InMemoryFileSet(nvStruct)
            fs = fs@matlab.io.datastore.internal.fileset.ResolvedFileSet(nvStruct);
            fs.Files = string(nvStruct.Files);
            reset(fs);
        end
    end

    methods (Hidden)
        function newCopy = copyWithFileIndices(fs, indices)
            %COPYWITHFILEINDICES This copies the current object using the input indices.
            %   Based on the input indices fileset object creates a copy.
            %   Subclasses must implement on how they can be created from a list of file indices.
            newCopy = copy(fs);
            setFileIndices(newCopy, indices);
            reset(newCopy);
        end
        function setShuffledIndices(fs, indices)
            %SETSHUFFLEDINDICES Set the shuffled indices for the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the shuffled indices.
            setFileIndices(fs,indices);
        end
        function setDuplicateIndices(fs, duplicateIndices, addedIndices)
            %SETDUPLICATEINDICES Set the duplicate indices for the fileset object.
            %   Any subsequent nextfile calls to the fileset object gets the files
            %   using the already existing indices and duplicate indices.
            setFileIndices(fs,duplicateIndices);
        end
        function setFilesAndFileSizes(fs, files, fileSizes)
            %SETFILESANDFILESIZES Set the files and file sizes for the fileset object.
            fs.Files = string(files);
            fs.FileSizes = fileSizes;
            reset(fs);
        end
        function newCopy = copyAndOrShuffle(fs, indices)
            %COPYANDORSHUFFLE This copies the current object, with or without shuffling.
            %   Based on the inputs fileset object can decide to either copy
            %   and/or shuffle the fileset. If just shuffling is done, then the output
            %   of this function is empty since a copy is not created.
            newCopy = [];
            setFileIndices(fs, indices);
        end
    end

    methods (Access = protected)
        function setFileIndices(fs, indices)
            %SETFILEINDICES A helper to set the indices for files and file sizes.
            fs.Files = fs.Files(indices);
            fs.FileSizes = fs.FileSizes(indices);
        end
        function [files, fileSizes] = resolveAll(fs)
            files = fs.Files;
            fileSizes = fs.FileSizes;
        end

        function f = resolveNextFile(fs)
            f = fs.Files(fs.CurrentFileIndex);
        end

        function files = getFilesAsCellStr(fs, ii)
            % Implementation to obtain a column cell array of files
            % that can be obtained from the fileset object.
            files = cellstr(fs.Files(ii));
        end

        function tf = isEmptyFiles(fs)
            tf = fs.NumFiles == 0;
        end

        function setTransformedFiles(fs, files)
            fs.Files = files;
        end

        function files = getFilesForTransform(fs)
            files = fs.Files;
        end
    end
end
