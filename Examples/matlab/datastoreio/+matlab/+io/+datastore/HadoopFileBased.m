classdef HadoopFileBased < handle
% HADOOPFILEBASED Declares the interface that adds support for Hadoop to
% the datastore.
%   This abstract class is a mixin for subclasses of matlab.io.Datastore
%   that adds support for Hadoop to the datastore.
%
%   HadoopFileBased Methods:
%
%   initializeDatastore   -    Initializes the datastore with necessary
%                              split information sent from Hadoop.
%   isfullfile            -    Returns a logical indicating whether or not
%                              initializeDatastore method must get information
%                              for one complete file.
%   getLocation           -    Returns the location to which this
%                              datastore points. This can be a file list,
%                              list of directories, or a DsFileSet. This
%                              method should throw an error if the datastore
%                              represents a file or a collection of files
%                              that are not over complete files. 
%                              This can occur when:
%                              1) partitioning the datastore using DsFileSet's
%                              partition method, or 
%                              2) when the FileSplitSize option of DsFileSet is
%                              not 'file' and when isfullfile is false.
%
%   HadoopFileBased Method Attributes:
%
%   initializeDatastore   -    Hidden, Abstract
%   getLocation           -    Hidden, Abstract
%   isfullfile            -    Hidden, Abstract
%
%   The initializeDatastore, getLocation, and isfullfile methods have to
%   be implemented by subclasses derived from the HadoopFileBased class.
%
%   Example Implementation:
%   -----------------------
%   % Mixing in Hadoop support for the datastore
%   % This example template builds on the example implementation found in
%   % matlab.io.Datastore and matlab.io.datastore.Partitionable. All three
%   % templates are meant to be used in conjunction to get a partitioned
%   % datastore that can be used in a Hadoop environment.
%   classdef MyDatastore < matlab.io.Datastore & ...
%                          matlab.io.datastore.Partitionable & ...
%                          matlab.io.datastore.HadoopFileBased
%       ...
%       ...
%       methods (Hidden)
%           function initializeDatastore(ds, info)
%               %INITIALIZEDATASTORE Initialize the datastore with necessary
%               %   split information sent from Hadoop.
%               %   initializeDatastore(DS, INFO) initializes the datastore with
%               %   necessary information sent from Hadoop.
%               %   The info struct consists of the following fields -
%               %     1) FileName,
%               %     2) Offset, and
%               %     3) Size.
%               %   The FileName field is of type char, and the fields Offset and
%               %   Size are of type double.
%
%               % This example implementation initializes the datastore based on
%               % Hadoop split information to store it as a DsFileSet object.
%               % The property FileSet is of type matlab.io.datastore.DsFileSet.
%               ds.FileSet = matlab.io.datastore.DsFileSet(info, ...
%                  'FileSplitSize',ds.FileSet.FileSplitSize);
%               reset(ds.FileSet);
%               reset(ds);
%           end
%
%           function location = getLocation(ds)
%               %GETLOCATION Return the location of the files in Hadoop.
%               %   LOCATION = getLocation(DS) returns the location of the files
%               %   in Hadoop to which this datastore points.
%               %   This LOCATION can be a -
%               %     1) list of files,
%               %     2) list of directories, or
%               %     3) object of type matlab.io.datastore.DsFileSet.
%               %   For a list of files or directories, a cell array of char vectors
%               %   is the expected datatype. This method should throw an
%               %   error if the datastore represents a file or a collection
%               %   of files that are not over complete files. 
%               %   This can occur when:
%               %   1) partitioning the datastore using DsFileSet's
%               %   partition method, and/or
%               %   2) when the FileSplitSize option of DsFileSet is 
%               %   not 'file' and when isfullfile is false.
%
%               % This example implementation returns the FileSet property
%               % of the datastore. The property FileSet is of type
%               % matlab.io.datastore.DsFileSet.
%               location = ds.FileSet;
%           end
%
%           function tf = isfullfile(ds)
%               %ISFULLFILE Return whether datastore supports full file or not.
%               %   TF = isfullfile(DS) returns a logical indicating whether or not
%               %   initializeDatastore method must get information for one complete file.
%               %   In a Hadoop environment it is typically inefficient to work over
%               %   full files. Whenever it is possible to read chunks of files
%               %   this function should return false.
%
%               % This example implementation checks if the FileSplitSize property of
%               % DsFileSet is 'file' or not. The property FileSet is a
%               % matlab.io.datastore.DsFileSet object.
%               tf = isequal(ds.FileSet.FileSplitSize, 'file');
%           end
%       end
%   end
%
%   Example usage:
%   -------------
%   % Construct a datastore with data from a Hadoop server
%   setenv('HADOOP_HOME', '/path/to/hadoop/install');
%   ds = MyDatastore('hdfs://myhadoopserver:8088/mydatafiles',2);
%   % while there is more data available in the datastore, read from the datastore
%   while hasdata(ds)
%       [data, info] = read(ds);
%   end
%
%   % Use tall arrays on Spark with parallel cluster configuration.
%   % Refer to the documentation on how to,
%   % "Use tall arrays on a Spark Enabled Hadoop Cluster".
%   t = tall(ds);
%
%   % Gather the head of the tall array
%   hd = gather(head(t));
%
%   See also tall, matlab.io.Datastore, matlab.io.datastore.Partitionable,
%   matlab.io.datastore.DsFileSet.

