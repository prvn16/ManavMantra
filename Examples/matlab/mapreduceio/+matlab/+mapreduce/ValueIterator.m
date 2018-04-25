classdef ValueIterator < matlab.mixin.CustomDisplay & handle
%VALUEITERATOR An iterator over intermediate values for use with mapreduce.
%   VALUEITERATOR objects are used within MAPREDUCE
%
%      OUTDS = MAPREDUCE(INDS,MAPFUN,REDUCEFUN,...)
%
%   where REDUCEFUN is a function:
% 
%      REDUCEFUN(key,valsIter,KVstore)
%
%   Within REDUCEFUN, iterate over all the intermediate values in the 
%   VALUEITERATOR valsIter using
%
%      while hasnext(valsIter)
%          val = getnext(valsIter)
%      end
%
%   ValueIterator Properties:
%     Key     -  All the values in the VALUEITERATOR are associated with
%                this Key.
%
%   ValueIterator Methods:
%     hasnext - Checks if the VALUEITERATOR has one or more values
%               available.
%     getnext - Gets the next value from the VALUEITERATOR.
%
%   See also mapreduce.

%   Copyright 2013 The MathWorks, Inc.

properties (GetAccess = public, SetAccess = private)
    % A key that this ValueIterator points to.
    Key;
end
properties (Access = private)
    % A store that provides hasNextValue() and getNextValue() methods
    KVStore;
    CacheHasNext;
end

properties (Constant, Access = private)
    AHREF_CUSTOM_DISPLAY_HASNEXT_LINK = '<a href="matlab: help(''matlab.mapreduce.ValueIterator\hasnext'')">hasnext</a>';
    AHREF_CUSTOM_DISPLAY_GETNEXT_LINK = '<a href="matlab: help(''matlab.mapreduce.ValueIterator\getnext'')">getnext</a>';
end

methods
    function obj = ValueIterator(key, kvs)
        obj.Key = key;
        obj.KVStore = kvs;
        obj.CacheHasNext = kvs.hasNextValue();
    end

    function tf = hasnext(obj)
        %HASNEXT Checks if the ValueIteraor has one or more values available.
        % tf = HASNEXT(VALITER)
        % Returns true if one or more values are available.
        % Returns false if no more values are available.
        %
        % Example:
        %    while HASNEXT(valiter)
        %        val = getnext(valiter);
        %    end 
        %
        % See also getnext, mapreduce.
        tf = obj.CacheHasNext;
    end

    function val = getnext(obj)
        %GETNEXT Gets the next value from the ValueIterator.
        % value = GETNEXT(VALITER) returns the next avilable value in VALITER.
        % Always use hasnext(VALITER) before GETNEXT(VALITER).
        %
        % Example:
        %    while hasnext(valiter)
        %        val = GETNEXT(valiter);
        %    end 
        %
        % See also hasnext, mapreduce.
        if ~obj.CacheHasNext
            error(message('MATLAB:mapreduceio:valueiterator:getNextNoMoreValues'));
        end
        val = obj.KVStore.getNextValue();
        obj.CacheHasNext = obj.KVStore.hasNextValue();
    end
end

methods (Access = protected)
    function footer = getFooter(valIter)
        valsAvailStr = getString(message(...
                'MATLAB:mapreduceio:valueiterator:valuesAvailable'));
        if ~valIter.CacheHasNext
            valsAvailStr = getString(message(...
                'MATLAB:mapreduceio:valueiterator:noMoreValues'));
        end
        hasnextStr = 'hasnext';
        getnextStr = 'getnext';
        if feature('hotlinks')
            import matlab.mapreduce.ValueIterator;
            hasnextStr = ValueIterator.AHREF_CUSTOM_DISPLAY_HASNEXT_LINK;
            getnextStr = ValueIterator.AHREF_CUSTOM_DISPLAY_GETNEXT_LINK;
        end
        useMethodStr = getString(message(...
                'MATLAB:mapreduceio:valueiterator:useMethodsCustomDisp', ...
                hasnextStr, ...
                getnextStr));
        footer = sprintf('%s\n%s\n', valsAvailStr, useMethodStr);
    end
end

end
