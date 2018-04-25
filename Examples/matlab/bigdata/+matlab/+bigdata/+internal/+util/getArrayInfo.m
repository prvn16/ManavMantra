function info = getArrayInfo(varargin)
%getArrayInfo Retrieve information about tall array.
%   S = getArrayInfo(T) returns in S a struct describing what is known and what
%   is not known about tall array T. (It is an error if T is not tall).
%
%   S = getArrayInfo(PA,ADAPTOR) in S a struct describing what is known and what
%   is not known about partitioned array PA and adaptor ADAPTOR.
%
%   The fields of S are:
%   'Class'    - the underlying type of T, or '' if not known
%   'Ndims'    - the number of dimensions of T, or NaN if not known
%   'Size'     - the underlying size of T. If 'Ndims' is NaN, this will be empty,
%                otherwise it is a vector of length Ndims. Some elements will be
%                NaN if they are not known.
%   'Gathered' - logical scalar indicating whether the value has already been
%                gathered. When 'Gathered' is TRUE, this implies that calling
%                GATHER is "free".
%   'IsPreviewAvailable' - logical scalar indicating whether 'PreviewData' is valid
%   'PreviewData' - the actual preview data
%   'IsPreviewTruncated' - whether the preview data has been truncated
%   'Error'    - if an error was encountered attempting to gather information, the
%                relevant MException is here. This error might well indicate that an
%                error would be thrown during GATHER.

% Copyright 2016-2017 The MathWorks, Inc.

narginchk(1,2);

if nargin == 1
    assert(istall(varargin{1}), 'getArrayInfo with a single input is valid only for tall arrays.');
    pa = hGetValueImpl(varargin{1});
    adaptor = hGetAdaptor(varargin{1});
else
    [pa, adaptor] = deal(varargin{:});
end

s = struct('Class', '', ...
    'Ndims', NaN, ...
    'Size', [], ...
    'Gathered', false, ...
    'IsPreviewAvailable', false, ...
    'PreviewData', [], ...
    'IsPreviewTruncated', true, ...
    'Error', MException.empty());
try
    info = iGatherInfo(s, pa, adaptor);
catch E
    info = s;
    info.Error = E;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to actually gather the information
function s = iGatherInfo(s, partitionedArray, adaptor)

s.Gathered = matlab.bigdata.internal.util.isGathered(partitionedArray);

numPreviewRows = matlab.bigdata.internal.util.defaultHeadTailRows(); % Number of rows to preview

if ~partitionedArray.IsValid
    % If the execution environment has gone away, we do not want to trigger
    % recreation of it via gather.
    s.Error = MException(message('MATLAB:bigdata:array:InvalidTall'));
elseif s.Gathered
    % The Adaptor doesn't get updated when things are gathered, but we can simply
    % query the underlying value.
    value = partitionedArray.ValueFuture.Value;
    isDataFullSize = true;
    s = iUpdateFromPreviewData(s, numPreviewRows, value, isDataFullSize, adaptor);
elseif hasCachedPreviewData(partitionedArray)
    [previewData, isTruncated] = getCachedPreviewData(partitionedArray);
    isDataFullSize = ~isTruncated;
    s = iUpdateFromPreviewData(s, numPreviewRows, previewData, isDataFullSize, adaptor);
elseif matlab.bigdata.internal.util.isPreviewCheap(partitionedArray)
    % Preview is cheap - use this to get better size information to match what the
    % object display can show
    cheapPreviewGuard = matlab.bigdata.internal.lazyeval.CheapPreviewGuard(); %#ok
    previewData = gather(matlab.bigdata.internal.lazyeval.extractHead(partitionedArray, numPreviewRows+1));
    % Under certain circumstances, the act of previewing can cause the
    % array to become gathered - in which case, we switch over to using the
    % gathered data.
    if matlab.bigdata.internal.util.isGathered(partitionedArray)
        s.Gathered = true;
        previewData = partitionedArray.ValueFuture.Value;
    end
    
    isDataFullSize = s.Gathered || size(previewData, 1) <= numPreviewRows;
    
    s = iUpdateFromPreviewData(s, numPreviewRows, previewData, isDataFullSize, adaptor);
    
    iUpdateAdaptorSizeInfoInPlace(size(previewData, 1), isDataFullSize, adaptor);
    
    if ~s.Gathered
        setCachedPreviewData(partitionedArray, s.PreviewData, s.IsPreviewTruncated);
    end
else
    s.Class = adaptor.Class;
    s.Ndims = adaptor.NDims;
    s.Size  = adaptor.Size;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [data, truncated] = iTruncate(data, szInDim1)
truncated = size(data, 1) > szInDim1;
if truncated
    data = matlab.bigdata.internal.util.indexSlices(data, 1:szInDim1);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sz1 = iDeriveSize1FromAdaptor(adaptor)
if ~isnan(adaptor.NDims)
    sz1 = adaptor.Size(1);
else
    sz1 = NaN;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = iUpdateFromPreviewData(s, numPreviewRows, previewData, isDataFullSize, adaptor)

s.IsPreviewAvailable = true;

s.Class = class(previewData);
s.Ndims = ndims(previewData);
s.Size  = size(previewData);

[s.PreviewData, s.IsPreviewTruncated] = iTruncate(previewData, numPreviewRows);

if ~isDataFullSize
    s.Size(1) = iDeriveSize1FromAdaptor(adaptor);
    % If the data is not full-size, it must be truncated.
    s.IsPreviewTruncated = true;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iUpdateAdaptorSizeInfoInPlace(previewRowsObtained, isDataFullSize, adap)
if isDataFullSize
    adap.setTallSize(previewRowsObtained);
elseif previewRowsObtained > 1
    adap.setTallSizeGtOneInPlace();
end
end
