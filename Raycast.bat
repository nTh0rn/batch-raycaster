@echo off
setlocal enableextensions EnableDelayedExpansion
chcp 65001
cls
::Allow overprinting on same line for loading bars, etc
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

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
 <nul set /p"=Generating Coordinates . . . !CR!"
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
	
::Print the screen from the x and y coordinate variables
:print_screen
	set screen=
	::Used to replace the filler whitespace with true whitespace
	set "temp_whitespace=·"
	set "real_whitespace= "
	for /l %%y in (1, 1, !height!) do (
		for /l %%x in (1, 1, !width!) do (
			set screen=!screen!!x%%xy%%y!!x%%xy%%y!
		)
		::Print the screen row and replace the filler whitespace.
		echo: !screen:%temp_whitespace%=%real_whitespace%!
		set screen=

	)
	goto :eof
	
	
:input
	::cls
	if NOT "%first_start%"=="true" (
		call :print_screen
		echo.
		call :print_map
		set /p move=?^>
	) else (
		set move=NIL
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
	
	
	call :find_mid
	call :search
	if "%first_start%"=="true" (
	::cls
	set first_start=false
	)
	goto input
	

::Find's the vector that denotes the center of the player's FOV, stored in nx and ny
::This is used for projection later on.
:find_mid

	set /a angle=!start_angle!-44
	if !angle! LSS 1 (
		set /a angle=360+!angle!
	)
	if !angle! GTR 360 (
		set /a angle=!angle!-360
	)
	set /a octant=!angle!-1
	set /a octant=!octant!/45
	set /a oct_angle=!octant!*45
	set /a oct_angle=!angle!-!oct_angle!
	set /a oct_angle=!oct_angle!
	if "!octant!"=="0" (
		set priority=y
		set /a dir=-1
		set /a xdir=1
		set /a ydir=-1
	) else if "!octant!"=="1" (
		set priority=x
		set /a dir=1
		set /a xdir=1
		set /a ydir=-1
	) else if "!octant!"=="2" (
		set priority=x
		set /a dir=-1
		set /a xdir=-1
		set /a ydir=-1
	) else if "!octant!"=="3" (
		set priority=y
		set /a dir=1
		set /a xdir=-1
		set /a ydir=-1
	) else if "!octant!"=="4" (
		set priority=y
		set /a dir=-1
		set /a xdir=-1
		set /a ydir=1
	) else if "!octant!"=="5" (
		set priority=x
		set /a dir=1
		set /a xdir=-1
		set /a ydir=1
	) else if "!octant!"=="6" (
		set priority=x
		set /a dir=-1
		set /a xdir=1
		set /a ydir=1
	) else if "!octant!"=="7" (
		set priority=y
		set /a dir=1
		set /a xdir=1
		set /a ydir=1
	)
	if "!dir!"=="1" (
		set /a oct_angle-=2
		set /a oct_angle=45-!oct_angle!
	) else (
		set /a oct_angle+=2
	)

	set /a vx=!px!*!scale!+!scale_half!
	set /a vy=!py!*!scale!+!scale_half!
	set /a screenx=!screenx!+1
	
	if "!priority!"=="x" (
		set /a dir2=!xdir!*!oct_angle!
		set /a dir3=!ydir!*45

		set /a nx=!dir2!
		set /a ny=!dir3!
	) else (
		set /a dir3=!xdir!*45
		set /a dir2=!ydir!*!oct_angle!
		set /a nx=!dir3!
		set /a ny=!dir2!
	)
	set /a tnx=!nx!/2
	set /a tny=!ny!/2
	set /a tnx=!tnx!*!tnx!
	set /a tny=!tny!*!tny!
	

	set /a toberooted=!tnx!+!tny!
	set /a high=2
	for /l %%x in (1, 1, 30) do (
		set /a low=!toberooted!/!high!
		set /a high=!low!+!high!
		set /a high=!high!/2
	)
	
	::Final distance of n
	set /a n_distance=!high!

	goto :eof

::Does the actual raycasting.
:search
	
::	The ray vector's x and y components
	set /a vx=!px!*!scale!+!scale_half!
	set /a vy=!py!*!scale!+!scale_half!
	
::	The current vertical-column
	set /a screenx=-1
	
::	Establish the current angle
	set /a angle=!start_angle!

::	Establish the temporary vector components
	set /a tvx=!vx!
	set /a tvy=!vy!

	set loading_bar_amt=#
	for /l %%y in (1, 1, 46) do (
	
		set /a angle=!angle!-2
		if !angle! LSS 1 (
			set /a angle=360+!angle!
		)
		if !angle! GTR 360 (
			set /a angle=360-!angle!
		)
::		Define what octant the angle is within
		set /a octant=!angle!/45
		set /a oct_angle=!octant!*45
		set /a oct_angle=!angle!-!oct_angle!
		set /a oct_angle=!oct_angle!

		if "!octant!"=="0" (
			set priority=y
			set /a dir=-1
			set /a xdir=1
			set /a ydir=-1
		) else if "!octant!"=="1" (
			set priority=x
			set /a dir=1
			set /a xdir=1
			set /a ydir=-1
		) else if "!octant!"=="2" (
			set priority=x
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!octant!"=="3" (
			set priority=y
			set /a dir=1
			set /a xdir=-1
			set /a ydir=-1
		) else if "!octant!"=="4" (
			set priority=y
			set /a dir=-1
			set /a xdir=-1
			set /a ydir=1
		) else if "!octant!"=="5" (
			set priority=x
			set /a dir=1
			set /a xdir=-1
			set /a ydir=1
		) else if "!octant!"=="6" (
			set priority=x
			set /a dir=-1
			set /a xdir=1
			set /a ydir=1
		) else if "!octant!"=="7" (
			set priority=y
			set /a dir=1
			set /a xdir=1
			set /a ydir=1
		)
		
		if "!dir!"=="1" (
			set /a oct_angle-=2
			set /a oct_angle=45-!oct_angle!
		) else (
			set /a oct_angle+=2
		)

		set /a vx=!tvx!
		set /a vy=!tvy!
		set /a screenx=!screenx!+1
		echo FUCK 2
		call :v_search
		
	)
	goto :eof
		:v_search
			
			set /a mvmt_scale=1
			set /a tvx=!vx!
			set /a tvy=!vy!
			if "!priority!"=="x" (
				set /a hx=!xdir!*!oct_angle!
				set /a hy=!ydir!*45
				
				::set /a vx=!vx!+!hx!
				::set /a vy=!vy!+!hy!
			) else (
				set /a hy=!ydir!*!oct_angle!
				set /a hx=!xdir!*45
				::set /a vx=!vx!+!hx!
				::set /a vy=!vy!+!hy!
			)
			
			set /a floor_x=!vx!/!scale!
			set /a floor_y=!vy!/!scale!
			
			set /a frac_x=!floor_x!*!scale!
			set /a frac_y=!floor_y!*!scale!
			
			set /a frac_x=!vx!-!frac_x!
			set /a frac_y=!vy!-!frac_y!
			
			if !hx! GTR 0 (
				set /a frac_x=!scale!-!frac_x!
			)
			if !hy! GTR 0 (
				set /a frac_y=!scale!-!frac_y!
			)
			
			set /a mult_x=!frac_x!/!hx!
			set /a mult_y=!frac_y!/!hy!
			
			if !mult_x! LSS 0 (
				set /a mult_x=!mult_x!*-1
			)
			
			if !mult_y! LSS 0 (
				set /a mult_y=!mult_y!*-1
			)
			
			set /a mult_x+=1
			set /a mult_y+=1
			echo !mult_x! !mult_y!
			if !mult_x! LSS !mult_y! (
				set /a mult_x=!mult_x!*!hx!
				set /a mult_y=!mult_x!*!hy!
			) else (
				set /a mult_x=!mult_y!*!hx!
				set /a mult_y=!mult_y!*!hy!
			)
			echo !mult_x! !mult_y!
			
			
			set /a vx=!vx!+!mult_x!
			set /a vy=!vy!+!mult_y!
			
			
			
			set /a checkx=!vx!/!scale!
			set /a checky=!vy!/!scale!
			
			set /a corner_hit=0
			set /a ccx_low=!vx!-!corner_thresh!
			set /a ccx_high=!vx!+!corner_thresh!
			set /a ccy_low=!vy!-!corner_thresh!
			set /a ccy_high=!vy!+!corner_thresh!
			
			set /a ccx_low=!ccx_low!/!scale!
			set /a ccx_high=!ccx_high!/!scale!
			set /a ccy_low=!ccy_low!/!scale!
			set /a ccy_high=!ccy_high!/!scale!
			
::			Check whether the current vector + or - the corner threshhold is defined
::			as a different cell and, therefore, near the edges of the cell. This can
::			only ever be the case for 1 of the x checks and 1 of the y checks, but if
::			it is the case for both, then the ray must be near a corner. If this occurs
::			then corner_hit will get added to twice.
			if not "!mapx%ccx_low%y%checky%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%ccx_high%y%checky%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%checkx%y%ccy_low%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if not "!mapx%checkx%y%ccy_high%!"=="!mapx%checkx%y%checky%!" (
				set /a corner_hit=!corner_hit!+1
			)
			if "!vx!" LSS "-1" (
				echo Player X is out of bounds!
				pause
			)
			
			
			echo KYS
			if "!mapx%checkx%y%checky%!"=="·" (
			echo KYS2
				set mapx%checkx%y%checky%=#
				goto :v_search
			) else if "!mapx%checkx%y%checky%!"=="P" (
			echo KY3
				goto :v_search
			) else if "!mapx%checkx%y%checky%!"=="#" (
			echo KY4
				goto :v_search
			) else (
				set walltype=!mapx%checkx%y%checky%!
				call :draw_line
			)
		goto :eof
	
	
