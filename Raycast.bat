@echo off
setlocal EnableDelayedExpansion
chcp 65001

set first_start=true

::The angle to begin looking at
set /a start_angle=270

set /a start_angle=!start_angle!+45

::How much to scale the room by.
set /a scale=500
set /a scale_half=!scale!/2
set /a corner_thresh=!scale!/8
set /a width=45
set /a height=30

::The vertical images, saved as horizontal strings
set d33=A···············‾··············B
set d32=A··············_‾··············B
set d31=A·············_##‾·············B
set d30=A·············—##—·············B
set d29=A············_####‾············B
set d28=A············—####—············B
set d27=A···········_######‾···········B
set d26=A···········—######—···········B
set d25=A··········_########‾··········B   
set d24=A··········—########—··········B
set d23=A·········_##########‾·········B
set d22=A·········—##########—·········B
set d21=A········_############‾········B
set d20=A········—############—········B
set d19=A·······_##############‾·······B
set d18=A·······—##############—·······B
set d17=A······_################‾······B
set d16=A······—################—······B
set d15=A·····_##################‾·····B
set d14=A·····—##################—·····B
set d13=A····_####################‾····B
set d12=A····—####################—····B
set d11=A···_######################‾···B
set d10=A···—######################—···B
 set d9=A··_########################‾··B
 set d8=A··—########################—··B
 set d7=A·_##########################‾·B
 set d6=A·—##########################—·B
 set d5=A_############################‾B
 set d4=A—############################—B
 set d3=A##############################B
 set d2=A##############################B
 set d1=A##############################B
 
 ::Generate coordinates
for /l %%y in (1, 1, !height!) do (
	for /l %%x in (1, 1, !width!) do (
		set x%%xy%%y=·
	)
)

