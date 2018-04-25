%DBSTOP  ブレークポイントの設定
%
%   コマンド DBSTOP は、M-ファイル関数の実行を一時的に停止するときに使い、
%   ローカルのワークスペースの内容を調べることができます。このコマンドには、
%   いくつかの形式があります。以下のようになります。
%
%   (1)  DBSTOP in MFILE at LINENO
%   (2)  DBSTOP in MFILE at LINENO@
%   (3)  DBSTOP in MFILE at LINENO@N
%   (4)  DBSTOP in MFILE at SUBFUN
%   (5)  DBSTOP in MFILE
%   (6)  DBSTOP in MFILE at LINENO if EXPRESSION
%   (7)  DBSTOP in MFILE at LINENO@ if EXPRESSION
%   (8)  DBSTOP in MFILE at LINENO@N if EXPRESSION
%   (9)  DBSTOP in MFILE at SUBFUN if EXPRESSION
%   (10) DBSTOP in MFILE if EXPRESSION
%   (11) DBSTOP if error
%   (12) DBSTOP if caught error
%   (13) DBSTOP if warning
%   (14) DBSTOP if naninf  or  DBSTOP if infnan
%   (15) DBSTOP if error IDENTIFIER
%   (16) DBSTOP if caught error IDENTIFIER
%   (17) DBSTOP if warning IDENTIFIER
%
%   MFILE は、M-ファイルの名前、または MATLABPATH 相対部分パス名でなければ
%   なりません (参照 PARTIALPATH)。コマンドが -completenames オプションを含み、
%   MFILE が完全修飾子付きのファイル名として指定されている場合は、MFILE はパス上
%   にある必要はありません。(Windows では、これは、コロンが \\ またはドライブ名
%   の後に続いて始まるファイル名です。Unix では、これは、/ または ~ で始まる
%   ファイル名です。)MFILE は、M-ファイル内の特定のサブ関数、または、ネスト
%   関数へのパスを指定する filemarker を含むことができます。
%
%   LINENO は、MFILE 内の行番号で、N はその行にある N 番目の無名関数を指定する
%   整数で、SUBFUN は MFILE 内のサブ関数の名前です。EXPRESSION は、実行可能な
%   条件式を含む文字列です。IDENTIFIER は、MATLAB のメッセージ識別子です 
%   (メッセージ識別子の記述は ERROR のヘルプを参照)。キーワード AT, IN は
%   オプションです。
%
%   形式は、以下のように動作します。
%
%   (1)  MFILE 内の指定した行番号で停止します。
%   (2)  MFILE の指定した行番号で、最初のある関数が呼び出された直後に停止します。
%   (3)  (2) と同様ですが、N 番目のある関数が呼び出された直後に停止します。
%   (4)  MFILE の指定したサブ関数で停止します。
%   (5)  MFILE の最初の実行可能な行で停止します。
%   (6-10) EXPRESSION を true に評価する場合のみ停止することを除き、
%        (1)-(5) と同じです。EXPRESSION は、ブレークポイントに達した場合、
%        MFILE のワークスペース内で (EVAL の場合のように) 評価されます。
%        これは、スカラの論理値 (true または false) で評価されなければ
%        なりません。
%   (11) TRY...CATCH ブロック内で検出されない実行時エラーを起こす M-ファイル
%        関数内で停止を引き起こします。
%        catch されなかった実行時エラーの後には、M-ファイルの実行を再開できません。
%   (12) TRY...CATCH ブロック内で検出された実行時エラーの原因となる M-ファイル
%        関数で停止します。実行時エラーを catch した後、M-ファイルの実行を
%        再開することができます。
%   (13) 実行時警告の原因となる M-ファイル関数内で停止します。
%   (14) 無限大 (Inf)、または、NaN が検知された位置に存在する M-ファイル内で
%        停止します。
%   (15-17) メッセージ識別子が IDENTIFIER であるエラーまたは警告において、
%        MATLAB が停止することを除き、(11)-(13) と同様です。(IDENTIFIER が
%        特定の文字列 'all' の場合、これらは、(11)-(13) と同じ動作になります。)
%
%   MATLAB がブレークポイントに達すると、デバッグモードに入ります。すると、
%   プロンプトが、K>> に変わり、デバッグメニューの "デバッグ時に M-ファイルを
%   開く" の設定によって、デバッガウィンドウがアクティブになります。任意の 
%   MATLAB コマンドをプロンプトに入力することができます。M-ファイルの実行を
%   再開するには、DBCONT または DBSTEP を使用してください。デバッガから
%   抜け出すには、DBQUIT を使用してください。
%
%   参考 DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%        DBQUIT, FILEMARKER, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY,
%        WARNING.


%   Copyright 1984-2009 The MathWorks, Inc.
