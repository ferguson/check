The challenge
=============

Use your favorite in-browser, plugin-free* approach to visualize a solution for the following problem:

Consider a checkerboard of unknown size. On each square is an arrow that randomly points either up, down, left, or right. A checker is placed on a random square. Each turn the checker moves one square in the direction of the arrow. Create an algorithm that determines if the checker moves off the edge of the board.

The solution should
 - Use HTML5/CSS3/Javascript
 - Only needs to work in Chrome
 - Visualize the solution in-browser
 - Include simple UI to start/stop/advance/reset the visualization
 - Use a package manager to manage dependencies
 - Use a scriptable build system (if there are build/run steps)
 - Use gitHub to deliver the solution
 - Bonus: Use WebAudio to enhance the visualization


Our favorite solutions have used very current Javascript techniques.  We like to see good modularity using requireJS - to organize code into "classes".  We also like to see good MVC. Visual design isn't as important, but doesn't hurt. We love npm, gulp, bower.  Super extra bonus points for browserify, minify, uglify, watch, and local Web server (via gulp).


FAQ
---

1. Does "plugin-free" mean not using any external library? If so, why is a package manager needed to manage dependencies if there isn't any? Or does it refer to development dependencies, e.g. CSS preprocessor? 

This just means no Flash, Unity, or Applets. Use whatever libraries and package management you want.

2. Regarding the unknown size of the checker board: is it supposed to be a random number? Or is it in a parameter that the user can specify in the UI?

It would be great if you could initialize the board's size through the UI

4. Would you mind if I write it in ES6? I'll include a compiled, runnable version.

That would be great! Double bonus points!
