var app = require("app");
var Menu = require("menu");
var Tray = require("tray");
var http = require("http");
var fs = require("fs");
var path = require("path");
var tumblr = require("tumblr.js");
var v8 = require("v8");

//The wallpaper module uses arrow functions.
v8.setFlagsFromString("--harmony-arrow-functions");
var wallpaper = require("wallpaper");

//Report crashes to the Electron team.
require("crash-reporter").start();

//Load consumer_key from config.json.
var config = JSON.parse(fs.readFileSync(__dirname + "/config.json", "utf8"));

var client = new tumblr.Client(
{
	consumer_key: config.consumer_key
});

//Hide dock icon on Mac.
if (process.platform === "darwin")
{
    app.dock.hide();
}

var mainWindow = null;

var appIcon = null;

var fileName;

app.on("ready", function()
{
	//Update wallpaper every 10 minutes.
	setInterval(function()
	{
		updateWallpaper();
	}, 600000);

	updateWallpaper();

	appIcon = new Tray(__dirname + "/tray.png");

	var contextMenu = Menu.buildFromTemplate([

		{
			label: "PrettyWall",
			type: "normal"
		},
        {
            type: "separator"
        },
		{
			label: "Quit",
			accelerator: "Command+Q",
			click: function()
			{
				app.quit();
			}
		}
	]);
	appIcon.setToolTip("PrettyWall");
	appIcon.setContextMenu(contextMenu);
	
	//Support right clicking the tray icon.
	appIcon.on("right-clicked", function(event, bounds)
	{
		appIcon.popUpContextMenu();
	});
});

/**
 * Get the latest color from prettycolors and pass it to the download function.
 */
function updateWallpaper()
{
	client.posts("prettycolors.tumblr.com", function(error, data)
	{
		if (error)
		{
			console.log(error);
			return;
		}
		
		//TODO: Only download/update if the color has changed.
		download(data.posts[0].photos[0].original_size.url, function()
		{
			wallpaper.set(fileName).then(function()
			{
				console.log("Wallpaper Updated.");
			});
		});
	});
}

function download(url, callback)
{
	//Try to delete previously downloaded file.
	if (fileName)
	{
		try 
		{
			fs.unlink(fileName);
		}
		catch (error)
		{
			console.log(error);
		}
	}
	
	var baseName = path.basename(url);
	fileName = __dirname + "/" + baseName;
	var file = fs.createWriteStream(fileName);
	var request = http.get(url, function(response)
	{
		response.pipe(file);
		callback();
	});
}