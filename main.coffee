enchant()

CHARA_SIZE  = 32
CHARA_SPEED = 1
GAME_WIDTH  = 320
GAME_HEIGHT = 320
BOSS_SIZE   = 32 * 16
global = this

window.onload = ->
    bamboo = null
    game = new Game GAME_WIDTH, GAME_HEIGHT
    game.fps = 60
    imgs =
        box:    'img/box.png'
        boss:   'img/boss.png'
        hito:   'img/chara.png'
        bamboo: 'img/bamboo.png'

    for key of imgs
        game.preload imgs[key]

    HitBody = enchant.Class.create enchant.Sprite,
        initialize: (subject, left, top, width, height) ->
            enchant.Sprite.call this, width, height
            @subject = subject
            @left = left
            @top  = top
            # @backgroundColor = 'rgba(0, 255, 0, 0.5)'
            @update()
            game.rootScene.addChild this

        update: ->
            @x = @subject.x + @left
            @y = @subject.y + @top
        destroy: ->
            game.rootScene.removeChild this
            @clearEventListener()

    box_speed = 2
    Box = enchant.Class.create enchant.Sprite,
        initialize: ->
            enchant.Sprite.call this, CHARA_SIZE, CHARA_SIZE
            @x = GAME_WIDTH
            @y = Math.floor (Math.random() * GAME_HEIGHT)
            @vy = Math.random() * box_speed - box_speed/2
            @image = game.assets[imgs.box]
            @addEventListener 'enterframe', @update
            game.rootScene.addChild this
            @hitbody = new HitBody(this, 6, 4, 18, 25)

        update: ->
            @x -= box_speed
            @y += @vy
            @frame = [0,1,0,2][@age % 4]
            for b in bamboos
                if @hitbody.intersect(b)
                    @destroy()
                    b.destroy()
                    return
            if @x < 0 - @width
                @destroy()
                return
            if @y < 0 - @width
                @y = GAME_HEIGHT
            if @y > GAME_WIDTH
                @y = -@width
            if @hitbody.intersect(hito.hitbody)
                hito.damage()

            @hitbody.update()

        destroy: ->
            game.rootScene.removeChild this
            @hitbody.destroy()
            @clearEventListener()


    # ボス
    boss_walk_pos_x = [0, 80]
    boss_walk_pos_y = [-80, 0, 80]
    Boss = enchant.Class.create enchant.Sprite,
        initialize: ->
            enchant.Sprite.call this, BOSS_SIZE, BOSS_SIZE
            console.log('boss')
            @x = GAME_WIDTH - 60
            @y = 0
            @damage_counter = 0
            @image = game.assets[imgs.boss]
            @addEventListener 'enterframe', @update
            game.rootScene.addChild this
            # 当たり判定
            @hitbody    = new HitBody(this, 11*16,12*16,  3*16,  2*16)
            # 攻撃判定
            @attackbody = new HitBody(this,  6*16, 4*16, 18*16, 25*16)

            # 初期アニメーション
            @standby = false
            @tl.moveTo(0, 0, game.fps * 5)
               .then ->
                @standby = true

        update: ->
            # テスト
            # console.log "x:#{@x}, y:#{@y}"
            # if game.input.up    then @y -= CHARA_SPEED
            # if game.input.down  then @y += CHARA_SPEED
            # if game.input.left  then @x -= CHARA_SPEED
            # if game.input.right then @x += CHARA_SPEED
            # 見た目の制御
            @frame = 0
            if @damage_counter > 0
                @frame = if @age % 6 < 3 then 0 else 4
                @damage_counter--
            # ダメージ、攻撃
            for b in bamboos
                if @hitbody.intersect(b)
                    @damage()
                    b.destroy()
                    return
            if @attackbody.intersect(hito.hitbody)
                hito.damage()
            # 行動選択
            if @standby
                @walk()

            # 当たり判定への反影
            @attackbody.update()
            @hitbody.update()

        walk: ->
            @standby = false
            x = boss_walk_pos_x[Math.floor(Math.random() * boss_walk_pos_x.length)]
            y = boss_walk_pos_y[Math.floor(Math.random() * boss_walk_pos_y.length)]
            # dist = Math.sqrt(x*x + y*y)
            # @tl.moveTo(x, y, Math.floor(game.fps * dist/80))
            @tl.moveTo(x, y, game.fps)
               .then ->
                @standby = true


        damage: ->
            @damage_counter = 12

        destroy: ->
            game.rootScene.removeChild this
            @hitbody.destroy()
            @attackbody.destroy()
            @clearEventListener()


    hito = null
    Hito = enchant.Class.create enchant.Sprite,
        initialize: ->
            enchant.Sprite.call this, CHARA_SIZE, CHARA_SIZE
            @x = 2
            @y = Math.floor (GAME_HEIGHT / 2)
            @image = game.assets[imgs.hito]
            @prev_shot_button = false
            @damage_counter = 0
            @shot_counter = 0

            @addEventListener 'enterframe', @update
            game.rootScene.addChild this
            @hitbody = new HitBody(this, 10, 3, 10, 25)

        update: ->
            # 見た目の初期化
            if game.input.up or game.input.down or game.input.left or game.input.right
                @frame = [0, 4, 0, 5][Math.floor(this.age/4) % 4]
            else
                @frame = 0
            if @damage_counter > 0
                @frame = if @age % 2 == 0 then 3 else 7
                @damage_counter--
            if @shot_counter > 0
                @frame = 1
                @shot_counter--
            #ボタン入力の処理
            if game.input.up    then @y -= CHARA_SPEED
            if game.input.down  then @y += CHARA_SPEED
            if game.input.left  then @x -= CHARA_SPEED
            if game.input.right then @x += CHARA_SPEED
            if (not @prev_shot_button) and game.input.a
                # if bamboos.length < max_bamboo_num
                #     @frame = 1
                #     bamboo = new Bamboo @x + CHARA_SIZE, @y + CHARA_SIZE/2
                @shot_counter = 6
                bamboo = new Bamboo @x + CHARA_SIZE, @y + CHARA_SIZE/2
                @to_shot_bamboo = false
            @prev_shot_button = game.input.a
            @hitbody.update()

        damage: ->
            @damage_counter = 20

    bamboos = []
    max_bamboo_num = 5
    Bamboo = enchant.Class.create enchant.Sprite,
        initialize: (x, y) ->
            enchant.Sprite.call this, 23, 3
            @x = x
            @y = y
            this.image = game.assets[imgs.bamboo]

            @addEventListener 'enterframe', @update
            game.rootScene.addChild this
            bamboos.push(this)

        update: ->
            @x += 3
            if @x > GAME_WIDTH # 削除
                @destroy()

        destroy: ->
                for b, index in bamboos
                    if b is this
                        bamboos.splice(index, 1)
                game.rootScene.removeChild this
                @clearEventListener()

    game.onload = ->
        game.rootScene.backgroundColor = "aqua"
        game.keybind 32, "a"

        global.boss =  new Boss
        hito = new Hito
        # スマホ対応
        game.rootScene.addEventListener 'touchstart', (e) ->
        game.rootScene.addEventListener 'touchend', (e) ->
        setInterval ->
            new Box
        , 500

    game.start()

