
local Lottery = Class("Lottery",require("components.ViewController"))
local LotteryView = require("scenes.game.lottery.LotteryView")
local ChangeStoreView = require("scenes.game.shop.ChangeStoreView")


local Nav_Type = {
    Nav_Lottery = 1,
    NAV_CHANGE = 2,
}


function Lottery:ctor(game)   
    Lottery.super.ctor(self,game)
end



function Lottery:OnBack()
    self:GetGame():navigateBack()
end



function Lottery:Navigation(ntype)
    if self.view~=nil then
        App:GetGUIManager():PopView()
        self.view = nil
    end
    if ntype == Nav_Type.Nav_Type then
        self.view = LotteryView.New(self)
    elseif ntype == Nav_Type.NAV_CHANGE then
        self.view = ChangeStoreView.New(self)
    end
end



function Lottery:OnEnter(navData)
    self:Navigation(Nav_Type.Nav_Type)
end

function Lottery:OnExit()
    Lottery.super.OnExit(self)
    App:GetGUIManager():PopView()
    if self.popCtrl then
        self.popCtrl:Close()
    end
    self.view = nil
    self.resBar = nil
     
end

return Lottery