:test_jump
	if %mvmt_scale% GTR !scale! (
		set /a %mvmt_scale%=!scale!
	)
	set /a jump_x=!mvmt_scale!*!hx!
	set /a jump_y=!mvmt_scale!*!hy!
	set /a jump_x=!tvx!+!jump_x!
	set /a jump_y=!tvy!+!jump_y!
	
	set /a check_jump_x=!jump_x!/!scale!
	set /a check_jump_y=!jump_y!/!scale!

	
	
	if "!mapx%check_jump_x%y%check_jump_y%!"=="·" (
		set blank=
	) else if "!mapx%check_jump_x%y%check_jump_y%!"=="P" (
		set blank=
	) else if "!mapx%check_jump_x%y%check_jump_y%!"=="#" (
		set blank=
	) else (
		set /a mvmt_scale=1
		goto :eof
	)
	

	set /a dif=0
	if not "!checkx!"=="!check_jump_x!" (
		set /a dif+=1
	)
	
	if not "!checky!"=="!check_jump_y!" (
		set /a dif+=1
	)
	
	if "!same!"=="0" (
		set /a mvmt_scale+=5
		goto test_jump
	)
	if !dif! LSS 2 (
		set /a vx=!jump_x!
		set /a vy=!jump_y!
	)
	
	goto :eof
	
	
