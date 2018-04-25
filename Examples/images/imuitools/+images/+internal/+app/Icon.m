classdef Icon < handle
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    methods (Static)
        function icon = CREATE_MASK_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'CreateMask_16px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = CREATE_MASK_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'CreateMask_24px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = FREEHAND_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'DrawFreehand_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = RECTANGLE_24
            fname = fullfile(matlabroot,'toolbox/images/icons', 'draw_rectangle_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = ELLIPSE_24
            fname = fullfile(matlabroot,'toolbox/images/icons', 'draw_ellipse_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = THRESHOLD_24
            fname = fullfile(matlabroot,'toolbox/images/icons', 'Threshold_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = FLOODFILL_24
            fname = fullfile(matlabroot,'toolbox/images/icons', 'FloodFill_Colored_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = FILTERREGIONS_24
            fname = fullfile(matlabroot,'toolbox/images/icons', 'FilterRegions_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = FILLHOLES_16
            fname = fullfile(matlabroot,'toolbox/images/icons', 'FillHoles_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = CLEARBORDER_16
            fname = fullfile(matlabroot,'toolbox/images/icons', 'ClearBorder_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GENERATE_MATLAB_SCRIPT_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GenerateMATLABScript_Icon_16px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GENERATE_MATLAB_SCRIPT_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GenerateMATLABScript_Icon_24px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = INVERT_MASK_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'InvertMask_16px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = INVERT_MASK_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'InvertMask_24px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = POLYGON_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'draw_polygon_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = ACTIVECONTOURS_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'ActiveContours_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GRAPHCUT_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GraphCut_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GRABCUT_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'LocalGraphCut_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = DRAWROI_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'DrawROI_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GRAPHCUTFOREGROUND_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GraphCutForeground_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GRAPHCUTBACKGROUND_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GraphCutBackground_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = GRAPHCUTERASE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'GraphCutErase_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = CLEARALL_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'ClearAll_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = REFINE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'Refine_24px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = MORPHOLOGY_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'Morphology_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = SHOW_BINARY_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'ShowBinary_24px.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELDISK_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELDISK_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELLINE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELLINE_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELPERIODICLINE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELPERIODICLINE_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELPAIR_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELPAIR_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELRECTANGLE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELRECTANGLE_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELSQUARE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELSQUARE_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELOCTAGON_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELOCTAGON_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELDIAMOND_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELDIAMOND_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELDISK_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELDISK_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELLINE_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELLINE_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELPERIODICLINE_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELPERIODICLINE_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELPAIR_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELPAIR_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELRECTANGLE_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELRECTANGLE_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELSQUARE_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELSQUARE_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELOCTAGON_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELOCTAGON_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = STRELDIAMOND_16
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'STRELDIAMOND_16.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = AUTOCLUSTER_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'auto_cluster_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = FINDCIRCLES_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'find_circles_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = LOADMASK_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'load_mask_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = RULER_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'ruler_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
        function icon = TEXTURE_24
            fname = fullfile(matlabroot, 'toolbox/images/icons', 'textures_24.png');
            icon = matlab.ui.internal.toolstrip.Icon(fname);
        end
    end
    
end