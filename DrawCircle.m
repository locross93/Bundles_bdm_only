%----------
% @file DrawCircle.m
% @brief Create and output circle stimulus. 円の作成、出力。
%
% Create and output circle stimulus. 円の作成、出力。
% 
% @author	T.Higashi
% @date		2008/01/24
%
% @par Change log
% - 2008/01/24	T.Higashi	:New. 新規作成。
% 
%%
%----------
% varargout = DrawCircle(iselector, varargin)
% @param	iselector	:Selector to change process('init', 'draw', 'clear' or 'get'). 処理の切り替え('init', 'draw', 'clear','get')。
% @param	varargin	:Input argments related to selector. 処理に応じた入力引数。
% @retval	varargout	:Onput argments related to selector. 処理に応じた出力引数。
% 
% cirp = DrawCircle('init', wpt, pntC, diaCrl, clrCrl, sclAll, dst)
% DrawCircle('draw', wpt, cirp)
% DrawCircle('clear', cirp)
% DrawCircle('get', cirp)
% wpt		:Window pointer. ウィンドウポインタ。
% cirp		:Circle pointer. 円ポインタ。
% pntC		:Point setting. 円の中点位置設定。
% diaCrl	:Circle diameter setting. 円の直径設定。
% clrCrl	:Circle color setting. 円の色設定。
% sclAll	:Entire scale setting. 全体スケール設定。
% dst		:Distance from the display(mm). 被験者とディスプレイとの距離(mm)。
% 
%%
function varargout = DrawCircle(iselector, varargin)

	persistent SETTING

	switch iselector

	case 'init'
		% Initialize random dot data.
		% 円データの初期化。
		if length(varargin) == 6

			[wpt, pntC, diaCrl, clrCrl, sclAll, dst] = deal(varargin{:});
			[SETTING, cirp] = CreateSetting(SETTING, wpt, pntC, diaCrl, clrCrl, sclAll, dst);
			varargout = {cirp};

		else

			error('DrawCircle(''init'', wpt, pntC, diaCrl, clrCrl, sclAll, dst)');

		end


	case 'draw'

		% Draw circle.
		% 円の描画。
		if length(varargin) == 2

			[wpt, cirp] = deal(varargin{:});
			CLRCRL = SETTING{cirp, 1};
			RECT = SETTING{cirp, 2};
			Screen('FillOval', wpt, CLRCRL, RECT);

		else

			error('DrawCircle(''draw'', wpt, cirp)');

		end


	case 'clear'

		% clear circle data.
		% 円データの削除。
		if length(varargin) == 1

			[cirp] = deal(varargin{:});
			if cirp == size(SETTING, 1);
				SETTING(cirp,:) = [];
			else
				SETTING(cirp,:) = repmat({[]}, 1, size(SETTING, 2));
			end

		else

			error('DrawCircle(''clear'', cirp)');

		end


	case 'get'

		% Get circle data.
		% 円データの取得。
		if length(varargin) == 1

			[cirp] = deal(varargin{:});
			if isempty(cirp)
				varargout = {SETTING};
			else
				varargout = {SETTING(cirp,:)};
			end

		else

			error('DrawCircle(''get'', cirp)');

		end

	end


function [oSETTING, oidx] = CreateSetting(iSETTING, iwpt, ipntC, idiaCrl, CLRCRL, isclAll, idst)

	% If the distance from the display is given, transform the unit.
	% ディスプレイとの距離が指定されているなら長さの単位がdegだと判断し、単位をpixel変換する。
	ppd = GetPpd(iwpt, idst);
	if ppd > 0
		idiaCrl = round(idiaCrl * ppd);
	end


	% Coordinate transform.
	% 座標系をあわせる。
	[sizW, sizH] = Screen( 'WindowSize', iwpt );
	pntO = round([sizW, sizH] / 2);
	ipntCinW = ipntC + pntO;

	% Transesate to display position and zoom.
	% 表示位置への移動と拡大縮小。
	RECT = round([0, 0, idiaCrl, idiaCrl]);
	RECT = CenterRectOnPoint(RECT, ipntCinW(1), ipntCinW(2));


	% Adjust image size.
	% サイズを調節。
	if ~isempty(isclAll)
		RECT = ZoomRect(RECT, isclAll, pntO);
	end


	if isempty(iSETTING)
		oidx = [];
	else
		oidx = min(find(cellfun('isempty', iSETTING(:,1))));
	end

	if isempty(oidx)
		% Append new data.
		% 新しいデータを追加。
		oSETTING = [iSETTING; {CLRCRL, RECT}];
		oidx = size(oSETTING, 1);
	else
		% Assign new data to empty place.
		% 新しいデータを開いている場所に追加。
		oSETTING = iSETTING;
		oSETTING(oidx, :) = {CLRCRL, RECT};
	end
