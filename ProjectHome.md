# rdqcutils #

This is the plugin in which I will continue to package my miscellaneous custom patches for Quartz Composer.  Currently, it includes Swap Numbers, CSV Importer, Text File Importer, Counter Plus, and Scale Number.  CSV Importer uses Dave DeLong's excellent CHCSVParser library.

| _**Note:** I've changed the name of the plugin slightly (added underscores and removed the version number from the plugin filename).  If you have an older version (before 1.2) you'll need to remove the old one before installing this new version.  That won't be the case in the future._ |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

## Description ##

  * **Swap Numbers** - Swap two numbers, or not.

  * **Scale Number** - Scale a number up or down, from one min-max range to another.  The patch settings determine the behavior when the original number is outside the specified original min-max range.  The Range patch can also be a handy partner.

  * **CSV Importer** - Imports a CSV (comma-delimited) text file from a URL and outputs a structure of structures, containing rows of fields.  Local files can be imported by specifying a `file://` URL  (Remember that an absolute path will have 3 slashes at its start eg: `file:///Users/bill/delimited.txt`) The import occurs every time the Update Signal input goes from LOW to HIGH.

  * **Text File Importer** - Imports a plain text file from a URL and outputs a structure containing one member per line.  Local files can be imported by specifying a `file://` URL  (Remember that an absolute path will have 3 slashes at its start eg: `file:///Users/bill/plain.txt`).  The structure's numerical indices are not necessarily in order. To retrieve the lines in order, use the structure keys and not the indices.  The import occurs every time the Update Signal input goes from LOW to HIGH.

  * **Counter Plus** - Like the normal counter, but allows for optionally decrementing below zero.  You can also specify a starting number and an amount by which to increment or decrement.

  * **XY Distance** - Calculates the distance between two sets of Cartesian (X and Y) coordinates. Works with pixels or units.

## Issues ##

Please feel free to add to the Issues tab anything regarding the functionality of the patches _OR the code_ - I am new to Objective C so I'm happy to have your   suggestions.

I have only tested this plugin with Snow Leopard 10.6.4, Quartz Composer 4.0.  Let me know if you try it in another configuration.  (Update: I just compiled a Leopard version for a project I'm working on - it's available as a deprecated version on the Downloads page. I still haven't tried this on Lion yet.)

## Installation ##

Install rdqcutils by unzipping the file and dropping the resulting plugin into your **~/Library/Graphics/Quartz Composer Plug-Ins** folder (where ~ is your Home directory).  Create that folder if it doesn't already exist.  The patches should now show up under Plugins in Quartz Composer's Library window.

If you already have an older (pre-1.2) version of the plugin, please see the note at the top of the page about upgrading.

## Screenshot ##

![http://rdqcutils.googlecode.com/files/rd_qc_utils-screenshot-1.3.png](http://rdqcutils.googlecode.com/files/rd_qc_utils-screenshot-1.3.png)

