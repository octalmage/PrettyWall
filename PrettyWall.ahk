#NoEnv
#Include Gdip.ahk
#SingleInstance force
#Persistent
#WinActivateForce

SysGet, MonMain, MonitorWorkArea, 1

SendMode Input
SetWorkingDir %A_ScriptDir%


ProgramName=PrettyWall
Version=0.1
Url=http://code.google.com/p/prettywall
IniFile=pw.ini


If not fileexist(IniFile)
		gosub iniwrite


Menu, tray, NoStandard
Menu, tray, icon, icon.ico
Menu, tray, Tip , %ProgramName%
Menu, tray, add, Refresh, refresh
Menu, tray, add ; separator
Menu, tray, add, About, about
Menu, tray, add, Settings, settings
Menu, tray, add ; separator
Menu, tray,add,Exit,cleanup
gosub iniread
min:=60000
updatetime:=min*updatemins
SetTimer,update, %updatetime%
Gosub, update

Return

refresh:
old=
update:
	download=http://prettycolors.tumblr.com/rss?%A_TickCount%
	URLDownloadToFile, %download%, pc.xml
	FileSetAttrib, +h , pc.xmls
	FileRead, data, pc.xml
	FileDelete, pc.xml
	org:=data
	StringReplace, data, data, &lt;img src=" , ``
	StringSplit, data, data , ``
	data:=data2
	StringReplace, data, data, "/&gt; , ``
	StringSplit, data, data , ``
	wallpaper:=data1
	URLDownloadToFile, %data1%, wall.png
	FileSetAttrib, +h , wall.png
	data:=org
	StringReplace, data, data, &gt;# , ``
	StringSplit, data, data , ``
	data:=data2
	StringReplace, data, data, &lt; , ``
	StringSplit, data, data , ``
	colorcode:=data1

	If colorcode=%old%
		{
			filedelete, wall.png
			Return
		}
	old:=colorcode
	If !pToken := Gdip_Startup()
		{
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. Please ensure you have gdiplus on your system
			ExitApp
		}

	wallfile := Gdip_CreateBitmapFromFile("wall.png")
	Gdip_SaveBitmapToFile(wallfile, "color.bmp")
	FileSetAttrib, +h , color.bmp

	Gdip_DisposeImage(wallfile)

	FileDelete, wall.png
	Gdip_Shutdown(pToken)

	SetWallpaperStyle("Tiled")
	SetWallpaper("color.bmp")
	FileDelete, color.bmp

	If showcolor
			displaycolor(colorcode)
Return
#If A_IsCompiled=0
#r::
	Reload

	displaycolor(color)
	{
		global 
		
		hexcolor=0x%color%
		comcolor:=complementaryC(hexcolor)
		gui, destroy
		Gui,color,2B2D2A
		Gui, -caption +toolwindow
		Gui, +lastfound +alwaysontop
		Gui, font,s48 c%comcolor%,  Lucida Console
		Gui, add, text,x10 y240 , %color%
		Gui,show, Hide autosize h200 ,colorcode
		SetFormat, Integer, D
		DetectHiddenWindows, on
		WinSet, TransColor, 2B2D2A, colorcode
		WinGetPos , , , Width, , colorcode
		
SysGet, Mon, MonitorWorkArea 

		win_x:=MonRight-Width+60
		win_y:=MonBottom-200
		gui, +lastfound
		Gui,show, h200 x%win_x% y%win_y%,colorcode
		cid:=winexist()
		OnMessage(0x201, "WM_LBUTTONDOWN")
		ControlGetPos , tx, ty,, , Static1, colorcode
		Loop 40
			{
				ty-=(40-A_index)/8
				GuiControl, move, Static1 , y%ty%
				Sleep 20
			}
		sleeptime:=1000*colorcodeseconds
		Sleep %sleeptime%
		Loop 10
			{
				ty-=(10-A_index)
				GuiControl, move, Static1 , y%ty%
				Sleep 30
			}

		Loop 30
		
			{
				ty+=A_index/2
				GuiControl, move, Static1 , y%ty%
				Sleep 20
			}
		Gui,destroy
		if clicked=1
		{
			wingetactivetitle, atitle
			if atitle=Program Manager
				returnwins()
		}
		clicked=0
		Return
	}

	

