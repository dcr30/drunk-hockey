local widget    = require("widget")
local composer  = require("composer")
local adsconfig = require("config.adsconfig")
local ads       = require("lib.ads")

local function showUI(event)
    local self        = event.source.params.self
    local winner      = event.source.params.winner
    local score       = event.source.params.score
    local shotsOnGoal = event.source.params.shotsOnGoal
    local savesCount  = event.source.params.savesCount

    self.winner = winner

    if winner == self.colorName then
        self.winnerText.text = lang.getString("game_you_win")
    else
        self.winnerText.text = lang.getString("game_you_lose")
    end
    if winner == "blue" then
        self.winnerText:setFillColor(0.15, 0.4, 1)
    else
        self.winnerText:setFillColor(1, 0.1, 0.1)
    end

    self.infoText.text = lang.getString("game_end_shots_on_goal") .. ": " .. tostring(shotsOnGoal)
        .. "\n\n" .. lang.getString("game_end_saves") .. ": " .. tostring(savesCount)

    self.scoreText.text = lang.getString("game_end_score")  .. " " .. score[1] .. ":" .. score[2]

    self.winnerText.alpha = 1
    self.winnerText.xScale = 1
    self.winnerText.yScale = 1

    self.scoreText.alpha = 1
    self.scoreText.xScale = 1
    self.scoreText.yScale = 1

    self.infoText.alpha = 1
    self.infoText.xScale = 1
    self.infoText.yScale = 1

    self.continueButton.alpha = 1
    self.continueButton.xScale = 1
    self.continueButton.yScale = 1

    transition.to(self.commercialBrakeText, { time = 300, alpha = 0 })

    self.backButton.alpha = 1
    self.backButton.xScale = 1
    self.backButton.yScale = 1

    transition.from(self.winnerText,     { transition = easing.outBack, delay = 500,  time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.scoreText,      { transition = easing.outBack, delay = 1000, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.infoText,       { transition = easing.outBack, delay = 1500, time = 500, alpha = 0, xScale = 0.5, yScale = 0.8 })
    transition.from(self.continueButton, { transition = easing.outBack, delay = 2000, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
    transition.from(self.backButton,     { transition = easing.outBack, delay = 2500, time = 500, alpha = 0, xScale = 0.3, yScale = 0.8 })
end

local function showAd(event)
    local self = event.source.params.self

    if ads.isLoaded(adsconfig.adType) then
        DEBUG.Log("Show ad")
        ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
    else
        DEBUG.Log("Can't show ad. Ad is not loaded yet")
        ads.show(adsconfig.adType, { testMode = adsconfig.testMode })
    end

    local showUITimer = timer.performWithDelay(2000, showUI, 1)
    showUITimer.params = event.source.params
end

local function commercialBrake(event)
    local self = event.source.params.self

    self.commercialBrakeText.alpha  = 1
    self.commercialBrakeText.xScale = 1
    self.commercialBrakeText.yScale = 1

    transition.from(self.commercialBrakeText, { transition=easing.outBack, delay = 100, time = 300, alpha = 0, xScale = 0.5, yScale = 0.8 })

    local showAdTimer = timer.performWithDelay(500, showAd, 1)
    showAdTimer.params = event.source.params
end

local function show(self, winner, score, shotsOnGoal, savesCount)
    if self.isVisible then
        return
    end

    if not score then
        score = {0, 0}
    end
    self.isVisible = true

    self.commercialBrakeText.text = lang.getString("game_commercial_brake")

    if self.bg then
        self.bg.alpha = 1
        self.bg.xScale = 1
        self.bg.yScale = 1

        transition.from(self.bg, { time = 300, alpha = 0 })
    end

    local commercialBrakeTimer = timer.performWithDelay(300, commercialBrake, 1)
    commercialBrakeTimer.params = { self        = self,
                                    winner      = winner,
                                    score       = score,
                                    shotsOnGoal = shotsOnGoal,
                                    savesCount  = savesCount}
end

local function hide(self)
    if not self.isVisible then
        return
    end

    local state = { time = 300, alpha = 0 }
    if self.bg then
        transition.to(self.bg, state)
    end
    transition.to(self.winnerText, state)
    transition.to(self.scoreText, state)
    transition.to(self.infoText, state)
    transition.to(self.continueButton, state)
    transition.to(self.backButton, { time = state.time, alpha = state.alpha, onComplete = function ()
        self.isVisible = false
    end})

end

local function constructor(isMultiplayer, bg, colorName)
    self = display.newGroup()
    self.isMultiplayer = isMultiplayer

    self.colorName = colorName
    self.bg = bg

    local shitFuckOffset = -8
    self.winnerText = display.newText("", 0, 0 + shitFuckOffset, "pixel_font.ttf", 9)
    self.winnerText:setFillColor(0.15, 0.4, 1)
    self:insert(self.winnerText)

    self.scoreText = display.newText("", 0, 9 + shitFuckOffset, "pixel_font.ttf", 6)
    self.scoreText:setFillColor(0.15, 0.4, 1)
    self:insert(self.scoreText)

    self.infoText = display.newText({
        text = "Some text 1: 99\nSome text 2: 99",
        x    = 0,
        y    = 20 + shitFuckOffset,
        font = "pixel_font.ttf",
        fontSize = 4,
        align = "center",
    })
    self.infoText.alpha = 0
    self.infoText:setFillColor(0.15, 0.4, 1)
    self:insert(self.infoText)

    self.commercialBrakeText = display.newText("", 0, 0, "pixel_font.ttf", 6)
    self.commercialBrakeText.alpha = 0
    self:insert(self.commercialBrakeText)

    self.continueButton = widget.newButton({
        x = 0,
        y = 31 + shitFuckOffset,
        alpha = 0,
        width = display.contentWidth,
        height = 8,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("game_restart_button"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            local scene = composer.getScene(composer.getSceneName("current"))
            if scene then
                scene:restartGame()
            end
        end
    })
    self.continueButton.alpha = 0
    self:insert(self.continueButton)

    self.backButton = widget.newButton({
        x = 0,
        y = 41 + shitFuckOffset,
        width = display.contentWidth,
        height = 8,

        font = "pixel_font.ttf",
        fontSize = 5,
        label = lang.getString("game_end_button"),
        labelColor = { default = {1, 1, 1} },

        defaultFile = "assets/empty.png",

        onRelease = function ()
            composer.gotoScene("scenes.menu", {time = 500, effect = "slideRight"})
        end
    })
    self.backButton.alpha = 0
    self:insert(self.backButton)

    self.isVisible = false

    self.show = show
    self.hide = hide
    return self
end

return constructor
