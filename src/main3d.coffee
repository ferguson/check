##
## visualization using React and three.js
##

### jshint eqnull: true, eqeqeq: false, -W030 ###

# 5 quick tips for reading CoffeeScript:
#   indenting automatically adds braces
#     obj =
#       prop1: 1, prop2: 'two'
#     is obj = { prop1: 1, prop2: 'two' }
#   -> is a function call (and => is a function call but binds 'this')
#     (x, y) -> is function(x, y), -> alone is just function() {}
#   @ is just an alias for 'this'
#     read @prop as this.prop
#   a space after a token causes a function call
#     console.log 'hi' is console.log('hi')
#   "#{value}" is just string interpolation
#     "The value is #{val}." is 'The value is' + val + '.'
#   And one bonus tip for the embedded JSX:
#     code in backticks (`) is just passed through unmodified
# And remember kids, CoffeeScript is just JavaScript!
# http://coffeescript.org/

_ = require 'lodash'
React = require 'react'
THREE = require 'three'

restore = React.createClass  # undo React.createClass monkeypatching!
ReactTHREE = require 'react-three'
React.createClass = restore  # dammit! that was very painful to find

BoardLogic = require './BoardLogic'
PieceLogic = require './PieceLogic'

# aliases so you don't have to write <ReactTHREE.Scene> etc. in JSX
Scene = ReactTHREE.Scene
Mesh = ReactTHREE.Mesh
Object3D = ReactTHREE.Object3D
PerspectiveCamera = ReactTHREE.PerspectiveCamera

isOdd = (n) -> n % 2 is 1
timeoutSet = (f, m) -> setTimeout(m, f)  # much more coffescript friendly


# an experiment: three.js doesn't use CSS, but CSS is where all our other colors are
# so let's try to get color values from CSS instead of hard coding them elsewhere
# limitations:
#  - the selectorText must be exact
#  - the color might be required to be #XXXXXX or rgb(N, N, N) (e.g. blue or #CCC might not work)
getColorFromCSS = (selectorText, propertyName='color') ->
  value = getStyleSheetPropertyValue selectorText, propertyName
  if value
    return parseColorValue value
  else
    return 0x000000


# from http://stackoverflow.com/questions/2707790
getStyleSheetPropertyValue = (selectorText, propertyName) ->
  # search backwards because the last match is more likely the right one
  for s in [document.styleSheets.length-1..0] by -1
    cssRules = document.styleSheets[s].cssRules or
      document.styleSheets[s].rules or []  # IE support
    for rule in cssRules
      if rule.selectorText is selectorText
        return rule.style[propertyName]
  return null


# from http://haacked.com/archive/2009/12/29/convert-rgb-to-hex.aspx/
colorToHex = (color) ->
  if not color? or color.substr(0, 1) is '#'
    return color
  digits = /(.*?)rgb\((\d+), (\d+), (\d+)\)/.exec color
  red   = parseInt digits[2]
  green = parseInt digits[3]
  blue  = parseInt digits[4]
  rgb = blue | (green << 8) | (red << 16)
  return digits[1] + '#' + rgb.toString(16)


parseColorValue = (value) ->
  value = colorToHex value
  value = value.slice(1) if value? and value[0] is '#'
  value = parseInt(value, 16)
  return value


# Square - React-THREE single square on the game board
Square = React.createClass
  displayName: 'Square'

  propTypes:
    position: React.PropTypes.instanceOf(THREE.Vector3)
    quaternion: React.PropTypes.instanceOf(THREE.Quaternion)
    dark: React.PropTypes.any

  getDefaultProps: ->
    position: new THREE.Vector3(0,0,0)
    quaternion: new THREE.Quaternion()
    dark: false

  getInitialState: do ->
    # items we only need one of across all objects created here
    # and stored in 'singleton'
    singleton = {}

    singleton.geometry   = new THREE.BoxGeometry( 200,20,200 )
    singleton.colorLight = new THREE.MeshBasicMaterial color: getColorFromCSS '.SquareLight'
    singleton.colorDark  = new THREE.MeshBasicMaterial color: getColorFromCSS '.SquareDark'

    return ->
      # this is the function that is called for each object's state on object creation
      state = _.clone singleton  # copy in the static values from the singleton
      # add any additional per object values to state here
      return state

  render: ->
    material = if @props.dark then @state.colorDark else @state.colorLight
    `<Object3D quaternion={this.props.quaternion} position={this.props.position}>
      <Mesh geometry={this.state.geometry} material={material} />
    </Object3D>`


