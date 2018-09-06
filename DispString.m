%----------
% @file DispString.m
% @brief Create and output string stimulus. 文字列刺激の作成、出力。
%
% Create and output string stimulus. 文字列刺激の作成、出力。
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/02/06	T.Higashi	:Change to use height scale. 幅、高さ方向縮尺の高さのみ利用することにした。
% - 2008/01/24	T.Higashi	:New. 新規作成。
% 
%%
%----------
% varargout = DispString(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). 処理の切り替え('init', 'draw', 'clear','get')。
% @param	varargin	:Input argments related to selector. 処理に応じた入力引数。
% @retval	varargout	:Onput argments related to selector. 処理に応じた出力引数。
% 
% strp = DispString('init', wpt, str, pntStr, sizStr, clrStr, sclAll)
% DispString('draw', wpt, strp)
% DispString('clear', strp)
% DispString('get', strp)
% wpt		:Window pointer. ウィンドウポインタ。
% strp		:Image pointer. 文字列ポインタ。
% str		:String. 文字列。
% pntStr	:Point setting. 文字列表示位置設定。
% sizStr	:Font size setting. フォントサイズ設定。
% clrStr	:String color setting. 文字色設定。
% sclAll	:Entire scale setting. 全体スケール設定。
% 
%%
function varargout = DispString(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize string data.
		% 文字列用データの初期化。
		if length(varargin) == 6

			[wpt, str, pntStr, sizStr, clrStr, sclAll] = deal(varargin{:});
			[SETTING, strp] = CreateSetting(SETTING, wpt, str, pntStr, sizStr, clrStr, sclAll);
			varargout = {strp};

		else

			error('DispString(''init'', wpt, str, pntStr, sizStr, clrStr, sclAll)');

		end


	case 'draw'

		% Draw string.
		% 文字列の描画。
		if length(varargin) == 2

			[wpt, strp] = deal(varargin{:});
			SIZSTR = SETTING{strp, 1};
			STR = SETTING{strp, 2};
			RECT = SETTING{strp, 3};
			CLRSTR = SETTING{strp, 4};
			Screen('TextSize', wpt, SIZSTR);
			Screen('DrawText', wpt, STR, RECT(1), RECT(2), CLRSTR);

		else

			error('DispString(''draw'', wpt, strp)');

		end


	case 'clear'

		% clear string data.
		% 文字列データの削除。
		if length(varargin) == 1

			[strp] = deal(varargin{:});
			if strp == size(SETTING, 1);
				SETTING(strp,:) = [];
			else
				SETTING(strp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DispString(''clear'', strp)');

		end


	case 'get'

		% Get string data.
		% 文字列データの取得。
		if length(varargin) == 1

			[strp] = deal(varargin{:});
			if isempty(strp)
				varargout = {SETTING};
			else
				varargout = {SETTING(strp,:)};
			end

		else

			error('DispString(''get'', strp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, STR, ipntStr, SIZSTR, CLRSTR, isclAll)

	% Coordinate transform.
	% 座標系をあわせる。
	[sizW, sizH] = Screen('WindowSize', iwpt);
	pntO = round([sizW, sizH] / 2);
	ipntStr = ipntStr + pntO;

	% Get text rectangle.
	% 文字列表示領域取得。
	Screen( 'TextSize', iwpt, SIZSTR );
	RECT = Screen('TextBounds', iwpt, STR);

	% Transesate to display position.
	% 表示位置への移動。
	RECT = CenterRectOnPoint(RECT, ipntStr(1), ipntStr(2));

	% Adjust image size.(use height scale. Don't use width scale.)
	% サイズを調節(高さ方向のみ利用)。
	if ~isempty(isclAll) && ~isequal(isclAll, [100, 100])
		tmpRECT = ZoomRect(RECT, isclAll, pntO);
		[cx, cy] = RectCenter(tmpRECT);
		SIZSTR = round(SIZSTR * isclAll(2) / 100);
		Screen( 'TextSize', iwpt, SIZSTR );
		RECT = Screen('TextBounds', iwpt, STR);
		RECT = CenterRectOnPoint(RECT, cx, cy);
	end


	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% 新しいデータを追加。
		oSETTING = [iSETTING; {SIZSTR, STR, RECT, CLRSTR}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% 新しいデータを開いている場所に追加。
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {SIZSTR, STR, RECT, CLRSTR};
	end

