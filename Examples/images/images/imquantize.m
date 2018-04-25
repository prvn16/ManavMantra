function [quant_a, index] = imquantize(varargin)
%IMQUANTIZE Quantize image using specified quantization levels and output values.
%   QUANT_A = IMQUANTIZE(A, LEVELS) uses the quantization levels specified
%   in the 1xN vector LEVELS to convert image A into an output image
%   QUANT_A with N+1 discrete levels. The entries in LEVELS have to be in
%   strictly increasing order. The output image QUANT_A contains integer
%   values in the range [1 (N+1)] assigned as per the criterion below:
% 
%       If A(k) <= LEVELS(1),               then QUANT_A(k) = 1 
%       If LEVELS(m-1) < A(k) <= LEVELS(m), then QUANT_A(k) = m 
%       If A(k) >LEVELS(N),                 then QUANT_A(k) = N+1
% 
%   Note that IMQUANTIZE assigns values to the two implicitly-defined end
%   intervals, namely A(k) <= LEVELS(1) and A(k) > LEVELS(N).
%
%   QUANT_A = IMQUANTIZE(A, LEVELS, VALUES) uses entries from the vector
%   VALUES for populating the output image QUANT_A. VALUES must be of
%   length (N+1), where N = length(LEVELS). Each of the (N+1) elements
%   specify the quantization value for one of the (N+1) discrete levels in
%   QUANT_A. The entries in output image QUANT_A are assigned as per the
%   criterion below:
% 
%       If A(k) <= LEVELS(1),               then QUANT_A(k) = VALUES(1) 
%       If LEVELS(m-1) < A(k) <= LEVELS(m), then QUANT_A(k) = VALUES(m) 
%       If A(k) > LEVELS(N),                then QUANT_A(k) = VALUES(N+1)
%
%   [QUANT_A, INDEX] = IMQUANTIZE(A, LEVELS, VALUES) returns an array INDEX
%   such that QUANT_A = VALUES(INDEX).
%
%   Class Support 
%   ------------- 
%   Input A is a numeric array. LEVELS is a numeric scalar or vector.
%   VALUES is numeric vector of length(VALUES) = length(LEVELS)+1. QUANT_A
%   and INDEX are the same size as A. If VALUES is specified, then QUANT_A
%   is the same class as VALUES, otherwise QUANT_A is of class double.
%   INDEX is of class double.
%
%   Notes
%   -----
%   1. To get the output QUANT_A to be a of a certain class, set the input
%   vector VALUES to be of the same class.
%
%   Example 1
%   ---------
%   This example computes multiple thresholds for an image using
%   MULTITHRESH and applies those thresholds to the image using IMQUANTIZE
%   to get segment labels.
%  
%     I = imread('circlesBrightDark.png'); 
%     imshow(I)
%     title('Original Image');
% 
%     % Compute the thresholds
%     thresh = multithresh(I,2);
% 
%     % Apply the thresholds to obtain segmented image
%     seg_I = imquantize(I,thresh);
% 
%     % Show the various segments in the segmented image in color
%     RGB = label2rgb(seg_I);
%     figure, imshow(RGB)
%     title('Segmented Image');
%
%   Example 2
%   ---------
%   This example reduces the number of discrete levels in an image from 256
%   to 8.
%
%     I = imread('coins.png');
%     imshow(I)
% 
%     % Obtain 7 thresholds from MULTITHRESH to split the image into 8 levels
%     thresh = multithresh(I,7);
% 
%     % Reduce the number of levels using the maximum value in each interval
%     % to replace the values in I
%     valuesMax = [thresh max(I(:))];
%     [quant8_I, index] = imquantize(I, thresh, valuesMax);
% 
%     % Display the 8-level image
%     figure, imshow(quant8_I,[])
%     title('Image with 8-levels, using maximum value of the interval');
% 
%     % Use the minimum interval value instead of maximum interval value to
%     % replace the values in I
%     valuesMin = [min(I(:)) thresh];
%     quant8_I_min = valuesMin(index);
% 
%     % Display the new image
%     figure, imshow(quant8_I_min,[])
%     title('Image with 8-levels, using minimum value of the interval');
% 
%   See also LABEL2RGB, MULTITHRESH, RGB2IND.

% Copyright 2012-2014 The MathWorks, Inc. 

narginchk(2,3);

A    = varargin{1};
validateattributes(A,{'numeric'},{'nonsparse','real', 'nonnan'}, mfilename,'A',1); 

levels = varargin{2};
validateattributes(levels,{'numeric'},{'nonsparse','real','vector','nonnan','increasing'},...
    mfilename,'LEVELS',2);

if (nargin == 3)
    values = varargin{3};    
    validateattributes(values,{'numeric', 'logical'},{'nonsparse','real','vector'}, ...
        mfilename,'VALUES',3);
    
    % Check if length of 'values' is one greater than length of 'levels'
    if (length(values) ~= (length(levels) + 1))
        error(message('images:imquantize:levelValuesLengthMismatch','VALUES','LEVELS'));
    end
    
    % The elements in VALUES need not be unique.
else    
    values = [];
end


N = length(levels);

% Compute the index values
index = ones(size(A)); 
for i = 1:N
    index = index + (A > levels(i));
end

% Populate the quantized output using specified VALUES

if isempty(values) % If VALUES is not specified as input    
    quant_a = index; % Use default values
else    
    quant_a = values(index);
    if (isvector(index) && xor(isrow(index),isrow(quant_a)))
        % Special case - when index (and input image) is a vector, and
        % values is vector of different orientation.
        quant_a = quant_a.';
    end            
end

end