%   Copyright 2017 The MathWorks, Inc.

    methods (Abstract, Hidden)
        %INITIALIZEDATASTORE Initialize the datastore with necessary
        %   split information sent from Hadoop.
        %   initializeDatastore(DS, INFO) initializes the datastore with
        %   necessary information sent from Hadoop.
        %   The info struct consists of the following fields -
        %     1) FileName,
        %     2) Offset, and
        %     3) Size.
        %   The FileName field is of type char, and the fields Offset and
        %   Size are of type double.
        %
        %   This is an abstract method and must be implemented by
        %   the subclasses.
        %
        %   Here is an example using DsFileSet:
        %
        %   function initializeDatastore(ds, hadoopInfo)
        %       % The property FileSet is a matlab.io.datastore.DsFileSet object.
        %       ds.FileSet = matlab.io.datastore.DsFileSet(hadoopInfo);
        %       reset(ds.FileSet);
        %       reset(ds);
        %   end
        %
        %   See also matlab.io.Datastore, isfullfile, getLocation,
        %            matlab.io.datastore.Partitionable,
        %            matlab.io.datastore.DsFileSet.
        initializeDatastore(ds, info);

        %GETLOCATION Return the location of the files in Hadoop.
        %   LOCATION = getLocation(DS) returns the location of the files
        %   in Hadoop to which this datastore points.
        %   This LOCATION can be a -
        %     1) list of files,
        %     2) list of directories, or
        %     3) object of type matlab.io.datastore.DsFileSet.
        %   For a list of files or directories, a cell array of char vectors
        %   is the expected datatype. This method should throw an error if
        %   the datastore represents a file or a collection of files that
        %   are not over complete files. 
        %   This can occur when:
        %   1) partitioning the datastore using DsFileSet's partition method, or 
        %   2) when the FileSplitSize option of DsFileSet is not 'file' and
        %   when isfullfile is false.
        %
        %   This is an abstract method and must be implemented by
        %   the subclasses.
        %
        %   Here is an example using DsFileSet:
        %
        %   function location = getLocation(ds)
        %       % The property FileSet is a matlab.io.datastore.DsFileSet object.
        %       location = ds.FileSet;
        %   end
        %
        %   See also matlab.io.Datastore, isfullfile, initializeDatastore,
        %            matlab.io.datastore.Partitionable,
        %            matlab.io.datastore.DsFileSet.
        location = getLocation(ds);

        %ISFULLFILE Return whether datastore supports full file or not.
        %   TF = isfullfile(DS) returns a logical indicating whether or not
        %   initializeDatastore method must get information for one complete file.
        %   In a Hadoop environment it is typically inefficient to work over
        %   full files. Whenever it is possible to read chunks of files
        %   this function should return false.
        %
        %   This is an abstract method and must be implemented by
        %   the subclasses.
        %
        %   Here is an example using DsFileSet:
        %
        %   function tf = isfullfile(ds)
        %       % The property FileSet is a matlab.io.datastore.DsFileSet object.
        %       tf = isequal(ds.FileSet.FileSplitSize, 'file');
        %   end
        %
        %   See also matlab.io.Datastore, getLocation, initializeDatastore,
        %            matlab.io.datastore.Partitionable,
        %            matlab.io.datastore.DsFileSet.
        tf = isfullfile(ds);
    end
end
