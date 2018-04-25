function times = bench(count)
%BENCH  MATLAB Benchmark
%   BENCH times six different MATLAB tasks and compares the execution
%   speed with the speed of several other computers.  The six tasks are:
%
%    LU       LAPACK.                            Floating point, regular memory access.
%    FFT      Fast Fourier Transform.            Floating point, irregular memory access.
%    ODE      Ordinary diff. eqn.                Data structures and functions.
%    Sparse   Solve sparse system.               Sparse linear algebra.
%    2-D      2-D Lissajous plot.                Animating line plot.
%    3-D      3-D SURF(PEAKS)and HGTransform.    3-D surface animation.
%
%   A final bar chart shows speed, which is inversely proportional to
%   time.  Here, longer bars are faster machines, shorter bars are slower.
%
%   BENCH runs each of the six tasks once.
%   BENCH(N) runs each of the six tasks N times.
%   BENCH(0) just displays the results from other machines.
%   T = BENCH(N) returns an N-by-6 array with the execution times.
%
%   The comparison data for other computers is stored in a text file:
%     fullfile(matlabroot, 'toolbox','matlab','general','bench.dat')
%   Updated versions of this file are available from <a href="matlab:web('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=1836&objectType=file#','-browser')">MATLAB Central</a>
%   Note the link above opens your system web browser as defined by WEB.
%
%   Fluctuations of five or 10 percent in the measured times of repeated
%   runs on a single machine are not uncommon.  Your own mileage may vary.
%
%   This benchmark is intended to compare performance of one particular
%   version of MATLAB on different machines.  It does not offer direct
%   comparisons between different versions of MATLAB.  The tasks and
%   problem sizes change from version to version.
%
%   The 2-D and 3-D tasks measure graphics performance, including software
%   or hardware support for OpenGL.  The command
%      opengl info
%   describes the OpenGL support available on a particular machine.

%   Copyright 1984-2015 The MathWorks, Inc.

if nargin < 1, count = 1; end;
times = zeros(count,6);
fig1 = figure;
set(fig1,'pos','default','menubar','none','numbertitle','off', ...
    'name',getString(message('MATLAB:bench:MATLABBenchmark')));
hax1 = axes('pos',[0 0 1 1],'parent',fig1);
axis(hax1,'off');
text(.5,.6,getString(message('MATLAB:bench:MATLABBenchmark')),'parent',hax1,'horizontalalignment','center','fontsize',18)
task = text(.50,.42,'','parent',hax1,'horizontalalignment','center','fontsize',18);
drawnow
pause(1);

% Use a private stream to avoid resetting the global stream
stream = RandStream('mt19937ar');

problemsize = zeros(1, 4);

bench_lu(stream);
bench_fft(stream);
bench_ode;
bench_sparse;
bench_2d('Off');
bench_3d(false);    

for k = 1:count
    
    % LU, n = 2400.
    set(task,'string',getString(message('MATLAB:bench:LU')))
    drawnow
    [times(k,1), problemsize(1)] = bench_lu(stream);
    
    % FFT, n = 2^21.    
    set(task,'string',getString(message('MATLAB:bench:FFT')))
    drawnow
    [times(k,2), problemsize(2)] = bench_fft(stream);
    
    % ODE. van der Pol equation, mu = 1
    set(task,'string',getString(message('MATLAB:bench:ODE')))
    drawnow
    [times(k,3), problemsize(3)] = bench_ode;
    
    % Sparse linear equations
    set(task,'string',getString(message('MATLAB:bench:Sparse')))
    drawnow
    [times(k,4), problemsize(4)] = bench_sparse;
    
    % 2-D graphics
    set(task,'string',getString(message('MATLAB:bench:twoD')))
    drawnow
    pause(1)
    times(k,5) = bench_2d('On');
 
    % 3-D graphics. Vibrating logo.
    set(task,'string',getString(message('MATLAB:bench:threeD')))
    drawnow
    pause(1)
    times(k,6) = bench_3d(true);    
    
end  % loop on k

% Compare with other machines.  Get latest data file, bench.dat, from
% MATLAB Central at the URL given in the help at the beginning of bench.m

if exist('bench.dat','file') ~= 2
    warning(message('MATLAB:bench:noDataFileFound'))
    return
end
fp = fopen('bench.dat', 'rt');

