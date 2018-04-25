%% Compute Maximum Average HSV of Images with MapReduce
% This example shows how to use |ImageDatastore| and |mapreduce| to find
% images with maximum hue, saturation and brightness values in an image
% collection.

% Copyright 1984-2015 The MathWorks, Inc.

%% Prepare Data
% Create a datastore using the images in |toolbox/matlab/demos| and
% |toolbox/matlab/imagesci|. The selected images have the extensions
% |.jpg|, |.tif| and |.png|.
demoFolder = fullfile(matlabroot, 'toolbox', 'matlab', 'demos');
imsciFolder = fullfile(matlabroot, 'toolbox', 'matlab', 'imagesci');

%%
% Create an |ImageDatastore| using the folder paths, and filter which images
% are included in the datastore using the |FileExtensions| Name-Value pair.
ds = imageDatastore({demoFolder, imsciFolder}, ...
    'FileExtensions', {'.jpg', '.tif', '.png'})

%% Find Average Maximum HSV from All Images
% One way to find the maximum average hue, saturation, and brightness
% values in the collection of images is to use |readimage| within a
% for-loop, processing the images one at a time. For an example of this
% method, see <http://www.mathworks.com/help/matlab/import_export/read-and-analyze-image-files.html Read and Analyze Image Files>.
%
% This example uses |mapreduce| to accomplish the same task, however, the
% |mapreduce| method is highly scalable to larger collections of images.
% While the for-loop method is reasonable for small collections of images,
% it does not scale well to a large collection of images.

%% Scale to MapReduce
% * The |mapreduce| function requires a map function and a reduce function
%   as inputs.
% * The map function receives chunks of data and outputs intermediate
%   results.
% * The reduce function reads the intermediate results and produces a final
%   result.

%% Map function
% * In this example, the map function stores the image data and the average
%   HSV values as intermediate values.
% * The intermediate values are associated with 3 keys, |'Average Hue'|,
%   |'Average Saturation'| and |'Average Brightness'|.
%
% <include>hueSaturationValueMapper.m</include>
%

%% Reduce function
% * The reduce function receives a list of the image file names along with
%   the respective average HSV values and finds the overall maximum values
%   of average hue, saturation and brightness values.
% * |mapreduce| only calls this reduce function 3 times, since the map
%   function only adds three unique keys.
% * The reducefunction uses |add| to add a final key-value pair to the
%   output. For example, |'Maximum Average Hue'| is the key and the
%   respective file name is the value.
%
% <include>hueSaturationValueReducer.m</include>
%

%% Run MapReduce
% Use |mapreduce| to apply the map and reduce functions to the datastore,
% |ds|.
maxHSV = mapreduce(ds, @hueSaturationValueMapper, @hueSaturationValueReducer);

%%
% |mapreduce| returns a datastore, |maxHSV|, with files in the
% current folder.

%%
% Read and display the final result from the output datastore, |maxHSV|.
% Use |find| and |strcmp| to find the file index from the |Files| property.
tbl = readall(maxHSV);
for i = 1:height(tbl)
    figure;
    idx = find(strcmp(ds.Files, tbl.Value{i}));
    imshow(readimage(ds, idx), 'InitialMagnification', 'fit');
    title(tbl.Key{i});
end
