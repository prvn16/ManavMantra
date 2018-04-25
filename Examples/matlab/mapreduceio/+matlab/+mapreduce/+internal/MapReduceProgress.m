classdef MapReduceProgress < handle
    properties (Hidden)
        PrintHeader;
        PrintZero;
        Progress;
        NProgress;
        PrintMapHundred;
        PrintHundred;
        Total;
    end

    properties (Access=private)
        PercInterval;
        Header;
        MapPerc;
        ReducePerc;
        DisplayOn;
        LastDisplayTime;
    end

    properties (Constant, Access=private)
        DISPLAY_TIME_INTERVAL = 1;
        DISPLAY_PERC_INTERVAL = 10;
        HUNDRED_PERC = 100;
        ZERO_PERC = sprintf('%3d', 0);
    end

    methods (Access=public, Hidden)
        function pp = MapReduceProgress(displayOn, percInterval)
            narginchk(1,2);
            pp.PercInterval = matlab.mapreduce.internal.MapReduceProgress.DISPLAY_PERC_INTERVAL;
            if nargin > 1
                pp.PercInterval = percInterval;
            end
            pp.DisplayOn = displayOn;
            pp.MapPerc = pp.PercInterval;
            pp.ReducePerc = pp.PercInterval;
            pp.LastDisplayTime = tic;
            if displayOn
                pp.PrintHeader = @iPrintHeader;
                pp.Progress = @(mpercnow, rpercnow)iProgress(pp, mpercnow, rpercnow);
                pp.PrintZero = @iPrintZero;
                pp.PrintMapHundred = @iPrintMapHundred;
                pp.PrintHundred = @iPrintHundred;
            else
                pp.PrintHeader = @()[];
                pp.Progress = @(~)[];
                pp.PrintZero = @()[];
                pp.PrintMapHundred = @()[];
                pp.PrintHundred = @()[];
            end
        end

        function setMapProgress(pp, mperc)
            if pp.DisplayOn
                pp.Progress = @(rpercnow)iProgress(pp, mperc, rpercnow);
            end
        end

        function setReduceProgress(pp, rperc)
            if pp.DisplayOn
                pp.Progress = @(mpercnow)iProgress(pp, mpercnow, rperc);
            end
        end
    end
end
function iPrintHeader()
headerStr = getString(message('MATLAB:mapreduceio:mapreduce:displayHeader'));
stHdrSpacing = '*      ';
edHdrSpacing = '      *';
asteriskLen = numel(headerStr) + numel(stHdrSpacing) + numel(stHdrSpacing);
asteriskRep = repmat('*', 1, asteriskLen);
disp('');
disp(asteriskRep);
disp([stHdrSpacing, headerStr, edHdrSpacing]);
disp(asteriskRep);
disp('');
end

% function iHeartBeatProgress(pp, mpercnow, rpercnow)
% import matlab.mapreduce.internal.MapReduceProgress;
% isComplete = mpercnow >= MapReduceProgress.HUNDRED_PERC && rpercnow >= MapReduceProgress.HUNDRED_PERC;
% if (isComplete || toc(pp.LastDisplayTime) < MapReduceProgress.DISPLAY_TIME_INTERVAL)
%     return;
% end
% pp.LastDisplayTime = tic;
% mpercnow = sprintf('%3d', floor(mpercnow));
% rpercnow = sprintf('%3d', floor(rpercnow));
% disp(getString(message('MATLAB:mapreduceio:mapreduce:displayPhase', mpercnow, rpercnow)));
% end

function iProgress(pp, mpercnow, rpercnow)
import matlab.mapreduce.internal.MapReduceProgress;
noMapThreshold = mpercnow < pp.MapPerc && mpercnow ~= MapReduceProgress.HUNDRED_PERC;
noReduceThreshold =  rpercnow < pp.ReducePerc && mpercnow == MapReduceProgress.HUNDRED_PERC;
if ( noMapThreshold || rpercnow == MapReduceProgress.HUNDRED_PERC || noReduceThreshold)
    return;
end
mpercnow = floor(mpercnow);
rpercnow = floor(rpercnow);
disp(getString(message('MATLAB:mapreduceio:mapreduce:displayPhase', sprintf('%3d', mpercnow), sprintf('%3d', rpercnow))));
pp.MapPerc = mpercnow + pp.PercInterval;
pp.ReducePerc = rpercnow + pp.PercInterval;
end

function iPrintZero()
import matlab.mapreduce.internal.MapReduceProgress;
disp(getString(message('MATLAB:mapreduceio:mapreduce:displayPhase', ...
    MapReduceProgress.ZERO_PERC, MapReduceProgress.ZERO_PERC)));
end

function iPrintMapHundred()
import matlab.mapreduce.internal.MapReduceProgress;
disp(getString(message('MATLAB:mapreduceio:mapreduce:displayPhase', ...
    MapReduceProgress.HUNDRED_PERC, MapReduceProgress.ZERO_PERC)));
end

function iPrintHundred()
import matlab.mapreduce.internal.MapReduceProgress;
disp(getString(message('MATLAB:mapreduceio:mapreduce:displayPhase', ...
    MapReduceProgress.HUNDRED_PERC, MapReduceProgress.HUNDRED_PERC)));
end
