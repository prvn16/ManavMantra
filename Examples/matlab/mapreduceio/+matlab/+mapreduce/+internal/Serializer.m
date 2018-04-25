classdef (Hidden) Serializer < handle
%SERIALIZER A serializer to write arrays to disk.
%
%   See also tall, mapreduce, datastore.

%   Copyright 2016-2017 The MathWorks, Inc.

    properties (Access = protected)
        OutputFolder;
        SerializedFiles;
        NthFile = 1;
        OutputFileName;
    end

    properties (Constant = true, Access = protected)
        DEFAULT_FLUSH_LIMIT = 32 * 1024 * 1024; % 32 MB
        DEFAULT_FILE_EXTENSION = '.mat';
        DEFAULT_FILEPREFIX_SEPARATOR = '_';
        FILE_NUMBER_FILL = '%05i';
    end

    methods (Abstract)
        %serialize(kvsr, varargin)
        %   Serialize given arrays to disk appropriate for the
        %   object that owns this Serializer.
        %   Return logical true if serialized else return logical false.
        tf = serialize(obj, varargin);
    end

    methods (Access = protected)
        function writeToMatfile(obj, structS)
            %writeToMatfile(obj, structS)
            %   Save the structS to MAT-file using struct-save syntax. 
            matlab.mapreduce.internal.checkFolderExistence(obj.OutputFolder);
            newFilename = fullfile(obj.OutputFolder, sprintf(obj.OutputFileName, obj.NthFile));
            oldWarnState = warning('error', 'MATLAB:save:sizeTooBigForMATFile');
            oldWarnCleanup = onCleanup(@() warning(oldWarnState));
            try
                save(newFilename, '-struct', 'structS');
            catch err
                % Size for saving to default MAT-Files must be less than 2GB.
                % If not error.
                if isequal(err.identifier, 'MATLAB:save:sizeTooBigForMATFile')
                    error(message('MATLAB:mapreduceio:serializer:greaterThanTwoGig'));
                else
                    throw(err);
                end
            end
            obj.SerializedFiles{obj.NthFile} = newFilename;
            obj.NthFile = obj.NthFile + 1;
        end
    end

end % classdef end