% Skip over headings in first six lines.
for k = 1:6
    fgetl(fp);
end

% Read the comparison data

specs = {};
T = [];
details = {};
g = fgetl(fp);
m = 0;
desclength = 61;
while length(g) > 1
    m = m+1;
    specs{m} = g(1:desclength); %#ok<AGROW>
    T(m,:) = sscanf(g((desclength+1):end),'%f')'; %#ok<AGROW>
    details{m} = fgetl(fp); %#ok<AGROW>
    g = fgetl(fp);
end

% Close the data file
fclose(fp);

% Determine the best 10 runs (if user asked for at least 10 runs)
if count > 10
    warning(message('MATLAB:bench:display10BestTrials', count));
    totaltimes = 100./sum(times, 2);
    [~, timeOrder] = sort(totaltimes, 'descend'); 
    selected = timeOrder(1:10);
else
    selected = 1:count;
end

meanValues = mean(T, 1);

% Add the current machine and sort
T = [T; times(selected, :)];
this = [zeros(m,1); ones(length(selected),1)];
if count==1
    % if a single BENCH run
    specs(m+1) = {getString(message('MATLAB:bench:ThisMachine', repmat(' ', 1, desclength-12)))};
    details{m+1} = getString(message('MATLAB:bench:YourMachine', version));
else
    for k = m+1:size(T, 1)
        ind = k-m; % this varies 1:length(selected)
        sel = num2str(selected(ind));
        specs(k) = {getString(message('MATLAB:bench:ThisMachineRunN', sel, repmat(' ', 1, desclength-18-length(sel))))}; %#ok<AGROW>
        details{k} = getString(message('MATLAB:bench:YourMachineRunN', version, sel));         %#ok<AGROW>
    end
end
scores = mean(bsxfun(@rdivide, T, meanValues), 2);
m = size(T, 1);

% Normalize by the sum of meanValues to bring the results in line with
% earlier implementation 
speeds = (100/sum(meanValues))./(scores);
[speeds,k] = sort(speeds);
specs = specs(k);
details = details(k);
T = T(k,:);
this = this(k);

% Horizontal bar chart. Highlight this machine with another color.

clf(fig1)

% Stretch the figure's width slightly to account for longer machine
% descriptions
units1 = get(fig1, 'Units');
set(fig1, 'Units', 'normalized');
pos1 = get(fig1, 'Position');
set(fig1, 'Position', pos1 + [-0.1 -0.1 0.2 0.1]);
set(fig1, 'Units', units1);

hax2 = axes('position',[.4 .1 .5 .8],'parent',fig1);
barh(hax2,speeds.*(1-this),'y')
hold(hax2,'on')
barh(hax2,speeds.*this,'m')
set(hax2,'xlim',[0 max(speeds)+.1],'xtick',0:10:max(speeds))
title(hax2,getString(message('MATLAB:bench:RelativeSpeed')))
axis(hax2,[0 max(speeds)+.1 0 m+1])
set(hax2,'ytick',1:m)
set(hax2,'yticklabel',specs,'fontsize',9)
set(hax2,'OuterPosition',[0 0 1 1]);

% Display report in second figure
fig2 = figure('pos',get(fig1,'pos')+[50 -150 50 0], 'menubar','none', ...
    'numbertitle','off','name',getString(message('MATLAB:bench:MATLABBenchmarkTimes')));

% Defining layout constants - change to adjust 'look and feel'
% The names of the tests
TestNames = {getString(message('MATLAB:bench:LU')), ...
    getString(message('MATLAB:bench:FFT')), ...
    getString(message('MATLAB:bench:ODE')), ...
    getString(message('MATLAB:bench:Sparse')), ...
    getString(message('MATLAB:bench:twoD')), ...
    getString(message('MATLAB:bench:threeD'))};

testDatatips = {getString(message('MATLAB:bench:LUOfMatrix', problemsize(1), problemsize(1))),...
    getString(message('MATLAB:bench:FFTOfVector', problemsize(2))),...
    getString(message('MATLAB:bench:SolutionFromTo', problemsize(3))),...
    getString(message('MATLAB:bench:SolvingSparseLinearSystem', problemsize(4), problemsize(4))),...    
    getString(message('MATLAB:bench:BernsteinPolynomialGraph')),...
    getString(message('MATLAB:bench:AnimatedLshapedMembrane'))};
