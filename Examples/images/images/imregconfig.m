function [optimizer, metric] = imregconfig(str)
%imregconfig   Configurations for intensity-based registration.
%    [OPTIMIZER, METRIC] = IMREGCONFIG(CONFIGNAME) creates a metric and
%    optimizer configuration to perform a typical image registration.
%    OPTIMIZER contains settings used to configure the intensity similarity
%    optimization.  METRIC configures the image similarity metric to be
%    used during registration.
%
%    Recognized values for CONFIGNAME are 'monomodal' and 'multimodal'.
%    'monomodal' is useful for images that have the same intensity value
%    range and distribution, such as if the images came from the same
%    sensor under the same conditions.  Use 'multimodal' when the images
%    come from different sensors or have different intensity levels.
%
%    The default settings in the METRIC and OPTIMIZER output arguments will
%    provide a basic registration, the registration will likely improve if
%    the METRIC or OPTIMIZER settings are changed.  For example, increasing
%    the number of iterations used by the optimizer, reducing the optimizer
%    step size, or changing the number of samples used for stochastic
%    metrics typically improves the registration (to a point and at the
%    expense of performance).
%
%    Example
%    -------
%   % Read in two remote sensing images of the same scene taken at
%   % different times with different sensors from slightly different
%   % perspectives.
%   fixed  = imread('westconcordorthophoto.png');
%   moving = rgb2gray(imread('westconcordaerial.png'));
%
%   % View misaligned images
%   imshowpair(fixed, moving,'Scaling','joint');
%
%   % Get a configuration suitable for registering images from different
%   % sensors.
%   [optimizer, metric] = imregconfig('multimodal')
%
%   % Tune the properties of the optimizer to allow for more iterations
%   % and reduce the initial step size we will take in parameter space so
%   % that the registration will converge to a global maxima of mutual
%   % information.
%   optimizer.MaximumIterations = 300;
%   optimizer.InitialRadius = 3.5e-3;
%
%   % Align the moving image with the fixed image
%   movingRegistered = imregister(moving, fixed, 'affine', optimizer, metric);
%
%   % View registered images
%   figure
%   imshowpair(fixed, movingRegistered,'Scaling','joint');
%
%    See also imregister,
%    registrationEstimator,
%    registration.metric.MattesMutualInformation,
%    registration.metric.MeanSquares,
%    registration.optimizer.OnePlusOneEvolutionary,
%    registration.optimizer.RegularStepGradientDescent 

%   Copyright 2011 The MathWorks, Inc.

% Validate input.  Must be a string vector.
str = validatestring(str, ...
                     {'monomodal', 'multimodal'}, ...
                     mfilename, ...
                     'METRIC');

switch (str)
case 'monomodal'
    metric = registration.metric.MeanSquares;
    optimizer = registration.optimizer.RegularStepGradientDescent;
case 'multimodal'
    metric = registration.metric.MattesMutualInformation;
    optimizer = registration.optimizer.OnePlusOneEvolutionary;
otherwise
    iptassert(false, 'images:imregconfig:badMetricString', str)
end
