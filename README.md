## ScreenConnect_BlockList
Queries ScreenConnects Security.db SQLite database and compiles a list of IPv4 addresses you can block
This is quick and dirty, and meets my needs. I hope it helps someone else.

This script ONLY creates a list of IP addresses, it does not do any sort of blocking on its own. I use it to update an azure network security group.
It does not what user source generated the invalid login, meaning it will block login attempts from SAML, LDAP, or Internal.

## Prerequisites
sqlite3 for querying the database: [link](https://www.sqlite.org/download.html "https://www.sqlite.org/download.html")\
* save somewhere with PATH (or append add a new PATH)\

Powershell Core 7
* in theory this is crossplatform
* no additional modules required
* write access to a directory to save the blocklist

## Usage
the script creates a blocklist of IPv4 addresses, one on each line.\
the script can read an allowlist of IPv4 addresses, one on each line.

scriptname.ps1 -DatabasePath <Security.db path> -BlockListPath <where should the blocklist be saved> -AllowListPath <path to allow list> -QueryDays <number of days to query the log> -BanAttempts <how many attempts before an ip is added to the blocklist>

example
```powershell
CreateBlockList.ps1 -databasepath C:\CWC\App_Data\Security.db -blocklistpath "c:\lists\blocklist.txt" -allowlistpath "c:\lists\allowlist.txt" -QueryDays 365 -BanAttempts 30
```
parameters

DatabasePath - the path to your Security.db file\
AllowListPath - The path to a list of ipv4\
QueryDays - The number of days before run time to pull results. **Default is 28**\
BanAttempts - how many failed login attempts within the QueryDays parameter should get an IP address banned? **Default is 10**\
BlockListPath - the path where the script will write the resultant list.\
EnableDebug - Writes a bunch of diagnostic info to a text file in the same directoy the script is run from.
