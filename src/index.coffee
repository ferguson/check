### jshint eqnull: true, eqeqeq: false, -W030 ###

# if you put "#2d" on the end of the url (http://localhost:8000/#2d)
# you can see my first (abandoned) visualization attempt
# (you may need to reload the url twice, because that's how location.hash works)

if /2d/.test location.hash
  main = require './main2d'
else
  main = require './main3d'

if window?
  window.onload = ->
    main()
