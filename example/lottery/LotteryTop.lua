local LotteryTop=Class("LotteryTop",require("components.View"))
local HelpTip=require("scenes.game.help.HelpTip")


local LotteryModel = App:GetModel("LotteryModel")
local PlayerModel = App:GetModel("PlayerModel")
local PropsModel = App:GetModel("PropsModel")

local AppConst = const("AppConst")


function LotteryTop:ctor(ctrl)
    LotteryTop.super.ctor(self,ctrl)
    local path="UI/Prefabs/summon/summonTop.prefab"
    local go = App:GetResourceManager():GetPrefab(path)
    self.view = App:GetGUIManager():PushNavigation(go,self)
    self.boxScript=self.boxBtn.gameObject:GetComponent(typeof(CS.AnimationUICurve))
    self:UpDataResView()
    self.progress.Slider.value = LotteryModel.lotteryData.pb_high_lottery_point
    self.Text.Text.text = string.format('%s/%s', NumToFormatString(LotteryModel.lotteryData.pb_high_lottery_point), NumToFormatString(LotteryModel.PointConsume))
    self.boxScript.enabled=(LotteryModel.lotteryData.pb_high_lottery_point >= self.progress.Slider.maxValue)
end


function LotteryTop:UpDataResView()
    self.diamond.Text.text = NumberFormat(PlayerModel:GetResourceByType(AppConst.PRICE_TYPE.Gold))
    self.reelIc1.Image.sprite = App:GetResourceManager():GetPropIcon(LotteryModel:GetProId(1))
    self.reelIc2.Image.sprite = App:GetResourceManager():GetPropIcon(LotteryModel:GetProId(2))
    self.pro1.Text.text = NumberFormat(PropsModel:GetPropItemNum(LotteryModel:GetProId(1)))
    self.pro2.Text.text = NumberFormat(PropsModel:GetPropItemNum(LotteryModel:GetProId(2)))
end


function LotteryTop:SetBackEnable(isEnable)
    self.FXback.gameObject:SetActive(isEnable)
end




function LotteryTop:UpDataProgressView()
    local lotteryData = LotteryModel.lotteryData
    self.progress.Slider.value = lotteryData.pb_pre_lottery_point
    self.progress.Slider:DOValue(lotteryData.pb_high_lottery_point,  1)
    self.Text.Text.text = string.format('%d/%d',LotteryModel.lotteryData.pb_high_lottery_point,LotteryModel.PointConsume)
    self.boxScript.enabled=(LotteryModel.lotteryData.pb_high_lottery_point >= self.progress.Slider.maxValue)
end


function LotteryTop:Show(value)
    self.node.gameObject:SetActive(value)
end

function LotteryTop:LotteryPoint()
    if LotteryModel.lotteryData.pb_high_lottery_point>=LotteryModel.PointConsume then
        SendPacket("ReqLotteryAction", {lottery_type=3, fee_type=0, lottery_times=1})
    else
        local helpTip = HelpTip.New(self)
        local pos = Vector3(self.boxBtn.RectTransform.position.x-2,self.boxBtn.RectTransform.position.y-2,self.boxBtn.RectTransform.position.z)
        helpTip:Show()
        helpTip:ShowTip(pos,99012)
    end
end

--去充值界面
function LotteryTop:OnChargeClick()
    App:dispatchEvent({name = const("AppEvent").BUY_DIAMON})
end


function LotteryTop:OnGoStrong( ... )
    App:dispatchEvent({name = const("AppEvent").GO_STRONG_VIEW, data = AppConst.StrongLableList.DialGold})
end

function LotteryTop:OnBack()
    App.game:navigateBack()
end

function LotteryTop:OnHelp()
    self:GetCtrl():OnHelp(self.sign)
end

function LotteryTop:Remove()
    App:GetGUIManager():PopNavigation()
end

function LotteryTop:UpDataView()
    self.diamond.Text.text = NumberFormat(PlayerModel:GetResourceByType(AppConst.PRICE_TYPE.Gold))
end

function LotteryTop:OnEnter()
    local AppEvent = const("AppEvent")
    self:Binding(LotteryModel, self, self.UpDataResView, AppEvent.Lottery)
    self:Binding(PlayerModel, self, self.UpDataView, AppEvent.PLAYER_DATA_UPDATA)
    self:Binding(App, self, self.UpDataProgressView, AppEvent.LOTTERY_RESULTOK)
end


return LotteryTop
