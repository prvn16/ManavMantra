%CAMERATOOLBAR  Interactively manipulate camera.
%   CAMERATOOLBAR creates a new toolbar that enables interactive
%   manipulation of a scene's camera and light by dragging the
%   mouse on the figure window; the camera properties of the
%   current axes (gca) are affected. Several camera properties
%   are set when the toolbar is initialized.
%
%   CAMERATOOLBAR('NoReset') creates the toolbar without setting
%   any camera properties.
%
%   CAMERATOOLBAR('SetMode' mode) sets the mode of the
%   toolbar. Mode can be: 'orbit', 'orbitscenelight', 'pan',
%   'dollyhv', 'dollyfb', 'zoom', 'roll', 'nomode'.
%
%   CAMERATOOLBAR('SetCoordSys' coordsys) sets the principal axis
%   of the camera motion. coordsys can be: 'x', 'y', 'z', 'none'.
%
%   CAMERATOOLBAR('Show') shows the toolbar.
%   CAMERATOOLBAR('Hide') hides the toolbar.
%   CAMERATOOLBAR('Toggle') toggles the visibility of the toolbar.
%
%   CAMERATOOLBAR('ResetCameraAndSceneLight') resets the current
%   camera and scenelight.
%   CAMERATOOLBAR('ResetCamera') resets the current camera.
%   CAMERATOOLBAR('ResetSceneLight') resets the current scenelight.
%   CAMERATOOLBAR('ResetTarget') resets the current camera target.
%
%   MODE = CAMERATOOLBAR('GetMode') returns the current mode.
%   PAXIS = CAMERATOOLBAR('GetCoordSys') returns the current
%   principal axis.
%   VIS = CAMERATOOLBAR('GetVisible') returns the visibility.
%   H = CAMERATOOLBAR returns the handle to the toolbar.
%
%   CAMERATOOLBAR('Close') removes the toolbar.
%
%   CAMERATOOLBAR(FIG,...) specify figure handle as first argument.
%
%   Note: Rendering performance is affected by presence of OpenGL
%   hardware.
%
%   See also ROTATE3D, ZOOM, PAN.

%   Copyright 2011 The MathWorks, Inc.
