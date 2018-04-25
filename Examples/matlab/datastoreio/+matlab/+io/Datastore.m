classdef (Abstract) Datastore < matlab.io.datastore.internal.HandleUnwantedHideable &...
                                matlab.mixin.Copyable & matlab.io.datastore.internal.ScalarBase
%DATASTORE Declares the interface expected of datastores.
%   This abstract class captures the interface expected of datastores.
%   Datastores are a way to access collections of data via iteration.
%   Datastore is a handle class and a subclass of matlab.mixin.Copyable.
%
%   Datastore Methods:
%
%   preview         -    Read the subset of data from the datastore that is
%                        returned by the first call to the read method.
%   read            -    Read subset of data from the datastore.
%   readall         -    Read all of the data from the datastore.
%   hasdata         -    Returns true if there is more data in the datastore.
%   reset           -    Reset the datastore to the start of the data.
%   progress        -    Return fraction between 0.0 and 1.0 indicating
%                        percentage of consumed data.
%
%   Datastore Method Attributes:
%
%   preview         -   Public
%   read            -   Public, Abstract
%   readall         -   Public
%   hasdata         -   Public, Abstract
%   reset           -   Public, Abstract
%   progress        -   Hidden, Abstract
%
%   This class implements the preview and readall methods. The
%   read, hasdata, progress, and reset methods have to be implemented by
%   subclasses derived from the Datastore class. The default
%   implementations for preview and readall are not optimized for tall
%   array construction. It is recommended to implement efficient versions
%   of these methods for improved tall array performance.
%
%   Example Implementation:
%   ----------------------
%   % Creating a custom datastore by inheriting from matlab.io.Datastore
%   classdef MyDatastore < matlab.io.Datastore
%       properties(Access = private)
%           % This class consists of 2 properties FileSet and CurrentFileIndex
%           FileSet matlab.io.datastore.DsFileSet
%           CurrentFileIndex double
%      end
%
%       methods(Access = public)
%           function myds = MyDatastore(location)
%               % The class constructor to set properties of the datastore.
%               myds.FileSet = matlab.io.datastore.DsFileSet(location, ...
%                   'FileExtensions', '.bin', 'FileSplitSize', 8*1024);
%               myds.CurrentFileIndex = 1;
%               reset(myds);
%           end
%
%           function tf = hasdata(myds)
%               %HASDATA   Returns true if more data is available.
%               %   Return logical scalar indicating availability of data.
%               %   This method should be called before calling read. This
%               %   is an abstract method and must be implemented by the
%               %   subclasses. hasdata is used in conjunction with read to
%               %   read all the data within the datastore.
%               tf = hasfile(myds.FileSet);
%           end
%
%           function [data, info] = read(myds)
%               %READ   Read data and information about the extracted data.
%               %   Return the data extracted from the datastore in the
%               %   appropriate form for this datastore. Also return
%               %   information about where the data was extracted from in
%               %   the datastore. Both the outputs are required to be
%               %   returned from the read method, and can be of any type.
%               %   info is recommended to be a struct with information
%               %   about the chunk of data read. data represents the
%               %   underlying class of tall, if tall is created on top of
%               %   this datastore. This is an abstract method and must be
%               %   implemented by the subclasses.
%
%               % In this example, the read method reads data from the
%               % datastore using a custom reader function, MyFileReader,
%               % which takes the resolved filenames as input. CurrentFileIndex
%               % is updated every time a new file is read.
%               if ~hasdata(myds)
%                   error(sprintf('No more data to read.\nUse reset method to reset the datastore to the start of the data. Before calling the read method, check if data is available to read by using the hasdata method.')); %#ok<SPERR>
%               end
%
%               file = nextfile(myds.FileSet);
%               data = MyFileReader(file);
%               info.Size = size(data);
%               info.FileName = file.FileName;
%               info.Offset = file.Offset;
%
%               % Update CurrentFileIndex when nextfile changes
%               if file.Offset + file.SplitSize >= file.FileSize
%                   myds.CurrentFileIndex = myds.CurrentFileIndex + 1;
%               end
%           end
%
%           function reset(myds)
%               %RESET   Reset to the start of the data.
%               %   Reset the datastore to the state where no data has been
%               %   read from it. This is an abstract method and must be
%               %   implemented by the subclasses.
%
%               % In this example, the datastore is reset to point to the
%               % first file (and first partition) in the datastore.
%               reset(myds.FileSet);
%               myds.CurrentFileIndex = 1;
%           end
%
%           function frac = progress(myds)
%               %PROGRESS   Percentage of consumed data between 0.0 and 1.0.
%               %   Return fraction between 0.0 and 1.0 indicating progress as a
%               %   double. The provided example implementation returns the
%               %   ratio of the index of the current file from DsFileSet
%               %   to the number of files in DsFileSet. A simpler
%               %   implementation can be used here that returns a 1.0 when all
%               %   the data has been read from the datastore, and 0.0
%               %   otherwise.
%               %
%               %   See also matlab.io.Datastore, read, hasdata, reset, readall,
%               %   preview.
%               frac = (myds.CurrentFileIndex-1)/myds.FileSet.NumFiles;
%           end
%       end
%
%       methods(Access = protected)
%           function dsCopy = copyElement(ds)
%               %COPYELEMENT   Create a deep copy of the datastore
%               %   Create a deep copy of the datastore. We need to call
%               %   copy on the datastore's property FileSet, because it is
%               %   a handle object. Creating a deep copy allows methods
%               %   such as readall and preview, that call the copy method,
%               %   to remain stateless.
%               dsCopy = copyElement@matlab.mixin.Copyable(ds);
%               dsCopy.FileSet = copy(ds.FileSet);
%           end
%       end
%   end
%
%   function data = MyFileReader(fileInfoTbl)
%   % create a custom reader object for the specified file
%   reader = matlab.io.datastore.DsFileReader(fileInfoTbl.FileName);
%
%   % seek to the offset
%   seek(reader,fileInfoTbl.Offset,'Origin','start-of-file');
%
%   % read fileInfoTbl.Size amount of data
%   % the data returned from MyFileReader is a uint8 column vector
%   data = read(reader,fileInfoTbl.SplitSize);
%   end
%
%   Example usage:
%   -------------
%   myFiles = fullfile(matlabroot, 'examples', 'matlab', '*.bin');
%   ds = MyDatastore(myFiles);
%   % while there is more data available in the datastore, read from the
%   % datastore
%   while hasdata(ds)
%       [data, info] = read(ds);
%   end
%
%   % reset to read from start of the datastore
%   reset(ds);
%   % read the first file in the datastore
%   [data, info] = read(ds);
%   % read all the data in the datastore
%   dataAll = readall(ds);
%
%   See also datastore, mapreduce, matlab.io.datastore.Partitionable, matlab.io.datastore.HadoopFileBased.