# Arrow - React-THREE directional arrows
Arrow = React.createClass
  displayName: 'Arrow'

  propTypes:
    position: React.PropTypes.instanceOf(THREE.Vector3)

  getDefaultProps: ->
    position: new THREE.Vector3(0,0,0)
    quaternion: false
    dark: false

  getInitialState: do ->
    # items we only need one of across all objects created here
    # and stored in 'singleton'
    singleton = {}

    singleton.extrudeSettings =
      amount: 20
      #bevelEnabled: true
      bevelEnabled: false
      bevelSegments: 2  # 5
      steps: 2
      #bevelSize: 8
      #bevelThickness:5
      material: 0
      extrudeMaterial: 1

    shape = new THREE.Shape()
    shape.moveTo(  0, -70 )  # tip
    shape.lineTo(-40, -10 )
    shape.lineTo(-20, -10 )  # shoulder
    shape.lineTo(-20,  70 )  # shaft
    shape.lineTo( 20,  70 )  # shaft
    shape.lineTo( 20, -10 )  # shoulder
    shape.lineTo( 40, -10 )
    shape.lineTo(  0, -70 )  # close path
    singleton.geometry = shape.extrude( singleton.extrudeSettings )

    singleton.lightColor        = new THREE.MeshBasicMaterial color: getColorFromCSS '.ArrowLight'
    singleton.lightSideColor    = new THREE.MeshBasicMaterial color: getColorFromCSS '.ArrowLightSide'
    singleton.darkColor         = new THREE.MeshBasicMaterial color: getColorFromCSS '.ArrowDark'
    singleton.darkSideColor     = new THREE.MeshBasicMaterial color: getColorFromCSS '.ArrowDarkSide'
    singleton.lightMeshMaterial = new THREE.MeshFaceMaterial [singleton.lightColor, singleton.lightSideColor]
    singleton.darkMeshMaterial  = new THREE.MeshFaceMaterial [singleton.darkColor,  singleton.darkSideColor]

    return ->
      # this is the function that is called for each object's state on object creation
      state = _.clone singleton  # copy in the static values from the singleton
      # add any additional per object values to state here
      return state


  render: ->
    if not @props.quaternion
      rotationFactor = 0
      switch @props.direction
        when 'U',0 then rotationFactor = 0
        when 'D',1 then rotationFactor = 2
        when 'L',2 then rotationFactor = 3
        when 'R',3 then rotationFactor = 1

      deg90 = (Math.PI/2)  # 90 degrees in radians
      @props.quaternion = new THREE.Quaternion()
          .setFromEuler( new THREE.Euler(deg90, 0, deg90*rotationFactor), 'XYZ')
    material = if @props.dark then @state.darkMeshMaterial else @state.lightMeshMaterial
    `<Object3D quaternion={this.props.quaternion} position={this.props.position}>
      <Mesh geometry={this.state.geometry} material={material} />
    </Object3D>`


