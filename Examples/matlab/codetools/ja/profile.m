%PROFILE  関数用のプロファイル実行時間
%
%   PROFILE ON は、プロファイルを開始し、それ以前に記録されたプロファイルの
%   統計をクリアします。
%
%   PROFILE には以下のオプションを与えられます。
%
%      -DETAIL LEVEL
%         このオプションは、プロファイル統計量をカウントする関数の種類を指定
%         するものです。LEVEL が 'mmex' (デフォルト) の場合、M-関数、M-サブ関数、
%         MEX-関数に関する情報が記録されます。LEVEL が 'buitin' の場合、EIG 等の
%         組み込み関数に関する情報も記録します。
%
%      -TIMER CLOCK
%         このオプションは、プロファイル中に使用する時間のタイプを指定します。
%         CLOCK が 'cpu' (デフォルト) の場合、計算時間が測定されます。
%         CLOCK が 'real' の場合、経過時間が計測されます。たとえば、関数 
%         PAUSE は、非常に小さい cpu 時間ですが、実際に一時停止する時間を
%         占める実時間を持ちます。
%
%      -HISTORY
%         このオプションが指定された場合、関数呼び出しの履歴レポートが生成
%         されるような関数呼び出しの正確なシーケンスを記録します。
%         注意: MATLAB は、10000 以上の関数や exit イベントを記録しません 
%         (下記の -HISTORYSIZE を参照)。しかし MATLAB は、このような制限を
%         超えても、他のプロファイルの統計量は記録し続けます。
%
%      -NOHISTORY
%         このオプションが指定された場合、MATLAB は履歴の記録を無効にします。
%         他のすべてのプロファイラ統計量は、収集を続けます。
%
%      -HISTORYSIZE SIZE
%         このオプションは、関数の呼び出し履歴のバッファ長を指定します。
%         デフォルトは 1000000 です。
%
%      オプションは、同じコマンドで ON の前後のいずれかに置きますが、
%      プロファイラが前のコマンドで開始しておらず、まだ中止していない場合、
%      変更されない可能性があります。
%
%   PROFILE OFF は、プロファイルの実行を中止します。
%
%   PROFILE VIEWER はプロファイラを中止し、グラフィカルなプロファイルブラウザ
%   を開きます。PROFILE VIEWER に対する出力は、プロファイラウィンドウ内の 
%   HTML ファイルです。関数のプロファイルページの下にリストされたファイルは、
%   コードの各行の左側から 4 列に表示されます。
%         列 1 (赤) は、行で費やされる時間の合計 (s) です。
%         列 2 (青) は、その行を呼び出す数です。
%         列 3 は、行番号です
%
%   PROFILE RESUME は、それ以前に記録された関数の統計量をクリアせずに
%   プロファイルを再開します。
%
%   PROFILE CLEAR は、記録されたすべてのプロファイル統計量をクリアします。
%
%   S = PROFILE('STATUS') は、現在のプロファイラ状態に関する情報を含む
%   構造体を返します。S は、以下のフィールドを含みます。
%
%       ProfilerStatus   -- 'on' または 'off'
%       DetailLevel      -- 'mmex' または 'builtin'
%       Timer            -- 'cpu' または 'real'
%       HistoryTracking  -- 'on' または 'off'
%       HistorySize      -- 10000 (デフォルト)
%
%   STATS = PROFILE('INFO') は、プロファイラを停止し、現在のプロファイラ
%   統計量を含む構造体を返します。STATS は、以下のフィールドを含みます。
%
%       FunctionTable    -- 呼びだされた各関数についての統計を含む構造体配列
%       FunctionHistory  -- 関数呼び出し履歴テーブル
%       ClockPrecision   -- プロファイラの時間測定の精度
%       ClockSpeed       -- cpu の推定クロック速度 (あるいは 0)
%       Name             -- プロファイラの名前 (すなわち、MATLAB)
%
%   FunctionTable 配列は、STATS 構造体の最も重要な部分です。
%   そのフィールドは、以下のようになります。
%
%       FunctionName     -- サブ関数リファレンスを含む関数名
%       FileName         -- ファイル名は、完全修飾子付きのパスです
%       Type             -- M-ファンクション、MEX-ファンクション
%       NumCalls         -- この関数が呼び出される時間数
%       TotalTime        -- この関数に費やされる時間の合計
%       Children         -- FunctionTable は、子関数にインデックスを付けます
%       Parents          -- FunctionTable は、親関数にインデックスを付けます
%       ExecutedLines    -- 行毎の詳細を取り扱う配列 (下記参照)
%       IsRecursive      -- 関数が再帰的であるかどうか判定する boolean 値
%       PartialData      -- プロファイル中にこの関数が変更されたかどうか。
%                           boolean 値
%
%   ExecutedLines 配列には、いくつかの列があります。列 1 は、実行される
%   行数です。行が実行されなかった場合は、この行列には現れません。
%   列 2 は、実行された時間数です。列 3 は、その行に費やされた時間の合計です。
%   注意: 列 3 の和を関数の TotalTime に加える必要はありません。
%
%   プロファイラセッションの結果をディスクに保存する場合、PROFSAVE コマンドを
%   使用してください。
%
%   例:
%
%       profile on
%       plot(magic(35))
%       profile viewer
%       profsave(profile('info'),'profile_results')
%
%       profile on -history
%       plot(magic(4));
%       p = profile('info');
%       for n = 1:size(p.FunctionHistory,2)
%           if p.FunctionHistory(1,n)==0
%               str = 'entering function: ';
%           else
%               str = ' exiting function: ';
%           end
%           disp([str p.FunctionTable(p.FunctionHistory(2,n)).FunctionName]);
%       end
%
%   参考 PROFSAVE, PROFVIEW.


%   Copyright 1984-2009 The MathWorks, Inc.
