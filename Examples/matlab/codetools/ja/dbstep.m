%DBSTEP  現在のブレークポイントから 1 行または複数行を実行
%
%   DBSTEP は、実行可能な MATLAB コードの 1 行または複数行を実行し、終了
%   するとデバッグモードに戻ります。このコマンドには 4 つの形式があります。
%   以下のようになります。
%
%   DBSTEP
%   DBSTEP nlines
%   DBSTEP IN
%   DBSTEP OUT
%
%   ここで、nlines は実行する行数です。最初の形式では、次の実行可能な行を
%   実行します。2 番目の形式は、次の nlines 個の実行可能な行を実行します。
%   次の実行可能な行が、他の M-ファイル関数を読み込むとき、3 番目の形式は
%   読み込まれる M-ファイル関数内の最初の実行可能な行に移動します。
%   4 番目の形式は、関数の残りの部分を実行し、終了後すぐに停止します。
%   すべての形式において、MATLAB は、ブレークポイントがあると、そこで
%   実行を停止します。
%
%   参考 DBCONT, DBSTOP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%        DBSTATUS, DBQUIT.


%   Copyright 1984-2009 The MathWorks, Inc.