WM_LBUTTONDOWN(wParam, lParam)
{
	global
	
	
	if not a_gui=1
		return
	if not clicked
	{
		send #m
		winactivate, ahk_id %cid%
		 ;Control, Hide,, SysListView321, ahk_class Progman
	;	WinHide ahk_class Shell_TrayWnd
		clicked=1
	}
	else
	{
		returnwins()
		clicked=0

	}
	
	
	
}

returnwins()
{
global
		send #+m
		; Control, Show,, SysListView321, ahk_class Progman
		; Winshow ahk_class Shell_TrayWnd
return
}

complementaryC(RGB)
	{
		SetFormat, Integer, hex
		r := (RGB & 0xFF0000) >> 16
		g := (RGB & 0x00FF00) >> 8
		b := RGB & 0x0000FF
		h := ((r > b) && (r > g)) ? r : ((g > b) && ( g > r)) ? g : b
		l := ((r < b) && (r < g)) ? r : ((g < b) && ( g < r)) ? g : b
		s := h + l
		nr := s - r
		ng := s - g
		nb := s - b
		nrgb := (nr << 16) + (ng << 8) + nb
		Return nrgb
	}

iniread:
	IniRead, showcolor, %inifile%,Settings,showcolor
	IniRead, startup, %inifile%,Settings,startup
	IniRead, updatemins, %inifile%,Settings,updatemins
	IniRead, colorcodeseconds, %inifile%,Settings,colorcodeseconds
	;iniread, wininfo, %inifile%,Settings,wininfo
Return

iniwrite:
	If not fileexist(inifile)
		{
			IniWrite, 1, %inifile%, Settings, showcolor
			IniWrite, 0, %inifile%, Settings, startup
			IniWrite, 5, %inifile%, Settings, updatemins
			IniWrite, 8, %inifile%, Settings, colorcodeseconds
			FileSetAttrib, +h , %inifile%
		}
	Else
		{
			IniWrite, %showcolor%, %inifile%, Settings, showcolor
			IniWrite, %startup%, %inifile%, Settings, startup
		}
	;IniWrite, 1, %inifile%, Settings, wininfo
Return

settings:
	Gui 66: Default
	gui,add,checkbox, vshowcolor Checked%showcolor%,Show color code?
	gui,add,checkbox, vstartup Checked%startup%,Run at startup?
	Gui,add,button,gsave,Save
	Gui,show,,Settings
	Gui 1: Default
Return

save:
	Gui 66: Default
	Gui,submit
	Gui,destroy
	Gui 1: Default
	If startup=1
			RegWrite, REG_SZ,HKCU,Software\Microsoft\Windows\CurrentVersion\Run,PrettyWall, "%A_ScriptFullPath%"
	Else
			RegDelete, HKCU,Software\Microsoft\Windows\CurrentVersion\Run,PrettyWall
	Gosub iniwrite
Return

about:
	MsgBox %programname% v%version%`nBy: Jason Stallings`n%url%
Return

cleanup:
	ExitApp


	SetWallpaper(BMPpath)
	{
		SPI_SETDESKWALLPAPER := 20
		SPIF_SendWININICHANGE := 2
		Return DllCall("SystemParametersInfo", UINT, SPI_SETDESKWALLPAPER, UINT, uiParam, STR, BMPpath, UINT, SPIF_SendWININICHANGE)
	}



SetWallpaperStyle(style)
	{
		;for tiled,    use TileWallpaper=1 WallpaperStyle=0
		;for centered, use TileWallpaper=0 WallpaperStyle=0
		;for strech,   use TileWallpaper=0 WallpaperStyle=2
		If style=Tiled
			{
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, TileWallpaper, 1
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, WallpaperStyle, 0
			}
		Else If style=Centered
			{
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, TileWallpaper, 0
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, WallpaperStyle, 0
			}
		Else If style=Streched
			{
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, TileWallpaper, 0
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, WallpaperStyle, 2
			}
	}
