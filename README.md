#mk\_blog.pl#
This is a project I'm using to familiarise myself with perl. It's an *extremely*
minimal static blog generator that renders markdown documents and places my last
five posts onto a landing page.

Developed on and designed for OpenBSD. If you find it useful that's great.

##Dependencies##
Currently depends on the following perl modules:
* [Template](http://search.cpan.org/~abw/Template-Toolkit-2.26/lib/Template.pm)
* [HTML::TokeParser](http://search.cpan.org/~gaas/HTML-Parser-3.72/lib/HTML/TokeParser.pm)
* [Text::Markdown](http://search.cpan.org/~bobtfish/Text-Markdown-1.000031/lib/Text/Markdown.pm)

And the makefile requires a BSD make, most Linux distributions package the NetBSD make as ```bmake```.
In the examples below you may need to substitue ```bmake``` for ```make```.

##Installation##

    $ make install

By default the Makefile installs everything under ```/usr/local```. 
You can change this by setting the ```PREFIX```, ```BINDIR``` and ```DATADIR``` environment variables: 

    $ #Linux style (Everything under /usr)
    $ export PREFIX=/usr
    $ make install
    $ #Or something more custom
    $ make install BINDIR=$HOME/bin $DATADIR=~/.local/share
    $ make install PREFIX=/opt/mk_blog
    
##Deinstallation##

    $ make deinstall
    
If you set custom installation directories earlier you'll have to ensure they're still set for deinstallation to succeed.

##Usage##
This script can be used pretty easily with an existing website:
    
    $ mkdir -p ~/www/staging
    $ rsync -av /var/www/htdocs/ ~/www/staging/
    $ mk_blog.pl ./post.md ~/www/staging/ /usr/local/share/templates/
    $ #Check that you're happy with the results before proceeding
    $ rsync -av ~/www/staging/ /var/www/htdocs/

There are no themes supplied for this script, the templates look for css in a directory called ```static```.
E.g. in the above example css would go in ```~/www/staging/static/style.css```.

The templates are almost plain html and you should be able to edit them with a reasonable degree of abandon.

##Limitations##
Currently ```mk_blog.pl``` expects your markdown documents to begin with a level-two heading followed by a paragraph. Just the way I wanted it to work, no real reason for it otherwise.
