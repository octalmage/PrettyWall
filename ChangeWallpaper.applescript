set desktopImage to choose file
tell application "Finder"
	set desktop picture to desktopImage
end tell


tell application "Finder"
	tell application "System Events"
		set picture of every desktop to desktopImage
	end tell
end tell