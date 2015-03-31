Check
=====

Home page <https://github.com/ferguson/check>

> Version 0.1.0 - 2015.03.30 - initial release

The Challenge
-------------

Use your favorite in-browser, plugin-free* approach to visualize a
solution for the following problem:

Consider a checkerboard of unknown size. On each square is an arrow
that randomly points either up, down, left, or right. A checker is
placed on a random square. Each turn the checker moves one square in
the direction of the arrow. Create an algorithm that determines if the
checker moves off the edge of the board.

The solution should
 - Use HTML5/CSS3/Javascript
 - Only needs to work in Chrome
 - Visualize the solution in-browser
 - Include simple UI to start/stop/advance/reset the visualization
 - Use a package manager to manage dependencies
 - Use a scriptable build system (if there are build/run steps)
 - Use gitHub to deliver the solution
 - Bonus: Use WebAudio to enhance the visualization


Our favorite solutions have used very current Javascript techniques.
We like to see good modularity using requireJS - to organize code into
"classes".  We also like to see good MVC. Visual design isn't as
important, but doesn't hurt. We love npm, gulp, bower.  Super extra
bonus points for browserify, minify, uglify, watch, and local Web
server (via gulp).

Challenge FAQ
-------------

 - Does "plugin-free" mean not using any external library? If so, why
   is a package manager needed to manage dependencies if there isn't
   any? Or does it refer to development dependencies, e.g. CSS
   preprocessor?

   This just means no Flash, Unity, or Applets. Use
   whatever libraries and package management you want.

 - Regarding the unknown size of the checker board: is it supposed to
   be a random number? Or is it in a parameter that the user can
   specify in the UI?

   It would be great if you could initialize the board's size through the UI

 - Would you mind if I write it in ES6? I'll include a compiled,
   runnable version.

   That would be great! Double bonus points!

Installation
============

Requirements: git and the standard system dev tools

This package uses node, but it will download and install a local copy
directly in the package itself. No need to have node preinstalled.

Clone a copy of Check:

    $ cd ~
    $ git clone git@github.com:ferguson/check.git

Run the setup script:

    $ cd check
    $ ./setup

This will download and install a local copy of node and npm. Then the
needed npm modules will be installed. Finally, gulp will be used to
build the package.

Operation
=========

To run Check:

    $ cd ~/check
    $ . activate
    $ gulp webserver

This should launch a browser window on your machine pointing to the
webserver. If the browser window fails to open automatically, just
open a browser page and point it at http://localhost:8000/.

Hopefully the UI is self explanatory (assuming you have read The
Challenge above).

Press Contrl-C to quit the webserver.

Uninstalling
============

Just delete the directory that Check was cloned into. Everything it
depends upon, including it's local node installation, is contained in
that directory.

Notes
=====

You can see my abandoned first visualization by appending #2d to the
end of the URL: <http://localhost:8000/#2d>.

You might need to edit the URL twice to get it to load (that's the
special nature of # parameters in URLs).

Know Issues
===========

The play field does not resize when the browser window is resized.

Not very mobile friendly. If you want to try it, uncomment the host:
'0.0.0.0' line in the gulpfile before running the webserver.

There are a number of other bugs and issues noted in the TODO file.

------------------------------------------------------------
