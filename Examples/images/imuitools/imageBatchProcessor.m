function imageBatchProcessor(varargin)
%imageBatchProcessor Process a folder of images.
%   imageBatchProcessor opens an image batch processing app. This app can
%   be used to process an input folder of images using a function. This
%   function should have the following signature:
%          RESULTS = FCN(IN)
%   Where IN is the image data and RESULTS is a scalar structure containing
%   the results of the processing.
%
%   imageBatchProcessor CLOSE closes all open image batch processing apps.
%
%   See also imread, imwrite.

% Copyright 2014-2015 The MathWorks, Inc.

narginchk(0,1)
if (nargin == 0)
    iptui.internal.batchProcessor.BatchProcessorGUI();
    
elseif(nargin == 1)
    validatestring(varargin{1}, {'close'}, mfilename);
    imageslib.internal.apputil.manageToolInstances('deleteAll',...
        'imageBatchProcessor');
end
