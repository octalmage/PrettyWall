var app = require("app");
var Menu = require("menu");
var Tray = require("tray");
var http = require("http");
var fs = require("fs");
var tumblr = require("tumblr.js");
var v8 = require("v8");

//The wallpaper module uses arrow functions.
v8.setFlagsFromString("--harmony-arrow-functions");
var wallpaper = require("wallpaper");

//Report crashes to the Electron team.
require("crash-reporter").start();

//Load consumer_key from config.json.
var config = JSON.parse(fs.readFileSync("config.json", "utf8"));

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

app.on("ready", function()
{
	setInterval(function()
	{
		updateWallpaper();
	}, 600000);

	updateWallpaper();

	appIcon = new Tray("tray.png");

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
});

function updateWallpaper()
{
	client.posts("prettycolors.tumblr.com", function(error, data)
	{
		download(data.posts[0].photos[0].original_size.url, function()
		{
			wallpaper.set(".temp.png").then(function()
			{
				fs.unlink(".temp.png");
				console.log("Wallpaper Updated.");
			});
		});
	});
}

function download(url, callback)
{
	var file = fs.createWriteStream(".temp.png");
	var request = http.get(url, function(response)
	{
		response.pipe(file);
		callback();
	});
}