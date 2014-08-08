RAQUETA_ACELERACION = 0.40
RAQUETA_VELOCIDAD_FINAL = 5
RAQUETA_FRICCION = 0.10
PELOTA_ACELERACION = 5
PELOTA_VELOCIDAD_FINAL = 5
PELOTA_FRICCION = 0
LEFT = 0
RIGHT = 1

class Ingles
  getLove: ->
    return "Love"

  getFifteen: ->
    return "Fifteen"

  getThirty: ->
    return "Thirty"

  getForty: ->
    return "Forty"

  getAll: ->
    return "-All"

  getDeuce: ->
    return "Deuce"

  getAdvantage: ->
    return "Advantage"

  getWin: ->
    return "Win for "

class Espanol
  getLove: ->
    return "Cero"

  getFifteen: ->
    return "Quince"

  getThirty: ->
    return "Treinta"

  getForty: ->
    return "Cuarenta"

  getAll: ->
    return "-Iguales"

  getDeuce: ->
    return "Empate"

  getAdvantage: ->
    return "Ventaja para "

  getWin: ->
    return "Gana "

class Aleman
  getLove: ->
    return "Liebe"

  getFifteen: ->
    return "Fünfzehn"

  getThirty: ->
    return "Dreißig"

  getForty: ->
    return "Vierzig"

  getAll: ->
    return "-À"

  getDeuce: ->
    return "Gleichstand"

  getAdvantage: ->
    return "Gleichstand "

  getWin: ->
    return "Gewinnen "

class Frances
  getLove: ->
    return "Zèro"

  getFifteen: ->
    return "Quinze"

  getThirty: ->
    return "Trente"

  getForty: ->
    return "Quarant"

  getAll: ->
    return "-À"

  getDeuce: ->
    return "Égalité"

  getAdvantage: ->
    return "Avantage "

  getWin: ->
    return "Gagner "


class Tenis
  constructor: (p1N, p2N) ->
    @p2 = 0
    @p1 = 0
    @p1N = p1N
    @p2N = p2N

  wonPoint: (playerName) ->
    if playerName is 1
      @p1 += 1
    else
      @p2 += 1

  setPoint: (playerName, point) ->
    if playerName is @p1N
      @p1 = point
    else
      @p2 = point

  getPoint: (player) ->
    if player is 1
      return @p1
    else
      return @p2

  getScore: ->
    s = undefined
    if (@p1 < 4 and @p2 < 4) and (@p1 + @p2 < 6)
      p = [
        @idioma.getLove()
        @idioma.getFifteen()
        @idioma.getThirty()
        @idioma.getForty()
      ]
      s = p[@p1]
      (if (@p1 is @p2) then s + @idioma.getAll() else s + "-" + p[@p2])
    else
      return @idioma.getDeuce()  if @p1 is @p2
      s = (if @p1 > @p2 then @p1N else @p2N)
      (if ((@p1 - @p2) * (@p1 - @p2) is 1) then @idioma.getAdvantage() + s else @idioma.getWin() + s)

  getName: (player) ->
    if player is 1
      return @p1N
    else
      return @p2N

  setIdioma:(idioma) ->
    @idioma = idioma

class Figura
  x: 0, y: 0, vx: 0, vy: 0
  constructor: (@context, @maxX, @maxY, @minX, @minY, @offsetX, @offsetY, @a, @tv, @f) ->

  update: ->
    @vx -= @f if @vx > 0
    @vx += @f if @vx < 0
    @vy -= @f if @vy > 0
    @vy += @f if @vy < 0

    @vx = @tv if @vx > @tv
    @vx = -@tv if @vx < -@tv
    @vy = @tv if @vy > @tv
    @vy = -@tv if @vy < -@tv

    @x += @vx
    @y += @vy

    @checkBoundary()

  checkBoundary: ->
    @x = @maxX-@w if @x+@w > @maxX
    @x = @minX if @x < @minX
    @y = @maxY-@h if @y+@h > @maxY
    @y = @minY if @y < @minY

  draw: ->
    @context.fillStyle = '#186AB6'
    @context.fillRect @x+@offsetX, @y+@offsetY, @w, @h

  accelX: -> @vx += @a
  accelY: -> @vy += @a
  decelX: -> @vx -= @a
  decelY: -> @vy -= @a

class Raqueta extends Figura
  w: 20, h: 175