# Piece - React-THREE the playing piece
Piece = React.createClass
  displayName: 'Piece'

  propTypes:
    position: React.PropTypes.instanceOf(THREE.Vector3)

  getDefaultProps: ->
    position: new THREE.Vector3(0,0,0)
    quaternion: false

  getInitialState: do ->
    # items we only need one of across all objects created here
    # and stored in 'singleton'
    singleton = {}

    # a little squat cylinder    ( radiusAtTop, radiusAtBottom, height, radiusSegments, heightSegments )
    singleton.geometry = new THREE.CylinderGeometry( 85, 85, 30, 40, 4 )  #new THREE.BoxGeometry( 20,200,20 )
    singleton.color    = new THREE.MeshBasicMaterial
      color: getColorFromCSS '.Piece'
      transparent: true
      opacity: 0.85
    # from http://stackoverflow.com/questions/25231965/
    for face in singleton.geometry.faces
      if face.normal.y is 0
        face.color.setHex getColorFromCSS '.PieceSide'
    singleton.color.vertexColors = THREE.FaceColors

    return ->
      # this is the function that is called for each object's state on object creation
      state = _.clone singleton  # copy in the static values from the singleton
      # add any additional per object values to state here
      return state

  render: ->
    if not @props.quaternion
      deg90 = (Math.PI/2)  # 90 degrees in radians
      @props.quaternion = new THREE.Quaternion()
      #    .setFromEuler( new THREE.Euler(deg90, 0, deg90*rotationFactor), 'XYZ')
    `<Object3D quaternion={this.props.quaternion} position={this.props.position}>
      <Mesh geometry={this.state.geometry} material={this.state.color} />
    </Object3D>`


# Board - React-THREE grid of squares
Board = React.createClass
  displayName: 'Board'

  setInitialState: ->
    board: @props.board

  propTypes:
    position: React.PropTypes.instanceOf(THREE.Vector3)
    quaternion: React.PropTypes.instanceOf(THREE.Quaternion).isRequired

  render: ->
    objects = []
    [piece_row, piece_col] = @props.piece.currentPos()
    board = @props.board
    board.visit (square, i, row, col) ->
      if isOdd board.cols then isDarkSquare = isOdd i
      else  # even sized edge boards checkboard correction
        isDarkSquare = if isOdd row then isOdd i else isOdd i+1
      key = "#{row}x#{col}"
      x = (col-1) * 200 - (board.cols * 200 / 2)
      y = (row-1) * 200 - (board.rows * 200 / 2)
      position = new THREE.Vector3(x,100,y)
      objects.push `<Square key={key} position={position} dark={isDarkSquare} />`

      position = new THREE.Vector3(x-0,125,y-0)
      key = key += 'arrow'
      direction = BoardLogic::toUDLR(square)
      objects.push `<Arrow key={key} direction={direction} position={position} dark={!isDarkSquare} />`

      if row is piece_row and col is piece_col
        position = new THREE.Vector3(x-0,120,y-0)
        objects.push `<Piece key="piece" position={position} />`

    if not @props.piece.stillOnBoard()
      x = (piece_col-1) * 200 - (board.cols * 200 / 2)  # code smell: repeating, hard-coded
      y = (piece_row-1) * 200 - (board.rows * 200 / 2)
      position = new THREE.Vector3(x-0,120,y-0)
      objects.push `<Piece key="piece" position={position} />`

    position = @props.position || new THREE.Vector3(0,0,0)
    `<Object3D quaternion={this.props.quaternion} position={position}>
      {objects}
    </Object3D>`


# Tabletop - React-THREE 3d scene containing the playing board, arrows, piece, and camera
Tabletop = React.createClass
  displayName: 'Tabletop'

  render: ->
    aspectRatio = @props.width / @props.height
    cameraProps =
      fov: 75
      aspect: aspectRatio
      near: 1, far: 20000
      #position: new THREE.Vector3(0, 800, 10+(@props.board.rows*180) )
      position: new THREE.Vector3(0, 1400, 10+(@props.board.rows*180) )
      lookat: new THREE.Vector3(0,-200,0)

    background = getColorFromCSS '.Scene', 'background-color'
    `<Scene background={background} width={this.props.width} height={this.props.height} camera="maincamera">
        <PerspectiveCamera name="maincamera" {...cameraProps} />
        <Board board={this.props.board} piece={this.props.piece} quaternion={this.props.boardQuaternion} />
      </Scene>`