::Scale coordinates to allow fractional precision of grid.
set /a high=2
set /a scaler=!scale!*10
set /a scaler=!scaler!*!scaler!
set /a scaler=!scaler!+!scaler!
::Set scale according to the theoretical longest visible distance in map
::(the diagonal distance from one corner of the map to the other)
::The babylonian square root algorithm is used here.
for /l %%x in (1, 1, 30) do (
	set /a low=!scaler!/!high!
	set /a high=!low!+!high!
	set /a high=!high!/2
)
::Divide by the number of vertical detail available (Technically there's 33)
set /a scalediv=!high!/30
echo !scalediv! !scale!

::Read room.txt
:read_map
	set /a y=-1
	set "File=%cd%\room.txt"
	set /a count=0
	
	::Read file line by line
	for /F "tokens=* delims=" %%a in ('Type "%File%"') do (
		Set /a count+=1
		Set "output[!count!]=%%a"
	)
	For /L %%i in (1,1,%Count%) Do (
		Call :Action "!output[%%i]!"
	)
	goto input
	
	::Read line character by character
	:Action
	set l=%1
	set l=%l:"=%
	set /a x=0
	set /a y=%y%+1
	SET strterm=LAST
	SET mytext=!l!
	SET tmp=!mytext!!strterm!
	:loop
		SET char=!tmp:~0,1!
		SET tmp=!tmp:~1!
		::Store map
		set mapx%x%y%y%=!char!
		::Store player position
		if "!char!"=="P" (
			set pcord=x%x%y%y%
			set /a px=!x!
			set /a py=!y!
		)
		set /a x=%x%+1
	IF NOT "!tmp!" == "!strterm!" GOTO loop
	goto :eof


call :find_mid
call :search
goto input

:print_map
	set screen=
	for /l %%y in (0, 1, 10) do (
		for /l %%x in (0, 1, 10) do (
			
			set screen=!screen!!mapx%%xy%%y!
		)
		set screen=!screen!;
	)
	for /l %%y in (0, 1, 10) do (
		for /l %%x in (0, 1, 10) do (
			if "!mapx%%xy%%y!"=="#" (
				set mapx%%xy%%y=·
			)
		)
	)
	for %%f in (%screen%) do @echo                                         %%f
	goto :eof
	
:print_screen
	set screen=
	set "Pattern=·"
	set "Replace= "
	for /l %%y in (1, 1, !height!) do (
		for /l %%x in (1, 1, !width!) do (
			set screen=!screen!!x%%xy%%y!!x%%xy%%y!
		)
		if NOT "!screen!"=="                                                                                          " (
			echo: !screen:%Pattern%=%Replace%!
		) else (
			echo.
		)
		set screen=

	)
	goto :eof
	
	
:input
	cls
	call :print_screen
	echo.
	call :print_map

	if NOT "%first_start%"=="true" (
		set /p move=?^>
	) else (
		set move=filler
	)
	
	set mapx!px!y!py!=·
	if "%move%"=="w" (
		set /a py=!py!-1
	) else if "%move%"=="a" (
		set /a px=!px!-1
	)else if "%move%"=="s" (
		set /a py=!py!+1
	)else if "%move%"=="d" (
		set /a px=!px!+1
	)

	if NOT "%move:x=%"=="%move%" (
		set /a move_amt=%move:x=%
		set /a start_angle=!start_angle!-!move_amt!
	)

	if NOT "%move:z=%"=="%move%" (
		set /a move_amt=%move:z=%
		set /a start_angle=!start_angle!+!move_amt!
	)

	set mapx!px!y!py!=P
	if !start_angle! LSS 0 (
		set start_angle=360+!start_angle!
	)
	if !start_angle! GTR 359 (
		set start_angle=!start_angle!-360
	)
	set pcord=x!px!y!py!
	
	echo Loading Frame . . . 
	call :find_mid
	call :search
	if "%first_start%"=="true" (
	cls
	set first_start=false
	)
	goto input
	
	

::Find's the vector that denotes the center of the player's FOV, stored in nx and ny
::This is used for projection later on.
:find_mid
	set /a x=-1
	set flip=0
	set /a angle=!start_angle!
	for /l %%y in (1, 1, 23) do (
		set /a angle=!angle!-2
		if !angle! LSS 1 (
			set /a angle=360+!angle!
		)
		if !angle! GTR 360 (
			set /a angle=!angle!-360
		)
		set /a angle_num=!angle!-1
		set /a angle_num=!angle_num!/45
		set /a temp_angle=!angle_num!*45
		set /a temp_angle=!angle!-!temp_angle!
		set /a temp_angle=!temp_angle!
		if "!angle_num!"=="0" (
			set priority=y
			set /a dir=-1
			set /a xdir=1
			set /a ydir=-1
		) else if "!angle_num!"=="1" (
			set priority=x
			set /a dir=1
			set /a xdir=1
			set /a ydir=-1
		) else if "!angle_num!"=="2" (
			set priority=x
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!angle_num!"=="3" (
			set priority=y
			set /a dir=1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!angle_num!"=="4" (
			set priority=y
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=1
		) else if "!angle_num!"=="5" (
			set priority=x
			set /a dir=1
			set /a xdir=-1
			set /a ydir=1
		) else if "!angle_num!"=="6" (
			set priority=x
			set /a dir=-1
			set /a xdir=1
			set /a ydir=1
		) else if "!angle_num!"=="7" (
			set priority=y
			set /a dir=1
			set /a xdir=1
			set /a ydir=1
		)
		if "!dir!"=="1" (
			set /a temp_angle-=2
			set /a temp_angle=45-!temp_angle!
		) else (
			set /a temp_angle+=2
		)

		set /a vx=!px!*!scale!+!scale_half!
		set /a vy=!py!*!scale!+!scale_half!
		set /a x=!x!+1
	)
	if "!priority!"=="x" (
		set /a dir2=!xdir!*!temp_angle!
		set /a dir3=!ydir!*45

		set /a nx=!dir2!
		set /a ny=!dir3!
	) else (
		set /a dir3=!xdir!*45
		set /a dir2=!ydir!*!temp_angle!
		set /a nx=!dir3!
		set /a ny=!dir2!
	)
	set /a scale_lvl=!scale!/2
	set /a tnx=!nx!*!scale_lvl!
	set /a tny=!ny!*!scale_lvl!
	set /a tnx=!tnx!*!tnx!
	set /a tny=!tny!*!tny!
	

	set /a toberooted=!tnx!+!tny!
	set /a high=2
	for /l %%x in (1, 1, 30) do (
		set /a low=!toberooted!/!high!
		set /a high=!low!+!high!
		set /a high=!high!/2
	)
	set /a nh=!high!
	set /a unscaled_nh=!nh!/!scale_lvl!

	
	set /a nx=!nx!*!scale!
	set /a ny=!ny!*!scale!
	goto :eof

::Does the actual raycasting.
:search
	set /a vx=%px%*%scale%+!scale_half!
	set /a vy=%py%*%scale%+!scale_half!
	set /a x=-1
	set flip=0
	set /a angle=!start_angle!
	set /a scalediv2=!scale!/2
	set /a tpx=!px!*!scale!+!scale_half!
	set /a tpy=!py!*!scale!+!scale_half!
	set /a tpx=!tpx!+!scalediv2!
	set /a tpy=!tpy!+!scalediv2!
	for /l %%y in (1, 1, 46) do (
		set /a angle=!angle!-2
		if !angle! LSS 1 (
			set /a angle=360+!angle!
		)
		if !angle! GTR 360 (
			set /a angle=360-!angle!
		)
		set /a angle_num=!angle!-1
		set /a angle_num=!angle_num!/45
		set /a temp_angle=!angle_num!*45
		set /a temp_angle=!angle!-!temp_angle!
		set /a temp_angle=!temp_angle!

		if "!angle_num!"=="0" (
			set priority=y
			set /a dir=-1
			set /a xdir=1
			set /a ydir=-1
		) else if "!angle_num!"=="1" (
			set priority=x
			set /a dir=1
			set /a xdir=1
			set /a ydir=-1
		) else if "!angle_num!"=="2" (
			set priority=x
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!angle_num!"=="3" (
			set priority=y
			set /a dir=1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!angle_num!"=="4" (
			set priority=y
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=1
		) else if "!angle_num!"=="5" (
			set priority=x
			set /a dir=1
			set /a xdir=-1
			set /a ydir=1
		) else if "!angle_num!"=="6" (
			set priority=x
			set /a dir=-1
			set /a xdir=1
			set /a ydir=1
		) else if "!angle_num!"=="7" (
			set priority=y
			set /a dir=1
			set /a xdir=1
			set /a ydir=1
		)
		if "!dir!"=="1" (
			set /a temp_angle-=2
			set /a temp_angle=45-!temp_angle!
		) else (
			set /a temp_angle+=2
		)

		set /a vx=!tpx!
		set /a vy=!tpy!
		set /a x=!x!+1
		call :v_search
		
	)
	goto :eof
		:v_search
			if "!priority!"=="x" (
				set /a hx=!xdir!*!temp_angle!
				set /a hy=!ydir!*45

				set /a vx=!vx!+!hx!
				set /a vy=!vy!+!hy!
			) else (
				set /a hy=!ydir!*!temp_angle!
				set /a hx=!xdir!*45
				set /a vx=!vx!+!hx!
				set /a vy=!vy!+!hy!
			)
			set /a checkx=!vx!/!scale!
			set /a checky=!vy!/!scale!
			
			set /a corner_hit=0
			set /a cornercheckx1=!vx!-!corner_thresh!
			set /a cornercheckx2=!vx!+!corner_thresh!
			set /a cornerchecky1=!vy!-!corner_thresh!
			set /a cornerchecky2=!vy!+!corner_thresh!
			
			set /a cornercheckx1=!cornercheckx1!/!scale!
			set /a cornercheckx2=!cornercheckx2!/!scale!
			set /a cornerchecky1=!cornerchecky1!/!scale!
			set /a cornerchecky2=!cornerchecky2!/!scale!
			

			if not "!mapx%cornercheckx1%y%checky%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%cornercheckx2%y%checky%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%checkx%y%cornerchecky1%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%checkx%y%cornerchecky2%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if "!vx!" LSS "-1" (
				echo Player X is out of bounds!
				pause
			)
			if "!mapx%checkx%y%checky%!"=="·" (
				set mapx%checkx%y%checky%=#
				goto :v_search
			) else if "!mapx%checkx%y%checky%!"=="P" (
				goto :v_search
			) else if "!mapx%checkx%y%checky%!"=="#" (
				goto :v_search
			) else (
				set walltype=!mapx%checkx%y%checky%!
				call :draw_line
			)
		goto :eof
	