class Pelota extends Figura
  w: 10, h: 10, x: 200, y: 200, winner: null

  checkWinner: -> @winner

  checkBoundary: ->
    if @x+@w > @maxX
      @winner = 1
    if @x < @minX
      @winner = 2

    @vy = -@vy if @y+@h > @maxY or @y < @minY

  checkCollision: (e, bat) ->
    x = @x + @offsetX
    y = @y + @offsetY
    ex = e.x + e.offsetX
    ey = e.y + e.offsetY
    if y >= ey and y <= ey+e.h
      if bat is LEFT and x < ex+e.w
        @x += RAQUETA_VELOCIDAD_FINAL / 2
        @vx = -@vx
      if bat is RIGHT and x+@w > ex
        @x -= RAQUETA_VELOCIDAD_FINAL / 2
        @vx = -@vx

  draw: ->
    @context.beginPath()
    @context.fillStyle = 'rgba(0,0,0,0.8)'
    @context.arc @x+@offsetX, @y+@offsetY, 10, 0, Math.PI*2
    @context.fill()

class TenisGame
  main: ->
    @createCanvas()
    @addKeyObservers()
    @startNewGame()

  startNewGame: ->
    @entities = []
    @entities.push(new Raqueta @context, @canvas.width, @canvas.height, 0, 0, 30, 0, RAQUETA_ACELERACION, RAQUETA_VELOCIDAD_FINAL, RAQUETA_FRICCION)
    @entities.push(new Raqueta @context, @canvas.width, @canvas.height, 0, 0, @canvas.width - 70, 0, RAQUETA_ACELERACION, RAQUETA_VELOCIDAD_FINAL, RAQUETA_FRICCION)
    @entities.push(new Pelota @context, @canvas.width, @canvas.height, 0, 0, 0, 0, PELOTA_ACELERACION, PELOTA_VELOCIDAD_FINAL, PELOTA_FRICCION)

    @entities[2].vx = 5
    @entities[2].vy = 5

    @runLoop()

  runLoop: ->
    setTimeout =>
      @entities[0].decelY() if @aPressed
      @entities[0].accelY() if @zPressed
      @entities[1].decelY() if @upPressed
      @entities[1].accelY() if @downPressed

      @entities.forEach (e) -> e.update()

      @entities[2].checkCollision @entities[0], LEFT
      @entities[2].checkCollision @entities[1], RIGHT

      player = @entities[2].checkWinner()
      if player
        @terminateRunLoop = true
        @score = [0, 0] unless @score
        @tenis.wonPoint(player)
        @notifyScore "<h1 class='animated tada'>#{@tenis.getScore()}</h1>"
        @notifyStatus "#{@tenis.getName(player)} gana el Set! Nuevo juego en 3 segundos."
        @addRow()
        setTimeout =>
          @notifyStatus ''
          @terminateRunLoop = false
          @startNewGame()
        , 3000

      @clearCanvas()

      @entities.forEach (e) -> e.draw()

      @runLoop() unless @terminateRunLoop
    , 10

  notifyStatus: (message) ->
    $('#message').html message

  notifyScore: (message) ->
    $('#score').html message

  cleanup: ->
    @terminateRunLoop = true
    @clearCanvas()

  createCanvas: ->
    @canvas = document.getElementById 'canvas'
    @context = @canvas.getContext '2d'
    @canvas.width = 1100
    @canvas.height = 400

  createTenis: (p1N, p2N) ->
    @tenis =  new Tenis(p1N,p2N)

  setIdiomaTenis: (idioma) ->
    @tenis.setIdioma(idioma)

  addRow: ->
    $('#table-marcador tbody').append("<tr><td>#{@tenis.getPoint(1)}</td><td>#{@tenis.getPoint(2)}</td><td>#{@tenis.getScore()}</td></tr>")

  clearCanvas: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

  addKeyObservers: ->
    document.addEventListener 'keydown', (e) =>
      switch e.keyCode
        when 40 then @downPressed = true
        when 38 then @upPressed = true
        when 90 then @zPressed = true
        when 65 then @aPressed = true
    , false

    document.addEventListener 'keyup', (e) =>
      switch e.keyCode
        when 27 then @cleanup()
        when 40 then @downPressed = false
        when 38 then @upPressed = false
        when 90 then @zPressed = false
        when 65 then @aPressed = false
    , false

game = new TenisGame

$('#btn-iniciar').click ->
  nombre_j1 = $('#nombre_j1').val()
  nombre_j2 = $('#nombre_j2').val()
  num_idioma = parseInt($('#idioma').val(), 10)
  if nombre_j1 && nombre_j2 && num_idioma
    game.createTenis(nombre_j1,nombre_j2)
    switch num_idioma
          when 1 then game.setIdiomaTenis(new Ingles)
          when 2 then game.setIdiomaTenis(new Espanol)
          when 3 then game.setIdiomaTenis(new Aleman)
          when 4 then game.setIdiomaTenis(new Frances)
    setTimeout ->
      game.main()
      $('#table-marcador #j1').html(nombre_j1)
      $('#table-marcador #j2').html(nombre_j2)
      $('#table-marcador').show()
    , 1500
  else
    alert 'Rellena todos los campos'


