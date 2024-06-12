local authorName = 'CHANGEME'   -- Your author name
local resourceName = 'CHANGEME' -- The name of your FiveM resource
local fullName = '^3[' .. authorName .. '-' .. resourceName .. '] '

-- Github info to check the version
local githubUsername = 'CHANGEME'        -- Your GitHub username
local githubRepo = 'CHANGEME'            -- Your GitHub repository name
local githubVersionFilename = 'CHANGEME' -- The filename on GitHub containing the version information

local function printVersion(cur, late, status)
    print(fullName .. '^4Checking for update...')
    print(fullName .. '^4' .. cur)
    print(fullName .. '^4' .. late)
    print(fullName .. status)
end

local function versionToNumber(version)
    local major, minor, patch = version:match("(%d+)%.?(%d*)%.?(%d*)")
    major = tonumber(major) or 0
    minor = tonumber(minor) or 0
    patch = tonumber(patch) or 0
    return major * 10000 + minor * 100 + patch
end

local function checkVersion()
    local cur = ''
    local late = ''
    local status = ''

    local current = GetResourceMetadata(GetCurrentResourceName(), "version", 0);
    cur = "Current version: " .. current

    PerformHttpRequest(
        'https://raw.githubusercontent.com/' .. githubUsername .. '/' ..
        githubRepo .. '/main/' .. githubVersionFilename,
        function(Error, Version, Header)
            if Error ~= 200 then
                printVersion(cur, 'Latest version: ^1Failed to fetch',
                    '^1' .. Error)
                return
            end

            late = "Latest version: " .. Version

            local currentVersionNumber = versionToNumber(current)
            local newToCheckNumber = versionToNumber(Version)

            if newToCheckNumber < currentVersionNumber then
                status = "^1" .. resourceName .. " version is from the future!"
            elseif newToCheckNumber < currentVersionNumber then
                status = "^1" .. resourceName .. " version is outdated. Please update."
            elseif newToCheckNumber == currentVersionNumber then
                status = "^2" .. resourceName .. " is up to date!"
            else
                status = "^1Error parsing version. Ensure format is (1.0.0), (1.0), or (1)."
            end

            printVersion(cur, late, status)
        end)
end

if Config.checkForUpdate then
    checkVersion()
end