:draw_line
	::Preparing for projection
	set /a screenx=!x!
	set /a wx=!vx!
	set /a wy=!vy!
	set /a tpx=!px!*!scale!+!scale_half!
	set /a tpy=!py!*!scale!+!scale_half!
	set /a wx=!wx!-!tpx!
	set /a wy=!wy!-!tpy!
	if !wx! LSS 0 (
		set /a wx=!wx!*-1
	)
	if !wy! LSS 0 (
		set /a wy=!wy!*-1
	)
	
	set /a d=!nh!
	set /a wx=!wx!
	set /a wy=!wy!
	set /a a1=!wx!*!nx!
	if !d! LSS 0 (
		set /a nh=!a1!*-1
	)
	if !a1! LSS 0 (
		set /a a1=!a1!*-1
	)
	set /a a2=!wy!*!ny!
	if !a2! LSS 0 (
		set /a a2=!a2!*-1
	)

	set /a a=!a1!+!a2!
	set /a d=!a!/!d!

	set /a h=!height!+3
	set /a h_scaled=!h!*!scale!

	set /a dd=!h_scaled!/!d!
	set /a dd=!h!-(!dd!*2)

	if !dd! LSS 1 (
		set /a dd=1
	)
	
	if !dd! GTR !h_scaled! (
		set /a dd=!h!
	)

	set view=!d%dd%!

	if !corner_hit! LSS 2 (
		set view=!view:#=%walltype%!
	) else (
		set view=!view:#=█!
	)

	for /l %%y in (1, 1, !height!) do (
		set x!screenx!y%%y=!view:~%%y,1!
	)

	goto :eof