function val = methods(this,fcn,varargin)

val = [];

% one arg is methods(obj) call
if nargin==1
    cls= this.classhandle;
    m = get(cls,'Methods');
    val = get(m,'Name');
    return;
end

args = [{fcn,this},varargin];
if nargout == 0
    feval(args{:});
else
    val = feval(args{:});
end

function over=mouseover(~,~)
over=0

function handled = bdown(~,~)
handled = false;

function update_contextmenu_cb(~,~,~)

function delete_self_cb(~,~,~)

function localChangeLocationCallback(~,~,~,~,~)

function set_standard_colormap_cb(~,~,~,~)

function toggle_editmode_cb(~,~,~)

function edit_colormap_cb(~,~)

function localOpenPropertyEditor(~,~,~)

function localGenerateMCode(~,~,~)
