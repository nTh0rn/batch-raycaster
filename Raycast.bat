goto SKIP_COMMENTS
###############################################################
Raycaster in Batch
Written by Nikolas Thornton
https://github.com/nTh0rn/batch-raycaster

I wrote about all the intricacies of this project on my website
over at https://www.nthorn.com/articles/batch-raycaster
###############################################################
:SKIP_COMMENTS
@echo off
title Raycaster
setlocal enableextensions EnableDelayedExpansion
chcp 65001
cls
::Allow overprinting on same line for loading bars, etc
for /f %%a in ('copy /Z "%~dpf0" nul') do set "CR=%%a"

set first_start=true

::The angle to begin looking at
set /a start_angle=270

::The beginning angle is increased by 45 degrees to start at the far left of the FOV
set /a start_angle=!start_angle!+45

::How much to scale the map by.
set /a scale=10000
set /a scale_half=!scale!/2
set /a corner_thresh=!scale!/8
set /a width=45
set /a height=30

set column_dists=

::All possible screen columns, saved as horizontal strings
set d30=A···············▀··············B
set d29=A··············▄▀··············B
set d28=A·············▄##▀·············B
set d27=A·············▀##▄·············B
set d26=A············▄####▀············B
set d25=A············▀####▄············B
set d24=A···········▄######▀···········B
set d23=A···········▀######▄···········B
set d22=A··········▄########▀··········B
set d21=A··········▀########▄··········B
set d20=A·········▄##########▀·········B
set d19=A·········▀##########▄·········B
set d18=A········▄############▀········B
set d17=A········▀############▄········B
set d16=A·······▄##############▀·······B
set d15=A·······▀##############▄·······B
set d14=A······▄################▀······B
set d13=A······▀################▄······B
set d12=A·····▄##################▀·····B
set d11=A·····▀##################▄·····B
set d10=A····▄####################▀····B
set d9=A····▀####################▄····B
set d8=A···▄######################▀···B
set d7=A···▀######################▄···B
 set d6=A··▄########################▀··B
 set d5=A··▀########################▄··B
 set d4=A·▄##########################▀·B
 set d3=A·▀##########################▄·B
 set d2=A▄############################▀B
 set d1=A▀############################▄B
 set d1=A##############################B
 
::Loading bar
 <nul set /p"=Generating Coordinates . . . !CR!"

::Generate coordinates
for /l %%y in (1, 1, !height!) do (
	for /l %%x in (1, 1, !width!) do (
		set x%%xy%%y=·
		set column%%x=                                                                                         ·
	)
)

call :read_map
goto input

::Read map.txt
:read_map

	::Loading bar
	<nul set /p"=Reading map . . .                     !CR!"
	set /a y=-1
	set "File=%cd%\map.txt"
	set /a count=0
	
	::Read file line by line
	for /F "tokens=* delims=" %%a in ('Type "%File%"') do (
		Set /a count+=1
		Set "output[!count!]=%%a"
	)
	For /L %%i in (1,1,%Count%) Do (
		Call :Action "!output[%%i]!"
	)
	goto :eof
	
	::Read line character by character
	:Action
	set l=%1
	set l=%l:"=%
	set /a x=0
	set /a y=%y%+1
	SET strterm=X
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


::Print the map
:print_map
	set screen=
	
	::Iterate through the coordinates.
	for /l %%y in (0, 1, 10) do (
		for /l %%x in (0, 1, 10) do (
			set screen=!screen!!mapx%%xy%%y!
			
			::Refresh the FOV markers
			if "!mapx%%xy%%y!"=="#" (
				set mapx%%xy%%y=·
			)
			
		)
		set screen=!screen!;
	)
	
	::Print the map
	for %%f in (%screen%) do @echo                                         %%f
	goto :eof
	
::Print the screen from the x and y coordinate variables
:print_screen

::	Clear the loading bar's used characters in the screen buffer
	<nul set /p"=|                                                                                            !CR!"
	
	set screen=
::	Used to replace the filler whitespace with true whitespace
	set "temp_whitespace=·"
	set "real_whitespace= "
	
::	Iterate through screen coordinates
	for /l %%y in (1, 1, !height!) do (
		for /l %%x in (1, 1, !width!) do (
			set column=!column%%x!
			set pixel=!column%%x:~%%y,1!
			set screen=!screen!!pixel!!pixel!
		)
		::Print the screen row and replace the filler whitespace.
		echo: !screen:%temp_whitespace%=%real_whitespace%!
		set screen=

	)
	goto :eof
	
	
