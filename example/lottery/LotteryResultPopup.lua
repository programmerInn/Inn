
-- 掉落弹出框
-- Created by jk on 16-11-8
-- Copyright (c) 2016年 tjf. All rights reserved.
local LotteryResultPopup = Class("LotteryResultPopup",require("components.Popup"))
local ShipItem=require("scenes.game.common.ShipItem");
local AppConst = const("AppConst")
local ShipTipsPopup = require("scenes.game.ship.ShipTips")
local LotteryShow = require("scenes.game.lottery.LotteryShow")

local ShipModel = App:GetModel("ShipModel")
local PlayerModel = App:GetModel("PlayerModel")
local PropsModel = App:GetModel("PropsModel")
local LotteryModel= App:GetModel("LotteryModel")

local AnimationInternal=0.3
local SpecialStar=5
---------------------------------------ShipCompositePopup---------------------------------
function LotteryResultPopup:ctor(ctrl)
    LotteryResultPopup.super.ctor(self,ctrl,"UI/Prefabs/summon/summonResult.prefab")
    self.isBuy = false
end


function LotteryResultPopup:ShopShipTip(item)
    local shipTipsPopup = ShipTipsPopup.New()
    shipTipsPopup:Show()
    shipTipsPopup:SetData(item.data)
end

function LotteryResultPopup:SetData(data)
    self.result3bg.gameObject:SetActive(false)
    self.data = data

    self:startAni()
    self.result3.gameObject:SetActive(data.lottery_times==1)
    if self.lotteryShow==nil then
        self.lotteryShow=LotteryShow.New(self,self.popup.gameObject)
    end
    self:InitUi()
end


function LotteryResultPopup:InitUi()
    self.normalBtn2.gameObject:SetActive(self.data.lottery_times==1 and self.data.lottery_type~=3)
    self.goldBtn.gameObject:SetActive(self.data.lottery_times==10 and self.data.lottery_type~=3)

    self.proId = LotteryModel:GetProId(self.data.lottery_type)
    local itemNum = PropsModel:GetPropItemNum(self.proId)
    if  itemNum > 0 then
        self.oneDiamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
        self.oneDiamondNum.Text.text= "1"
        self.resEnoughOne = true
        self.isPropOne=true
    else
       local data=LotteryModel:GetConsumeData(self.data.lottery_type,1)
       self.oneDiamond.Image.sprite = App:GetResourceManager():GetResIcon(data.ctype)
       self.oneDiamondNum.Text.text = NumToFormatString(data.num[1][1])
       self.resEnoughOne=PlayerModel:GetResourceByType(data.ctype) >= data.num[1][1]
       self.isPropOne=false
    end
    if itemNum>=10 then
        self.diamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
        self.diamondNum.Text.text= "10"
        self.resEnoughTen = true
        self.isPropTen=true
    else
       local data=LotteryModel:GetConsumeData(self.data.lottery_type,10)
       self.diamond.Image.sprite = App:GetResourceManager():GetResIcon(data.ctype)
       self.diamondNum.Text.text =  NumToFormatString(data.num[1][1])
       self.resEnoughTen=PlayerModel:GetResourceByType(data.ctype) >= data.num[1][1]
       self.isPropTen=false
    end


    if  self.data.lottery_times == 10 then
        if self.isPropTen == false and self.isPropOne == true then
            self.goldBtn.gameObject:SetActive(false)
            self.normalBtn2.gameObject:SetActive(true)
        end
    end

    if self.data.lottery_type == 1 and self.isPropOne == false then 
            self.goldBtn.gameObject:SetActive(false)
            self.normalBtn2.gameObject:SetActive(false)
    end


end


function LotteryResultPopup:EndAnimation(shipitem,pos,particle,data)
    function ShowParticle()
        particle.gameObject:SetActive(data.baseShip.star >=  SpecialStar)
        self.result3bg.gameObject:SetActive(true)
    end




    local go = shipitem.gameObject
    go:SetActive(true)
    local item = ShipItem.New(go,handler(self,self.ShopShipTip))
    item:SetIconVisible(false)
    item:SetData(data)
    local Tween=CS.DG.Tweening.DOTween
    local animation = Tween.Sequence()
    animation:Append(go.transform:DOAnchorPos(pos,AnimationInternal))
    animation:Join(go.transform:DOScale(CS.UnityEngine.Vector3.one, AnimationInternal))
    if data.baseShip then
        if data.baseShip.star>=  SpecialStar then
            animation:Append(go.transform:DOPunchScale(CS.UnityEngine.Vector3.one/2,AnimationInternal,0.25,0.05))
        end
    end
    animation:AppendInterval(0.5); 
    animation:AppendCallback(ShowParticle)
end






