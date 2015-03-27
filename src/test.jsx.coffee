### jshint eqnull: true, eqeqeq: false, -W030 ###

# @cjsx React.DOM

React = require 'react'

MainPage = React.createClass
  render: ->
    `<div className="MainPage">
      <h1>Hello, anonymous!</h1>
      <p><a href="/users/doe">Login</a></p>
    </div>`


NotFoundHandler = React.createClass
  render: -> `<p>Page not found!</p>`

App = React.createClass
  render: ->
    `<html>
      <head>
        <link rel="stylesheet" href="/assets/style.css" />
        <script src="/assets/bundle.js" />
      </head>
    </html>`

if typeof window isnt "undefined"
  window.onload = ->
    React.renderComponent App(), document