:input
	::Check if its the first startup
	if NOT "%first_start%"=="true" (
		call :print_screen
		echo.
		call :print_map
		set /p move=?^>
	) else (
		call :raycast cv
		call :raycast
		set first_start=false
		goto input
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

	::Detecting look commands
	set /a look_amt=0
	if NOT "%move:x=%"=="%move%" (
		set /a look_amt=!move:x=!
		set /a look_amt=!look_amt!*-1
		set /a start_angle=!start_angle!+!look_amt!
	)

	if NOT "%move:z=%"=="%move%" (
		set /a look_amt=%move:z=%
		set /a start_angle=!start_angle!+!look_amt!
	)
	
::	Keep movement within bounds
	if !look_amt! GTR 359 (
		echo OUT OF RANGE
		set /a start_angle=!start_angle!-!look_amt!
	)
	if !look_amt! LSS -359 (
		echo OUT OF RANGE
		set /a start_angle=!start_angle!-!look_amt!
		set /a look_amt=0
	)

::	Update where the player is
	set mapx!px!y!py!=P
	
::	Keep angle within bounds
	if !start_angle! LSS 0 (
		set /a start_angle=360+!start_angle!
	)
	if !start_angle! GTR 359 (
		set /a start_angle=!start_angle!-360
	)
	
::	Find the centor of FOV vector
	call :raycast cv
	
::	Raycast
	call :raycast

	goto input

::Does the actual raycasting.
:raycast
	
::	The ray vector's x and y components
	set /a vx=!px!*!scale!+!scale_half!
	set /a vy=!py!*!scale!+!scale_half!
	
::	The current vertical-column
	set /a screenx=0
	
::	Establish the current angle
	set /a angle=!start_angle!

::	Establish the temporary vector components
	set /a tvx=!vx!
	set /a tvy=!vy!

::	Reset the loading bar
	set loading_bar_amt=
	
::	Used for calculating center of FOV
	if "%1"=="cv" (
		set /a angle=!start_angle!-45
	)
	
::	Iterate through all 45 screen columns
	for /l %%y in (1, 1, 46) do (
		
		::Loading bar
		<nul set /p"=|                                                                                          |  !CR!"
		<nul set /p"=|!loading_bar_amt!!CR!"
		set loading_bar_amt=!loading_bar_amt!##
		
		::Move the next ray over by 2 degrees
		set /a angle=!angle!-2
		
		::Keep the angle within bounds
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

::		Establish movement directions based on the octant
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
			set /a oct_angle=45-!oct_angle!
			set /a oct_angle-=2
			if "!oct_angle!"=="0" (
				set /a oct_angle=1
			)
			
		) else (
			set /a oct_angle+=2
			if "!oct_angle!"=="0" (
				set /a oct_angle=1
			)
		)

::		Reset initial ray position
		set /a vx=!tvx!
		set /a vy=!tvy!
		
::		Find center of FOV vector
		if "%1"=="cv" (
		
::			The base vector for this ray, nx and ny
			if "!priority!"=="x" (
				set /a nx=!xdir!*!oct_angle!
				set /a ny=!ydir!*45
			) else (
				set /a ny=!ydir!*!oct_angle!
				set /a nx=!xdir!*45
			)
		
		
::			Prepare the radicand for the pythagorean calculation
			set /a tnx=!nx!/2
			set /a tny=!ny!/2
			set /a tnx=!tnx!*!tnx!
			set /a tny=!tny!*!tny!
			
::			Take the square root of the radicand. Babylonian Method used.
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
		)
		
		::Keep things within bounds
		if !oct_angle! LSS 1 (
			set /a oct_angle=1
		)
		if !oct_angle! GTR 45 (
			set /a oct_angle=45
		)
		
		::Keep track of the current column
		set /a screenx=!screenx!+1
		
		::Check/move the current ray.
		call :v_raycast
	)
	goto :eof
		:v_raycast
			
::			The coordinates to check for walls
			set /a checkx=!vx!/!scale!
			set /a checky=!vy!/!scale!
			
::			Calculations used for corner detection
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
			
			::Ensure the ray is within bounds.
			if "!vx!" LSS "-1" (
				echo Player X is out of bounds!
				pause
			)
			if "!vy!" LSS "-1" (
				echo Player Y is out of bounds!
				pause
			)
			
::			Check if the current cell is empty or not.
::			If it is, then draw that column to the screen.
			if "!mapx%checkx%y%checky%!"=="·" (
				set mapx%checkx%y%checky%=#
			) else if "!mapx%checkx%y%checky%!"=="P" (
				rem
			) else if "!mapx%checkx%y%checky%!"=="#" (
				rem
			) else (
				set walltype=!mapx%checkx%y%checky%!
				goto :draw_line
			)
		::	The base vector for this ray, hx and hy
			if "!priority!"=="x" (
				set /a hx=!xdir!*!oct_angle!
				set /a hy=!ydir!*45
			) else (
				set /a hy=!ydir!*!oct_angle!
				set /a hx=!xdir!*45
			)

		::	Determine distance to nearest edge of cell
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
			
		::	Find how many steps are needed to reach the edge of the cell
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
			if !mult_x! LSS !mult_y! (
				set /a move_amt=!mult_x!
			) else (
				set /a move_amt=!mult_y!
			)
			set /a mult_x=!move_amt!*!hx!
			set /a mult_y=!move_amt!*!hy!
			
		::	Move the ray to the edge of the cell
			set /a vx=!vx!+!mult_x!
			set /a vy=!vy!+!mult_y!
			
			goto :v_raycast
	
	
:draw_line
	
::	The player's scaled x and y coordinates.
	set /a tpx=!px!*!scale!+!scale_half!
	set /a tpy=!py!*!scale!+!scale_half!
	
::	The distance between the ray's collision point and the player
	set /a vx=!vx!-!tpx!
	set /a vy=!vy!-!tpy!

::	Ensure all terms are positive.
	if !vx! LSS 0 (
		set /a vx=!vx!*-1
	)
	if !vy! LSS 0 (
		set /a vy=!vy!*-1
	)
	
::	Calculate the dot product of center of FOV vector and the raycasted vector
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
	
::	Divide the dot product by the length of the center of FOV vector
	set /a d=!dot!/!n_distance!
	
::	Calculate the final unscaled distance value.
	set /a h=!height!
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
		set view=!view:█▄=██!
		set view=!view:▀█=██!
	)
	
	set column!screenx!=!view!
	goto :eof