:draw_line
	
::	The player's scaled x and y coordinates.
	set /a tvx=!px!*!scale!+!scale_half!
	set /a tvy=!py!*!scale!+!scale_half!
	
::	The distance between the ray's collision point and the player
	set /a vx=!vx!-!tvx!
	set /a vy=!vy!-!tvy!
	
::	Ensure all terms are positive.
	if !vx! LSS 0 (
		set /a vx=!vx!*-1
	)
	if !vy! LSS 0 (
		set /a vy=!vy!*-1
	)
	
::	
	set /a d=!n_distance!

	set /a dot_x=!vx!*!nx!
	if !d! LSS 0 (
		set /a n_distance=!dot_x!*-1
	)
	if !dot_x! LSS 0 (
		set /a dot_x=!dot_x!*-1
	)
	set /a dot_y=!vy!*!ny!
	if !dot_y! LSS 0 (
		set /a dot_y=!dot_y!*-1
	)

	set /a dot=!dot_x!+!dot_y!
	set /a d=!dot!/!d!

	set /a h=!height!+3
	set /a h_scaled=!h!*!scale!
	set /a distance=!h_scaled!/!d!
	set /a distance=!h!-!distance!
	if !distance! LSS 1 (
		set /a distance=1
	)
	
	if !distance! GTR !h_scaled! (
		set /a distance=!h!
	)
::	The vertical column for the distance calculated
	set view=!d%distance%!

::	Replace wall-characters with the associated character on
::	the map or with the corner-defining character.
	if !corner_hit! LSS 2 (
		set view=!view:#=%walltype%!
	) else (
		set view=!view:#=█!
	)

::	Iterate through the screen and insert this vertical column
	for /l %%y in (1, 1, !height!) do (
		set x!screenx!y%%y=!view:~%%y,1!
	)

	goto :eof