% Number of test columns
NumTests = size(TestNames, 2);
NumRows = m+1;      % Total number of rows - header (1) + number of results (m)
TopMargin = 0.05; % Margin between top of figure and title row
BotMargin = 0.20; % Margin between last test row and bottom of figure
LftMargin = 0.03; % Margin between left side of figure and Computer Name
RgtMargin = 0.03; % Margin between last test column and right side of figure
CNWidth = 0.40;  % Width of Computer Name column
MidMargin = 0.03; % Margin between Computer Name column and first test column
HBetween = 0.005; % Distance between two rows of tests
WBetween = 0.015; % Distance between two columns of tests
% Width of each test column
TestWidth = (1-LftMargin-CNWidth-MidMargin-RgtMargin-(NumTests-1)*WBetween)/NumTests;
% Height of each test row
RowHeight = (1-TopMargin-(NumRows-1)*HBetween-BotMargin)/NumRows;
% Beginning of first test column
BeginTestCol = LftMargin+CNWidth+MidMargin;
% Retrieve the background color for the figure
bc = get(fig2,'Color');
YourMachineColor = [0 0 1];

% Create headers

% Computer Name column header
uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
    'Position', [LftMargin 1-TopMargin-RowHeight CNWidth RowHeight],...
    'String',  getString(message('MATLAB:bench:LabelComputerType')), 'BackgroundColor', bc, 'Tag', 'Computer_Name','FontWeight','bold');

% Test name column header
for k=1:NumTests
    uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
        'Position', [BeginTestCol+(k-1)*(WBetween+TestWidth) 1-TopMargin-RowHeight TestWidth RowHeight],...
        'String', TestNames{k}, 'BackgroundColor', bc, 'Tag', TestNames{k}, 'FontWeight', 'bold', ...
        'TooltipString', testDatatips{k});
end
% For each computer
for k=1:NumRows-1
    VertPos = 1-TopMargin-k*(RowHeight+HBetween)-RowHeight;
    if this(NumRows - k)
        thecolor = YourMachineColor;
    else
        thecolor = [0 0 0];
    end
    % Computer Name row header
    uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
        'Position', [LftMargin VertPos CNWidth RowHeight],...
        'String', specs{NumRows-k}, 'BackgroundColor', bc, 'Tag', specs{NumRows-k},...
        'TooltipString', details{NumRows-k}, 'HorizontalAlignment', 'left', ...
        'ForegroundColor', thecolor);
    % Test results for that computer
    for n=1:NumTests
        uicontrol(fig2,'Style', 'text', 'Units', 'normalized', ...
            'Position', [BeginTestCol+(n-1)*(WBetween+TestWidth) VertPos TestWidth RowHeight],...
            'String', sprintf('%.4f',T(NumRows-k, n)), 'BackgroundColor', bc, ...
            'Tag', sprintf('Test_%d_%d',NumRows-k,n), 'ForegroundColor', thecolor);
    end
end

% Warning text
uicontrol(fig2, 'Style', 'text', 'Units', 'normalized', ...
    'Position', [0.01 0.01 0.98 BotMargin-0.02], 'BackgroundColor', bc, 'Tag', 'Disclaimer', ...
    'String', getString(message('MATLAB:bench:sprintf_PlaceTheCursorNearAComputerNameForSystemAndVersionDetai')) );

set([fig1 fig2], 'NextPlot', 'new');

% Log selected bench data
logBenchData(times(selected, :));

end
% ----------------------------------------------- %
function dydt = vanderpol(~,y)
%VANDERPOL  Evaluate the van der Pol ODEs for mu = 1
dydt = [y(2); (1-y(1)^2)*y(2)-y(1)];
end

function [t, n] = bench_lu(stream)
% LU, n = 2400.
n = 2400;
reset(stream,0);
A = randn(stream,n,n);
tic
B = lu(A); 
t = toc;
end
% ----------------------------------------------- %
function [t, n] = bench_fft(stream)
% FFT, n = 2^23.
n = 2^23;
reset(stream,1);
x = randn(stream,1,n);
tic;
y = fft(x);
t = toc;
end


