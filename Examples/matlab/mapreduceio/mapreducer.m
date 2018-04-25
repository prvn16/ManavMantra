function output = mapreducer(varargin)
%MAPREDUCER Define execution environment for mapreduce or tall arrays.
%   MAPREDUCER sets the global execution environment for mapreduce and tall
%   array calculations to be the default. This will either be the local
%   MATLAB session, or a parallel pool if Parallel Computing Toolbox is
%   available and a parallel pool is available.
%
%   MAPREDUCER(0) sets the global execution environment to be the local
%   MATLAB session.
%
%   MAPREDUCER(pool) sets the global execution environment to be the given
%   parallel pool from Parallel Computing Toolbox. Currently only the local
%   scheduler is supported.
%
%   MAPREDUCER(cluster) sets the global execution environment to be the
%   given cluster, where cluster is an instance of parallel.cluster.Hadoop
%   from Parallel Computing Toolbox.
%
%   mr = MAPREDUCER(..) returns the MapReducer object that represents the
%   set global execution environment.
%
%   mr = MAPREDUCER(.., 'ObjectVisibility', 'Off') returns a MapReducer
%   object without setting the global execution environment.
%
%   MAPREDUCER(mr) sets the global execution environment to be mr if the
%   'ObjectVisibility' property of mr is set to 'On'.
%
%   NOTE: Tall arrays are bound to an execution environment when they are
%   created using TALL. If you subsequently change the global execution
%   environment, then the tall array becomes invalid.
%
%   Examples: 
%   % Set the execution environment to be the default:
%   mapreducer();
%
%   % Set the execution environment to be the local session of MATLAB:
%   mapreducer(0);
%
%   % Set the execution environment to be the given Parallel Computing
%   Toolbox pool: 
%   mapreducer(parpool);
%
%   % Set the execution environment to be the given HADOOP cluster using
%   Parallel Computing Toolbox: 
%   cluster = parallel.cluster.Hadoop('HadoopInstallFolder', '/hadoop/path');
%   mapreducer(cluster);
%
%   % Set the execution environment to be the given HADOOP cluster from
%   within MATLAB Compiler compiled code in application mode: 
%   mr = matlab.mapreduce.DeployHadoopMapReducer; 
%   mapreducer(mr);
%
%   % Create a MapReducer object that represents the local MATLAB session
%   without modifying the  global execution environment:
%   mr = mapreducer(0, 'ObjectVisibility', 'Off');
%
%   See also MAPREDUCE, TALL, GCMR.

%   Copyright 2014-2017 The MathWorks, Inc.

import matlab.mapreduce.internal.MapReducerManager;

if nargin > 0
    [varargin{:}] = convertStringsToChars(varargin{:});
end

try
    options = iParseInput(varargin{:});
    if options.IsDefault
        obj = iCreateDefaultMapreducer();
        obj.ObjectVisibility = options.ObjectVisibility;
        
    elseif isa(options.Input, 'matlab.mapreduce.MapReducer')
        obj = options.Input;
        
    elseif isnumeric(options.Input) && isequal(options.Input, 0)
        obj = matlab.mapreduce.SerialMapReducer;
        obj.ObjectVisibility = options.ObjectVisibility;
        
    elseif isa(options.Input, 'parallel.Pool')
        obj = matlab.mapreduce.ParallelMapReducer(options.Input);
        obj.ObjectVisibility = options.ObjectVisibility;
        
    elseif isa(options.Input, 'parallel.cluster.Hadoop')
        obj = matlab.mapreduce.ParallelHadoopMapReducer(options.Input);
        obj.ObjectVisibility = options.ObjectVisibility;
        
    else
        error(message('MATLAB:mapreduceio:mapreducer:InvalidMapReducer'));
    end
catch err
    throw(err);
end

mapReducerManager = MapReducerManager.getCurrentManager();
mapReducerManager.setAsFrontOfStack(obj);

% If there is now a current MapReducer, we invalidate the cache of the
% default MapReducer so that any underlying resources are released.
if strcmp(options.ObjectVisibility, 'Yes')
    mapReducerManager.invalidateDefaultCache();
end

if nargout
    output = obj;
end

% Parse the various input arguments to obtain the input and object
% visibility property.
function options = iParseInput(varargin)

p = inputParser;
if nargin && ischar(varargin{1}) && ~isequal(varargin{1}, 'ObjectVisibility')
    p.addRequired('Input');
    p.KeepUnmatched = true;
else
    p.addOptional('Input', []);
end
p.addParameter('ObjectVisibility', 'On');
p.parse(varargin{:});

options = p.Results;

options.ObjectVisibility = validatestring(options.ObjectVisibility, {'On', 'Off'}, 'mapreducer', 'ObjectVisibility');
options.IsDefault = any(nargin == [0, 2]);

otherNames = fieldnames(p.Unmatched);
otherValues = struct2cell(p.Unmatched);
options.Other = reshape([otherNames';otherValues'], 1, []);

% Create the default mapreducer depending on whether PCT is available and a
% SPMD-enabled pool is available or can be opened.
function obj = iCreateDefaultMapreducer()
import matlab.mapreduce.internal.MapReducerManager;

% If possible, in order to preserve tall array caches, we want to return
% the existing internally cached default MapReducer. As this will soon be
% returned to the user, it is no longer suitable as the internal default
% and so we must invalidate the default cache.
mapReducerManager = MapReducerManager.getCurrentManager();
obj = mapReducerManager.getOrCreateDefault();
mapReducerManager.invalidateDefaultCache();
