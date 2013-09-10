WebMethods-Utils
================

Some utils for webMethods platform that developers and admins (of the webmethods platform) may find interesting:

* find dependents:

When using the findDependents you'll get all the dependents even if they're disabled and not being used. With this
script you can search for the disabled ones or only for the enabled ones. The next step will be to translate this
script to flow (or at least to a java service)


To install these bash functions just add to your .bashrc the following lines:

> for file in /path/to/the/folder/where/you/put/the/files/*.sh

> do

>     . $file

> done 
>

You'll have to logout and login. Now everytime you put a script in that "bin"
folder the scripts will be fired up when you login making all the functions they export available
