enchant()

CHARA_SIZE  = 32
GAME_WIDTH  = 320
GAME_HEIGHT = 320

window.onload = ->
    game = new Game GAME_WIDTH, GAME_HEIGHT
    game.preload 'img/box.png'

    Box = enchant.Class.create enchant.Sprite,
        initialize: ->
            enchant.Sprite.call this, CHARA_SIZE, CHARA_SIZE
            this.x = GAME_WIDTH
            this.y = Math.floor (Math.random() * GAME_HEIGHT)
            # this.backgroundColor = "red"
            this.image = game.assets['img/box.png']

            this.addEventListener 'enterframe', this.update
            game.rootScene.addChild this

        update: ->
            this.x -= 0.1
            this.frame = [0,1,0,2][this.age % 4]


    game.onload = ->
        # スマホ対応
        game.rootScene.addEventListener 'touchstart', (e) ->
        game.rootScene.addEventListener 'touchend', (e) ->

        new Box

    game.start()

