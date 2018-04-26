% codegen -config:lib -report testAddOne -args {0}
% codegen -config:lib -report use_shape

%% getarea
rect_obj = myRectangle(4,5)
codegen -config:lib getarea -args {rect_obj} -report

%% coderand
cfg = coder.config('exe')
cfg.CustomSource = 'coderand_main.c'
cfg.CustomInclude = '.'
codegen -config cfg coderand