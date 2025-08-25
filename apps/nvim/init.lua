--- Central configuration ---

-- Variable localization
local vim = vim

-- Load plugins
require("plugins")

-- Load modules
require("settings")
require("remaps")
require("commands")
require("autocommands")
require("before")
require("markdown")
-- require("notesync") -- Disabled after the switch to Seafile for note syncing.
require("matheval")


