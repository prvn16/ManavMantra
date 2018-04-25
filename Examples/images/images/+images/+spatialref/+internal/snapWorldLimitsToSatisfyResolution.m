function R_out = snapWorldLimitsToSatisfyResolution(idealWorldLimits,outputResolution)
%   FOR INTERNAL USE ONLY -- This function is intentionally
%   undocumented and is intended for use only within other toolbox
%   classes and functions. Its behavior may change, or the feature
%   itself may be removed in a future release.
%
%   R_out = snapWorldLimitsToSatisfyResolution(R_in,outputResX,outputResY) takes a spatial
%   referencing object Rin and the desired outputResolution defined by the scalars
%   outputResX and outputResY. R_out is an adjusted version of R_in which
%   the world limits of R_in are adjusted to achieve the specified
%   resolution.
%
%   R_out = snapWorldLimitsToSatisfyResolution(R_in,outputResX,outputResY,outputResZ) takes a spatial
%   referencing object Rin and the desired outputResolution defined by the scalars
%   outputResX, outputResY, and outputResZ. R_out is an adjusted version of R_in which
%   the world limits of R_in are adjusted to achieve the specified
%   resolution.

% Copyright 2013-2014 The MathWorks, Inc.
%#codegen

coder.inline('always');
coder.internal.prefer_const(idealWorldLimits,outputResolution);

is2DProblem = numel(outputResolution) == 2;
if  is2DProblem
    
    idealWorldLimitsX = idealWorldLimits(1,:);
    idealWorldLimitsY = idealWorldLimits(2,:);
    outputResolutionX = outputResolution(1);
    outputResolutionY = outputResolution(2);
    
    % Use ceil to provide grid that will accomodate world limits at roughly the
    % target resolution.
    numCols = ceil(diff(idealWorldLimitsX) / outputResolutionX);
    numRows = ceil(diff(idealWorldLimitsY) / outputResolutionY);
    
    % If the world limits divided by the output resolution are not
    % integrally valued, we adjust the world limits such that we exactly
    % honor the target output resolution. We adjust all four corners such
    % that the center of the image remains fixed in world coordinates.
    xNudge = (numCols*outputResolutionX-diff(idealWorldLimitsX))/2;
    yNudge = (numRows*outputResolutionY-diff(idealWorldLimitsY))/2;
    XWorldLimitsOut = idealWorldLimitsX + [-xNudge xNudge];
    YWorldLimitsOut = idealWorldLimitsY + [-yNudge yNudge];
    
    % Construct output referencing object with desired outputImageSize and
    % world limits.
    outputImageSize = [numRows numCols];
    R_out = imref2d(outputImageSize,XWorldLimitsOut,YWorldLimitsOut);

else
    
    idealWorldLimitsX = idealWorldLimits(1,:);
    idealWorldLimitsY = idealWorldLimits(2,:);
    idealWorldLimitsZ = idealWorldLimits(3,:);
    outputResolutionX = outputResolution(1);
    outputResolutionY = outputResolution(2);
    outputResolutionZ = outputResolution(3);
    
    % Use ceil to provide grid that will accomodate world limits at roughly the
    % target resolution.
    numCols   = ceil(diff(idealWorldLimitsX) / outputResolutionX);
    numRows   = ceil(diff(idealWorldLimitsY) / outputResolutionY);
    numPlanes = ceil(diff(idealWorldLimitsZ) / outputResolutionZ);
    
    % If the world limits divided by the output resolution are not
    % integrally valued, we adjust the world limits such that we exactly
    % honor the target output resolution. We adjust all four corners such
    % that the center of the image remains fixed in world coordinates.
    xNudge = (numCols*outputResolutionX-diff(idealWorldLimitsX))/2;
    yNudge = (numRows*outputResolutionY-diff(idealWorldLimitsY))/2;
    zNudge = (numPlanes*outputResolutionZ-diff(idealWorldLimitsZ))/2;

    XWorldLimitsOut = idealWorldLimitsX + [-xNudge xNudge];
    YWorldLimitsOut = idealWorldLimitsY + [-yNudge yNudge];
    ZWorldLimitsOut = idealWorldLimitsZ + [-zNudge zNudge];

    % Construct output referencing object with desired outputImageSize and
    % world limits.
    outputImageSize = [numRows numCols numPlanes];
    R_out = imref3d(outputImageSize,XWorldLimitsOut,YWorldLimitsOut,ZWorldLimitsOut);
      
end



