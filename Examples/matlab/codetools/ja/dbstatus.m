%DBSTATUS  すべてのブレークポイントのリスト
%
%   DBSTATUS は、ERROR, CAUGHT ERROR, WARNING, NANINF を含むデバッガが
%   認識するすべてのブレークポイントのリストを表示します。
%
%   DBSTATUS MFILE は、指定された M-ファイル内で設定されたブレークポイントを
%   表示します。MFILE は、M-ファイル関数名、または MATLABPATH の相対部分パス名で
%   なければなりません (PARTIALPATH を参照)。
%
%   DBSTATUS('-completenames') は、各関数の "完全な名前" を出力します。完全な
%   名前は、ブレークポイントが設定されている関数をネストする絶対ファイル名と
%   関数の列全体を含みます。
%
%   S = DBSTATUS(...) は、ブレークポイント情報を以下のフィールドを持つ 
%   M 行 1 列の構造体に返します。
%       name -- 関数名。
%       file -- ブレークポイントを含むファイルの完全な名前。
%       line -- ブレークポイントの行番号のベクトル。
%       anonymous -- 'line' フィールドの要素に対応する各要素の整数ベクトル。
%                    それぞれの正の要素は、その行の無名関数の本体にあるブレーク
%                    ポイントを表します。たとえば、その行の 2 番目の無名関数の
%                    本体にあるブレークポイントは、このベクトルにおいて値 2 に
%                    なります。要素が 0 の場合、ブレークポイントは行の始まりにあり、
%                    すなわち、無名関数にはないことを意味します。
%       expression -- 'line' フィールドの行に相当するブレークポイントの条件式の
%                    セルのベクトル。
%       cond -- 条件の文字列 ('error', 'caught error', 'warning' または 'naninf')。
%       identifier -- cond が 'error', 'caught error' または 'warning' の
%                    いずれかである場合、特定の cond の状態を設定する MATLAB 
%                    メッセージ識別子文字列のセルのベクトル。
%
%   参考 DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%        DBQUIT, ERROR, PARTIALPATH, WARNING.


%   Copyright 1984-2009 The MathWorks, Inc.
