%TaggedArray
% An array that has been tagged in some way. Use this to check if inputs
% have been tagged in some way.
%
% Example:
%   function tOut = getUnderlyingClass(tIn)
%   opts = matlab.bigdata.internal.PartitionedArrayOptions(...
%         'PassTaggedInputs', true);
%   out = chunkfun(opts, @getUnderlyingClassImpl, in);
%   out = out(1);
%   end
%   function getUnderlyingClassImpl(in)
%   if matlab.bigdata.internal.TaggedArray.isTagged(in)
%      % Deal with the tagged inputs we care about here.
%      if matlab.bigdata.internal.UnknownEmptyArray.isUnknown(in) && ~hasType(in)
%         out = cell(0, 1);
%         return;
%      end
%      % Otherwise just remove the tag and continue as normal.
%      in = getUnderlying(in);
%   end
%   out = {class(in)};
%   end

%   Copyright 2017 The MathWorks, Inc.

classdef (Abstract) TaggedArray
    methods (Abstract)
        % Get the array underlying this tagged array object.
        array = getUnderlying(obj);
    end
    
    methods (Static)
        function tf = isTagged(obj)
            tf = isa(obj, 'matlab.bigdata.internal.TaggedArray');
        end
    end
end
