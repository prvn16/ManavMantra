%% testAddOne
% codegen -config:lib -report testAddOne -args {0}

%% use_shape
% codegen -config:lib -report use_shape

%% getarea
rect_obj = myRectangle(4,5)
codegen -config:lib getarea -args {rect_obj} -report

%% coderand
cfg = coder.config('exe')
cfg.CustomSource = 'coderand_main.c'
cfg.CustomInclude = '.'
codegen -config cfg coderand

%%
mp=MakePolymorphic(1,2);
codegen callpolymorphic -args {mp} -config:lib -launchreport

%%
mn = MakeNet(1,2);
load bodyfat_dataset
mn.inputs=bodyfatInputs;
mn.targets=bodyfatTargets;
mn.fitNet
