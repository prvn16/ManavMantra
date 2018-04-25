function array = broadcast(array)
%broadcast Broadcasts an array, making it available in its entirety to all calls to a function handle.
%
% broadcastArray = broadcast(array) will return an object that when
% passed as an input argument to any method of the PartitionedArray
% interface, the underlying array will be passed in its entirety to all
% function calls made during the evaluation of the operation. This is
% intended for when the input is metadata, for example input flags or
% lookup tables.
%
% Example:
%  import matlab.bigdata.internal.broadcast;
%  import matlab.bigdata.internal.lazyeval.LazyPartitionedArray;
%
%  % tX is a PartitionedArray of size 1000x3
%  tX = LazyPartitionedArray.createFromConstant(rand(1000,3));
%
%  % A matrix operation that permutes the columns 1->2->3->1.
%  matrixOperation = [0,1,0;0,0,1;1,0,0];
%
%  % tY will be equivalent to circshift(tX, -1, 2)
%  tY = slicefun(@mtimes,tX,broadcast(matrixOperation));
%

% Copyright 2016 The MathWorks, Inc.

if ~isa(array, 'matlab.bigdata.internal.BroadcastArray')
    array = matlab.bigdata.internal.BroadcastArray(array);
end