function LotteryResultPopup:startAni()

    self.bottom.gameObject:SetActive(false)


    local data=self.data
    local shipList=data.ships
    self.result3.gameObject:SetActive(#shipList==1)

    local Tween=CS.DG.Tweening.DOTween
    local animation = Tween.Sequence()

    if  #shipList==1  then
        local data=shipList[1]
        data.pb_status=-1
        self.result3bg.gameObject:SetActive(false)
        self.shipName.Text.text= data:GetName()
        self.shipDetails.Text.text = lang(data.baseShip.desc) 

        animation:AppendCallback(function ()
            self:EndAnimation(self.shipItem1,Vector2(-280,20),self.Particle_shipItem1,data)
        end);
        animation:AppendInterval(1); 
        animation:AppendCallback(function ()
            self.bottom.gameObject:SetActive(true)
            App:dispatchEvent({name = const("AppEvent").LOTTERY_RESULTOK})
            App:dispatchEvent({name = constModel("TutorialModel").TUTORIAL_STEP_NEXT})
        end)

    else
        local count = #shipList
        function PauseAni(sData)
            if animation then
                animation:Pause();
            end
            local data={}
            data.lottery_type = self.data.lottery_type
            data.fee_type = self.data.fee_type
            data.lottery_times = 1
            data.ships = {sData}
            data.showUI = false
            data.proId = self.data.proId
            data.resTenValue = self.data.resTenValue
            data.resOneValue = self.data.resOne
            data.fun = function ()
                if animation then
                    animation:Play()
                end            
            end
            self.lotteryShow:SetData(data)
        end

        local len = #shipList
        local tempx1 = 174 * 2



        for i=1,#shipList do
            local data = shipList[i]
            data.pb_status=-1
            if data.baseShip.star >=SpecialStar then
                local sData = nil
                sData = data

                animation:AppendCallback(function()PauseAni(sData)end)
                animation:AppendInterval(0.2); 
            end
            
            local newy = 0
            local newx = 0
            if i <= 5 then
                newx = 174 * (i - 1) - tempx1 newy = 90
            else
                newx = 174 * (i - 6) - tempx1
                newy = -90
            end

            animation:AppendCallback(function ()
                self:EndAnimation(self["shipItem"..i],Vector2(newx,newy),self["Particle_shipItem"..i],data)
            end);
            animation:AppendInterval(0.5); 
        end
        animation:AppendInterval(0.5); 
        animation:AppendCallback(function ()
            self.bottom.gameObject:SetActive(true)
            App:dispatchEvent({name = const("AppEvent").LOTTERY_RESULTOK})
        end)

    end
end


function LotteryResultPopup:AnimaitonOneShip(go,currShipData)
    go:SetActive(true)
    local item = ShipItem.New(go,handler(self,self.ShopShipTip))
    item:SetIconVisible(false)
    item:SetData(currShipData)
    local Tween = CS.DG.Tweening.DOTween
    local animation = Tween.Sequence()
    animation:Join(go.transform:DOScale(CS.UnityEngine.Vector3.one, AnimationInternal))
    if currShipData.baseShip then
        if currShipData.baseShip.star >= SpecialStar  then 
            animation:Append(go.transform:DOPunchScale(Vector3.one*0.25,AnimationInternal,0,1));
        end
    end
    animation:AppendCallback(handler(item,item.SetIconVisible))
end



function  LotteryResultPopup:BuyOne()
    if #ShipModel.MyShipDataList+1<= ShipModel:GetShipMax() then
        if self.resEnoughOne then
            self.isBuy = true
            if self.isPropOne then
                SendPacket("ReqLotteryAction", {lottery_type = self.data.lottery_type, fee_type=3, lottery_times=1})
            else
                SendPacket("ReqLotteryAction", {lottery_type = self.data.lottery_type, fee_type=AppConst.PRICE_TYPE.Gold, lottery_times=1})
            end
        else
            self:ShowOutRes()
        end
    else
        self:ShipCapacity(handler(self,self.BuyOne))
    end
    self:Close()
end


function  LotteryResultPopup:BuyTen()
    if #ShipModel.MyShipDataList+10 <= ShipModel:GetShipMax() then
        if self.resEnoughTen then
            self.isBuy = true
            if self.isPropTen then
                SendPacket("ReqLotteryAction", {lottery_type = self.data.lottery_type, fee_type=3, lottery_times=10})
            else
                SendPacket("ReqLotteryAction", {lottery_type = self.data.lottery_type, fee_type=AppConst.PRICE_TYPE.Gold, lottery_times=10})
            end
        else
            self:ShowOutRes()
        end
    else
        self:ShipCapacity(handler(self,self.BuyTen))
    end
    self:Close()
end


function  LotteryResultPopup:ShowOutRes()
    if  self.data.lottery_type==1 then
        toast(lang('OutOfResource'))
    else
        toast(lang('Turnerr2'))
    end
end


function  LotteryResultPopup:ShipCapacity(fun)
    if PlayerModel:CanBuyShipMax()  then
    else
        self:ShowOutRes()
    end
    local gold_price_data = App:GetModel("GoldPriceModel"):getPriceByType(39);
    local buy_count = PlayerModel:GetBuyedShipMaxValue();
    local count = buy_count + 1;
    local num = -1;
    for k,v in ipairs(gold_price_data.num) do
        if k == count then
            num = v[1];
        end
    end
    if num == -1 then
        toast(lang("BuyShipLimit"))
        return;
    end
    local pop = require("scenes.game.common.popup.ConfirmPopup").New(); 
    local temp = {};
    local function click()
        SendPacket("ReqBuyShipMax",{})
    end
    temp.fun = click
    temp.reset = true;
    temp.str = lang("BuyShipMax", NumToFormatString(num), "10");
    temp.goldNum = num
    pop:Show();
    pop:SetData(temp);
    self:GetCtrl():SetBuyCallBack(fun)
end


function LotteryResultPopup:UnActive()
    self:Close()
end


function LotteryResultPopup:OnEnter()
    CS.UIRoot.GetInstance():ClearPopUpColor(true)
    LotteryResultPopup.super.OnEnter(self)
end


function LotteryResultPopup:OnExit()
    local shipList=self.data.ships
    for i,v in ipairs( shipList) do
        v.pb_status=0
    end


    CS.UIRoot.GetInstance():ClearPopUpColor(false)
    self:GetCtrl():EndShowLottery(not self.isBuy )
    LotteryResultPopup.super.OnExit(self)

end



return LotteryResultPopup