% ----------------------------------------------- %
function [t, n] = bench_ode
% ODE. van der Pol equation, mu = 1
F = @vanderpol;
y0 = [2; 0]; 
tspan = [0 eps];
[s,y] = ode45(F,tspan,y0);  %#ok Used  to preallocate s and  y   
tspan = [0 450];
n = tspan(end);
tic
[s,y] = ode45(F,tspan,y0); %#ok Results not used -- strictly for timing
t = toc;
end
% ----------------------------------------------- %
function [t, n] = bench_sparse
% Sparse linear equations
n = 300;
A = delsq(numgrid('L',n));
n = size(A, 1);
b = sum(A)';
tic
x = A\b; %#ok Result not used -- strictly for timing
t = toc;
end
% ----------------------------------------------- %
function t = bench_2d(isVisible)
% 2-D graphics. Lissajous plot. 
hh = figure('Name',getString(message('MATLAB:bench:LissajousPlots')),'NumberTitle','off','Visible', isVisible);
nPoints = 3e3;
theta = linspace(0,2*pi,nPoints);
a = [2 3 3 1];
b = [1, 2, 4, 4];
colors = [0 0.4470 0.7410;
    .8500 0.3250 0.0980;
    .9290 0.6940 0.01250;
    0.4940 0.1840 0.5560];

for i = 1:4
    ax(i) = subplot(2,2,i);
    set(ax(i),'XLim',[-1 1],'YLim',[-1 1]);
    xlabel(['a = ' num2str(a(i)) ', b = ' num2str(b(i))]);
    al(i) = animatedline('Parent',ax(i),'LineStyle','-','Color',colors(i,:));
end
drawnow;
skip = 50;
tStart  = tic;
for i = 1:skip:nPoints-skip
    for k = 1:4
        addpoints(al(k), sin(a(k).*theta(i:i+skip)),  sin(b(k).*theta(i:i+skip)));
    end
    drawnow;
end
for k = 1:4
    addpoints(al(k),sin(a(k).*theta(i+skip+1:nPoints)), sin(b(k).*theta(i+skip+1:nPoints)));
end
drawnow;
t = toc(tStart);
close(hh)
end

% ----------------------------------------------- %
function t = bench_3d(isVisible)
% 3-D graphics. Animating surface.
% Use of HGTransform for animation.
lfigure = figure();
if isVisible
    lfigure.Visible = 'on';
else
    lfigure.Visible = 'off';
end
dAspectRatio = [ 1 2 1];


ax1 = axes('Visible','off','DataAspectRatio',dAspectRatio);
ax2  = axes('Visible','off','DataAspectRatio',dAspectRatio);

[xhRes,yhRes,zhRes] = peaks(150);
[xlRes, ylRes, zlRes] = peaks(64);
xLim = [-4.25 4.25]; 
yLim = [-8 8];

zLim = [-5 5];
set(ax1,'Position',[0 0 .5 1],'XLim', xLim ,'YLim', yLim,'ZLim', zLim,'visible','off');
set(ax2,'Position',[.5 0 .5 1],'XLim', xLim,'YLim', yLim,'ZLim', zLim,'visible','off');
light('parent',ax1);

tTranslate1 = hgtransform('Parent',ax1);
t1 = hgtransform('Parent',tTranslate1);
rotationMatrix = makehgtform('xrotate',5*pi/3)*makehgtform('zrotate',-pi/4);
t1.Matrix = rotationMatrix;
tTranslate2 = hgtransform('Parent',ax2);
t2 = hgtransform('Parent',tTranslate2);
t2.Matrix = rotationMatrix;
s1 = surface(xhRes,yhRes,zhRes,'Parent',t1,'EdgeColor','none');
s2 = surface(xlRes,ylRes,zlRes,'Parent',t2,'FaceColor',get(gcf,'Color'));
l2 = line([xLim(1) xLim(1)],10*[yLim(1) yLim(2)],'Linestyle',':','LineWidth',1,'Color',[.54 .54 .54],'Clipping','off');

tTranslate1.Matrix = makehgtform('translate',8.5,0,0);

drawnow;

t = -1;
numIterations = 8;
tStart = tic;
for i = 1:numIterations
    for j = 1:numIterations
        tTranslate1.Matrix = tTranslate1.Matrix * makehgtform('translate',t,0,0);
        tTranslate2.Matrix = tTranslate2.Matrix * makehgtform('translate',t,0,0);
        drawnow;
    end;
    t = -t;
end
t=toc(tStart);
close(lfigure);
end
