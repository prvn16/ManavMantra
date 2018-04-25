function outds = mapreduce(ds, mapfun, reducefun, varargin)
%MAPREDUCE Solve out-of-memory problems with the MapReduce framework.
%   OUTDS = MAPREDUCE(INDS,MAPFUN,REDUCEFUN) applies the map and reduce
%   functions, MAPFUN and REDUCEFUN, to the data provided by the input
%   datastore, INDS.
%   OUTDS is a KeyValueDatastore containing the output key-value pairs.
%   The OUTDS files are in the current working directory.
%
%   OUTDS = MAPREDUCE(INDS,MAPFUN,REDUCEFUN,MR) specifies the execution
%   environment for mapreduce with the mapreducer MR. This is most
%   likely used with one of the following products:
%      Parallel Computing Toolbox
%      MATLAB Distributed Computing Server
%      MATLAB Compiler
%
%   OUTDS = MAPREDUCE(__, 'Name1',Value1, 'Name2',Value2, ...) specifies
%   optional name-value pairs:
%
%     'Display'      -  'on' (default) | 'off'. Display the progress of the
%                       map and reduce phases.
%     'OutputType'   -  'TabularText' - OUTDS is a TabularTextDatastore
%                       'Binary' - OUTDS is a KeyValueDatastore (default)
%     'OutputFolder' -  The folder to store the files in OUTDS.
%                       This name-value pair is required for Hadoop.
%
%   The map function must be as follows:
%   MAPFUN(data,info,intermKVstore)
%     MAPFUN must accept the outputs of READ on the input datastore INDS:
%        [data,info] = read(INDS)
%     MAPFUN uses ADD or ADDMULTI to put one or more intermediate key-value
%     pairs into the KeyValueStore intermKVstore.
%        add(intermKVstore,key,val)
%        addmulti(intermKVstore,{key1;key2},{val1;val2})
%
%   The reduce function must be as follows:
%   REDUCEFUN(intermKey,intermValIter,outKVstore)
%     REDUCEFUN must accept a single intermediate key intermKey, and a
%     ValueIterator object intermValIter, which you use to iterate over all
%     of the intermediate values associated with intermKey:
%        while hasnext(intermValIter)
%           val = getnext(intermValIter)
%        end
%     REDUCEFUN uses ADD or ADDMULTI to put one or more output key-value
%     pairs into the KeyValueStore outKVstore.
%     MAPREDUCE takes the output key-value pairs from outKVstore and
%     returns them in the output datastore OUTDS.
%
%   Example:
%
%   function MeanDistMapReduce()
%
%   % Create a TabularTextDatastore against a tabular text file
%   % that might not fit in memory
%   tds = datastore('airlinesmall.csv', 'TreatAsMissing','NA')
%   % There are 29 columns in the file, select the 'Distance' variable
%   tds.SelectedVariableNames = 'Distance'
%   % Use mapreduce to find the mean of the Distance data
%   outds = mapreduce(tds, @MeanDistMapFun, @MeanDistReduceFun);
%   % Read a table with Key and Value variables, only 1 row
%   outtab = readall(outds)
%   % Extract the mean distance from the table
%   meandist = outtab.Value{1}
%
%       function MeanDistMapFun(data, info, intermKVStore)
%           % data is a table with 'Distance' variable
%           % data.Distance = [447;447;447;  ...  ;553;553;553;553]
%           distances = data.Distance(~isnan(data.Distance));
%           sumLenKey = 'sumAndLength';
%           sumLenValue = [sum(distances), length(distances)];
%           add(intermKVStore, sumLenKey, sumLenValue);
%       end
%
%       function MeanDistReduceFun(sumLenKey, sumLenIter, outKVStore)
%           sumLen = [0, 0];
%           while hasnext(sumLenIter)
%               sumLen = sumLen + getnext(sumLenIter);
%           end
%           add(outKVStore, 'Mean', sumLen(1)/sumLen(2));
%       end
%   end
%
%   See also datastore, matlab.mapreduce.KeyValueStore,
%                       matlab.mapreduce.ValueIterator, mapreducer, pwd.

%   Copyright 2013-2017 The MathWorks, Inc.

% Currently there are
%   - 3 required positional arguments: ds, mapfun, reducefun
%   - 1 optional positional argument: mapreducer
%   - 3 Name-Value pairs: OutputFolder, OutputType, Display
% Validate nargin before calling gcmr
narginchk(3,10);

mrcer = [];
if numel(varargin) > 0 && isa(varargin{1}, 'matlab.mapreduce.MapReducer')
    mrcer = varargin{1};
    varargin = varargin(2:end);
end

% Validate the arguments before calling gcmr
try
    parsedStruct = validateArgs(varargin);
catch e
    throw(e)
end

if isempty(mrcer)
    try
        mrcer = getOrCreateDefault(matlab.mapreduce.internal.MapReducerManager.getCurrentManager());
    catch
        mrcer = mapreducer(0, 'ObjectVisibility', 'Off');
    end
end

if matlab.io.datastore.internal.shim.isV2ApiDatastore(ds)
    % Wrap custom datastores in a decorator that will insert the
    % right checks for the datastore contract.
    ds = matlab.io.datastore.internal.FrameworkDatastore(ds);
end

try
    outds = execMapReduce(mrcer, ds, mapfun, reducefun, parsedStruct);
catch e
    throw(e)
end

    function parsedStruct = validateArgs(args)
        % Check if the arguments passed are as expected by mapreduce
        if ~matlab.io.datastore.internal.shim.isDatastore(ds)
            error(message('MATLAB:mapreduceio:mapreduce:invalidDatastore'));
        end
        if ~isa(mapfun, 'function_handle')
            error(message('MATLAB:mapreduceio:mapreduce:invalidMapHandle'));
        end
        if ~isa(reducefun, 'function_handle')
            error(message('MATLAB:mapreduceio:mapreduce:invalidReduceHandle'));
        end
        mapNargin = nargin(mapfun);
        reduceNargin = nargin(reducefun);
        if mapNargin > -1 && mapNargin < 3
            error(message('MATLAB:mapreduceio:mapreduce:invalidMapNargin'));
        end
        if reduceNargin > -1 && reduceNargin < 3
            error(message('MATLAB:mapreduceio:mapreduce:invalidRedNargin'));
        end
        persistent p;
        if isempty(p)
            p = inputParser;
            addParameter(p, 'OutputFolder', []);
            addParameter(p, 'OutputType', 'Binary');
            addParameter(p, 'Display', 'On');
            p.FunctionName = 'mapreduce';
        end
        p.parse(args{:});
        parsedStruct = p.Results;
        parsedStruct.OutputType = validatestring(parsedStruct.OutputType, ...
            {'Binary', 'TabularText'},'mapreduce','OutputType');
        parsedStruct.Display = validatestring(parsedStruct.Display, ...
            {'On', 'Off'},'mapreduce','Display');
        if isstring(parsedStruct.OutputFolder)
            parsedStruct.OutputFolder = convertStringsToChars(parsedStruct.OutputFolder);
        end
    end

end
