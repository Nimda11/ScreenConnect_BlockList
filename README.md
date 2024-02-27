# ScreenConnect_BlockList
Queries ScreenConnects Security.db SQLite database and compiles a list of ip addresses you can block
This is quick and dirty, and meets my needs. I hope it helps someone else.

This script ONLY creates a list of IP Addresses, it does not do any sort of blocking on its own. I use it to update an azure network security group.
It does not what user source generated the invalid login, meaning it will block login attempts from SAML, LDAP, or Internal.

#Prerequisites
sqlite3 for querying the database: https://www.sqlite.org/download.html
-- save somewhere with PATH (or append add a new PATH)
Powershell Core 7
-- in theory this is crossplatform
-- no additional modules required
write access to a directory to save the blocklist

#usage
the script creates a list of IP addresses, one on each line.
the script can read an allowlist of ip addresses, one on each line

scriptname.ps1 -DatabasePath <Security.db path> -BlockListPath <where should the blocklist be saved> -AllowListPath <path to allow list> -QueryDays <number of days to query the log> -BanAttempts <how many attempts before an ip is added to the blocklist>