# Game - top level element
Game = React.createClass
  displayName: 'Game'

  getInitialState: ->
    sizeInput: @props.size
    size: @props.size
    board: @props.board
    piece: @props.piece
    moves: 0
    autoMoveTimeout: null

  newGame: (size) ->
    @clearTimer()
    gameData = newGame size
    @setState
      size: gameData.size
      board: gameData.board
      piece: gameData.piece
      moves: @state.moves+1
      sizeInput: gameData.size

  clearTimer: ->
    if @state.autoMoveTimeout?
      clearTimeout @state.autoMoveTimeout
      @setState autoMoveTimeout: null

  randomizeIt: ->
    console.log 'randomizeIt'
    @newGame @state.size

  changeSize: (e) ->
    console.log 'changeSize', e
    new_size = parseInt e.target.value
    @setState sizeInput: new_size
    if new_size > 1 and new_size <= 40
      console.log 'new_size', new_size
      @newGame new_size

  expandIt: ->
    @newGame @state.size + 1

  reduceIt: ->
    @newGame @state.size - 1

  moveNext: ->
    console.log 'moveNext'
    if @state.piece.stillOnBoard()
      @refs.nextSound.getDOMNode().play()
      @state.piece.executeMove()
      @setState moves: @state.moves + 1

  toggleAutoMove: ->
    if not @state.autoMoveTimeout?
      @autoMove()
    else
      @clearTimer()
    return @

  autoMove: ->
    console.log 'autoMove:', @
    if not @state.piece.stillOnBoard()  # pressing 'winner!' resets
      @randomizeIt()
    else
      if @state.piece.checkForLoop()
        # let's remove the loop from the history upon a second
        # press of the button and allow then to loop again
        @state.piece.checkForLoop(true)
      timeout = null
      if @state.piece.stillOnBoard()
        @moveNext()
        if @state.piece.stillOnBoard() and not @state.piece.checkForLoop()
          timeout = timeoutSet 500, => @autoMove()
      @setState autoMoveTimeout: timeout
    return @

  undoMove: ->
    console.log 'undoMove'
    @state.piece.undoMove()

  render: ->
    playStopLabel = 'play'
    if @state.autoMoveTimeout?
      playStopLabel = 'stop'
    else if not @state.piece.stillOnBoard()  # code smell: duplicate logic
      playStopLabel = 'winner!'
    else if @state.piece.checkForLoop()
      playStopLabel = 'loop'
    `<div>
      <Tabletop {...this.props.sceneProps} board={this.state.board} piece={this.state.piece}
          boardQuaternion={this.props.boardQuaternion} />
      <div className="controlbar noselect">
        <div className="controls">
          <button onClick={this.randomizeIt}><span>reset</span></button>
          <button onClick={this.toggleAutoMove}><span>{playStopLabel}</span></button>
          <input type="number" className="size" min="1" max="40"
            onChange={this.changeSize} value={this.state.sizeInput}>
          </input>
          <button onClick={this.undoMove} disabled={this.state.piece.history.length<2}><span>undo</span></button>
          <button onClick={this.moveNext} disabled={!this.state.piece.stillOnBoard()}><span>move</span></button>
        </div>
      </div>
      <audio ref='nextSound' src='static/sounds/First_Contact.wav' type='audio/wav' preload />
    </div>`


newGame = (size) ->
  board = new BoardLogic( Math.pow(size, 2) ).randomize()
  piece = new PieceLogic(board).placeRandomlyOnBoard()
  gameData =
    size: size
    board: board
    piece: piece
  return gameData


main = ->
  sceneProps =
    width:  window.innerWidth
    height: window.innerHeight

  gameData = newGame 8

  React.initializeTouchEvents(true)

  boardQuaternion = new THREE.Quaternion()
  Game = React.render `<Game sceneProps={sceneProps}
          size={gameData.size} board={gameData.board} piece={gameData.piece}
          boardQuaternion={boardQuaternion} />`, document.body

  rotationAngle = 0
  spinGameDisplay = (t) ->
    rotationAngle = t * 0.000007
    boardQuaternion.setFromEuler new THREE.Euler(0, rotationAngle*3, 0)
    Game.setProps(boardQuaternion: boardQuaternion)
    requestAnimationFrame(spinGameDisplay)
  spinGameDisplay()

  # not yet working FIXME
  resize = ->
    sceneProps =
      width:  window.innerWidth
      height: window.innerHeight
    Game.setState sceneProps: sceneProps
  window.addEventListener 'resize', resize, false
  #Game.setState({resizecallback:resize})


module.exports = main