%   Copyright 2017 The MathWorks, Inc.

    methods(Abstract, Access = public)
        %HASDATA   Returns true if more data is available.
        %   Return logical scalar indicating availability of data. This
        %   method should be called before calling read. This is an
        %   abstract method and must be implemented by the subclasses.
        %   hasdata is used in conjunction with read to read all the data
        %   within the datastore. Following is an example usage:
        %
        %   ds = myDatastore(...);
        %   while hasdata(ds)
        %       [data, info] = read(ds);
        %   end
        %
        %   % reset to read from start of the data
        %   reset(ds);
        %   [data, info] = read(ds);
        %
        %   See also matlab.io.Datastore, read, reset, readall, preview,
        %   progress.
        tf = hasdata(ds);

        %READ   Read data and information about the extracted data.
        %   Return the data extracted from the datastore in the
        %   appropriate form for this datastore. Also return
        %   information about where the data was extracted from in
        %   the datastore. Both the outputs are required to be
        %   returned from the read method, and can be of any type.
        %   info is recommended to be a struct with information
        %   about the chunk of data read. data represents the
        %   underlying class of tall, if tall is created on top of
        %   this datastore. This is an abstract method and must be
        %   implemented by the subclasses.
        %
        %   See also matlab.io.Datastore, hasdata, reset, readall, preview,
        %   progress.
        [data, info] = read(ds);

        %RESET   Reset to the start of the data.
        %   Reset the datastore to the state where no data has been
        %   read from it. This is an abstract method and must be
        %   implemented by the subclasses.
        %   In the provided example, the datastore is reset to point to the
        %   first file (and first partition) in the datastore.
        %
        %   See also matlab.io.Datastore, read, hasdata, readall, preview,
        %   progress.
        reset(ds);
    end

    % Default implementation for Datastore %
    methods(Access = public)
        function data = readall(ds)
            %READALL   Attempt to read all data from the datastore.
            %   Returns all the data in the datastore and resets it.
            %   This is the default implementation for the readall method,
            %   subclasses can implement an efficient version of this method
            %   by preallocating the data variable. Subclasses should also
            %   consider implementing a more efficient version of this
            %   method for improved tall array construction performance.
            %   In the provided default implementation, a copy of the 
            %   original datastore is first reset. While hasdata is true,
            %   it calls read on the copied datastore in a loop.
            %   All the data returned from the individual reads should be
            %   vertically concatenatable, and the datatype of the output
            %   should be the same as that of the read method.
            %
            %   See also matlab.io.Datastore, read, hasdata, reset, preview,
            %   progress.
            copyds = copy(ds);
            reset(copyds);
            data = read(copyds);
            while hasdata(copyds)
                data = [data; read(copyds)]; %#ok<AGROW>
            end
        end

        function data = preview(ds)
            %PREVIEW   Preview the data contained in the datastore.
            %   Returns a small amount of data from the start of the datastore.
            %   This is the default implementation of the preview method,
            %   subclasses can implement an efficient version of this method
            %   by returning a smaller subset of the data directly from the
            %   read method. Subclasses should also consider implementing a
            %   more efficient version of this method for improved tall 
            %   array construction performance. The datatype of the output
            %   should be the same as that of the read method. In the 
            %   provided default implementation, a copy of the datastore is
            %   first reset. The read method is called on this copied 
            %   datastore. The first 8 rows in the output from the read 
            %   method call are returned as output of the preview method.
            %
            %   See also matlab.io.Datastore, read, hasdata, reset, readall,
            %   progress.
            copyds = copy(ds);
            reset(copyds);
            data = read(copyds);
            otherDims = repmat({':'}, 1, ndims(data) - 1);
            numRows = min(8,size(data,1));
            substr = substruct('()', [{1:numRows}, otherDims]);
            data = subsref(data, substr);
        end
    end

    methods(Hidden, Abstract)
        %PROGRESS   Percentage of consumed data between 0.0 and 1.0.
        %   Return fraction between 0.0 and 1.0 indicating progress as a
        %   double. The provided example implementation returns the
        %   ratio of the index of the current file from DsFileSet
        %   to the number of files in DsFileSet. A simpler
        %   implementation can be used here that returns a 1.0 when all
        %   the data has been read from the datastore, and 0.0
        %   otherwise.
        %
        %   See also matlab.io.Datastore, read, hasdata, reset, readall,
        %   preview.
        frac = progress(ds);
    end
end
