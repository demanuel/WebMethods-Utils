WebMethods-Utils
================

Some utils for webMethods platform that developers and admins (of the webmethods platform) may find interesting:

* purge logs:
This is not a webmethods related but more a generic administration one. This script will compress all the log 
files that aren't being used. This will avoid the loosing of log information (for example, if you "touch" a file
that's being used for logging using log4j, that file will stop being updated.).

* find dependents:

When using the findDependents you'll get all the dependents even if they're disabled and not being used. With this
script you can search for the disabled ones or only for the enabled ones. The next step will be to translate this
script to flow (or at least to a java service). 

Requirements: perl (tested with perl 5.08)

More info: perl findDependents.pl --help

License
=======
All scripts indicated here are licensed under GPLv3 unless otherwise specified.


Contact
=======

Available by e-mail: David Santiago at <demanuel@ymail.com>