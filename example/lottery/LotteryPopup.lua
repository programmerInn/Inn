local LotteryPopup = Class("LotteryPopup",require("components.View"))
local AppEvent = const("AppEvent")
local AppConst = const("AppConst")
local Star = require("scenes.game.common.Star")
local ShipItem=require("scenes.game.common.ShipItem");
local ShipShow = require("scenes.game.ship.ShipShow")
local ShipTipsPopup = require("scenes.game.ship.ShipTips")
local LotteryShow = require("scenes.game.lottery.LotteryShow")
local HelpTip=require("scenes.game.help.HelpTip")




local SPECIAL_STAR=5
function LotteryPopup:ctor(ctrl,obj)
    LotteryPopup.super.ctor(self,ctrl)
    self.go=obj
    local LuaBehaviour = self.go:GetComponent(typeof(CS.LuaGameObjectHelper))
    LuaBehaviour:loadGameObjects(self)

    self.model = App:GetModel("LotteryModel")
    self.PlayerModel = App:GetModel("PlayerModel")
    self.propModel=App:GetModel("PropsModel")
    self.shipModel=App:GetModel("ShipModel")
    self.shipTipsPopup = ShipTipsPopup.New()
    self.lotteryShow=nil
    self:SetActive(false)
    self.preAmbientLight=CS.UnityEngine.RenderSettings.ambientLight
    CS.UnityEngine.RenderSettings.ambientLight=CS.UnityEngine.Color.white

    self.boxScript=self.boxBtn.gameObject:GetComponent(typeof(CS.AnimationUICurve))
end



function LotteryPopup:GetSpecialStar()
    return  SPECIAL_STAR
end

function LotteryPopup:SetActive(isActive)
    self.go:SetActive(isActive)
    if not isActive then
        self:UnProgress()
        App:dispatchEvent({name = AppEvent.SHOW_LOTTERY_ANI})
    end
    --local busy =self.view.gameObject:GetComponent(typeof(CS.DBusy))
    --busy.layer.raycastTarget= isActive;
end

function LotteryPopup:SetTopActive(isActive)
    self.top.gameObject:SetActive(isActive)

end

local AnimationInternal=0.3

function LotteryPopup:EndAnimation()
    self:SetTopActive(true)
    local data=self.data
    local itemNum=self.propModel:GetPropItemNum(data.proId)
    --data.lottery_type=self.pbData.lottery_type
    --data.fee_type=self.pbData.fee_type
    --data.lottery_times=self.pbData.lottery_times
    --data.ships=ships
    --App:GetModel("LotteryModel"):DispatchLottery(data)  --抽奖信息
    if self.star==nil then
	    self.star = Star.New(self.ttlSummon.gameObject)
    end
  
    --self.result1.gameObject:SetActive(data.lottery_times==1)
    App:dispatchEvent({name = constModel("TutorialModel").TUTORIAL_STEP_NEXT})



    self.result2.gameObject:SetActive(data.lottery_times~=1)
    self.result3.gameObject:SetActive(data.lottery_times==1)
    if data.lottery_times==1 then

        local color=self.shipName.Text.color
        color.a=0
        self.shipName.Text.color=color
        color=self.shipDetails.Text.color
        color.a=0
        self.shipDetails.Text.color=color

        color=self.decLine.Image.color
        color.a=0
        self.decLine.Image.color=color

        self.shipName.Text.text=data.ships[1]:GetName()
        self.shipDetails.Text.text=lang(data.ships[1].baseShip.desc)

        --self.shipShow.go:SetActive(true)
        --self.shipShow.shipobj.gameObject.transform.localScale=CS.UnityEngine.Vector3.zero
        --local Tween=CS.DG.Tweening.DOTween
        --local tweenSeq=Tween.Sequence();
        --tweenSeq:Append(self.shipShow.shipobj.gameObject.transform:DOScale(CS.UnityEngine.Vector3.one, AnimationInternal))
        --if not self.showUI then
            --tweenSeq:AppendInterval(2); 
            --tweenSeq:AppendCallback(handler(self,self.ResumeLottery))
        --end
        --self.shipName.Text.text =lang(data.ships[1].baseShip.name)
        --self.star:SetStar(data.ships[1].baseShip.star)
        --
        local item=self:GetOneShip(data.ships[1])
        local go=item.go
        go.transform:SetParent(self.target.gameObject.transform,false)
        go.transform.position=self.center.gameObject.transform.position
        local Tween=CS.DG.Tweening.DOTween
        local animation = Tween.Sequence();

        animation:Append(go.transform:DOAnchorPos(CS.UnityEngine.Vector2.zero,AnimationInternal));
        animation:Join(go.transform:DOScale(CS.UnityEngine.Vector3.one, AnimationInternal));
        animation:AppendCallback(handler(item,item.AddBg));
        if data.ships[1].baseShip then
            if data.ships[1].baseShip.star>=SPECIAL_STAR then
                animation:Append(go.transform:DOPunchScale(CS.UnityEngine.Vector3.one/2,AnimationInternal,0.25,0.05));
            end
        end

        animation:AppendCallback(handler(item,item.SetIconVisible));
        animation:AppendCallback(handler(self,self.ShowOneInfo));



        --if data.ships[self.aniIndex].baseShip then
            --if  data.ships[index].baseShip.star>=SPECIAL_STAR then
                --animation:AppendCallback(self:handler(self,self.PauseAni,animation))
                --animation:AppendInterval(0.1); 
            --end
        --end


        if self.showUI then
            if itemNum>=1 then
                --self.oneDiamond.Image.sprite=App:GetResourceManager():GetCommon("summonIc0"..self.type)

                self.proId=self.model:GetProId(self.type)
                self.oneDiamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
                self.oneDiamondNum.Text.text=tostring(1)
            else
                if data.lottery_type==3 then  --点数抽奖
                    --self.oneDiamond.Image.sprite=App:GetResourceManager():GetResIcon(data.resOneValue.ctype)
                    --self.oneDiamondNum.Text.text=tostring(data.resOneValue.num[1][1])
                else
                    if data.resOneValue then
                        self.oneDiamond.Image.sprite=App:GetResourceManager():GetResIcon(data.resOneValue.ctype)
                        self.oneDiamondNum.Text.text=tostring(data.resOneValue.num[1][1])
                    else
                        if data.lottery_type==1 then
                            self.proId=self.model:GetProId(self.type)
                            self.oneDiamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
                            self.oneDiamondNum.Text.text=tostring(1)
                        end
                    end
                end
            end
        end

        self:InitUI() 
    else
        self.shipAniIndex=1
        if itemNum>=10 then
            self.diamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
            self.diamondNum.Text.text=tostring(10)
        else
            if data.resTenValue then
                self.diamond.Image.sprite=App:GetResourceManager():GetResIcon(data.resTenValue.ctype)
                self.diamondNum.Text.text=tostring(data.resTenValue.num[1][1])
            else
                if data.lottery_type==1 then
                    self.proId=self.model:GetProId(self.type)
                    self.diamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
                    self.diamondNum.Text.text=tostring(10)
                end
            end
        end

        local Tween=CS.DG.Tweening.DOTween


    

        local animation = Tween.Sequence();
        self.aniIndex=1 

        --for index=1,data.lottery_times do --抽奖次数
        for index=1,#data.ships do --抽奖次数
            if data.ships[index].baseShip then
                --if  data.ships[self.aniIndex].baseShip.star>=SPECIAL_STAR then
                if  data.ships[index].baseShip.star>=SPECIAL_STAR then
                    animation:AppendCallback(self:handler(self,self.PauseAni,animation))
                    animation:AppendInterval(0.2); 
                end
            end
            animation:AppendCallback(handler(self,self.AnimaitonOneShip));
            --animation:AppendInterval(AnimationInternal); 
            animation:AppendInterval(0.5); 
        end
        animation:AppendCallback(handler(self,self.InitUI));

    end
    
end

function  LotteryPopup:handler(obj, method,...)
    local param=...
    return function()
        return method(obj, param)
    end
end



function LotteryPopup:ResumeLottery()
    self.data.fun()
    --self:Close()
end


function LotteryPopup:PauseAni(ani)
    --print(CS.Util.GetTime(),"pause")
    if ani then
        ani:Pause();
    end
    local data={}
    data.lottery_type=self.data.lottery_type
    data.fee_type=self.data.fee_type
    data.lottery_times=1
    data.ships={self.data.ships[self.aniIndex]}
    data.showUI=false
    data.proId=self.data.proId
    data.resTenValue=self.data.resTenValue
    data.resOneValue=self.data.resOneValue
    data.fun=self:handler(self,self.ResumeAni,ani)
    --self.summonAnimation.gameObject:SetActive(false)
    self.lotteryShow:SetData(data)
    --App.game:navigateTo("scenes.game.lottery.LotteryPopup",data)
end


function LotteryPopup:ResumeAni(ani)
    --print("ResumeAni")
    if ani then
        ani:Play();
    else
        self:EndAnimation()
    end
end


local progressTime=1

function LotteryPopup:InitUI()
    self.endAni=true
    local data=self.data
    self.proId=data.proId
    local lotteryData=self.model.lotteryData

    --self.result1.gameObject:SetActive(data.lottery_times==1)
    --self.result2.gameObject:SetActive(data.lottery_times~=1)
    --self.result3.gameObject:SetActive(data.lottery_times==1)
    self.FXback.gameObject:SetActive(true)

    self.normalBtn.gameObject:SetActive(true and self.showUI)
    self.normalBtn2.gameObject:SetActive(data.lottery_times==1 and data.lottery_type~=3 and self.showUI)--一次
    self.goldBtn.gameObject:SetActive(data.lottery_times~=1 and self.showUI)--10次

    --self.summonProg.gameObject:SetActive(data.lottery_type~=1 and self.showUI)
    self.summonProg.gameObject:SetActive(true)

   if  data.lottery_type==2 then
       self.startTime=CS.Util.GetTime()
       --print(lotteryData.pb_pre_lottery_point,lotteryData.pb_high_lottery_point)
       self.progress.Slider.value=lotteryData.pb_pre_lottery_point
       self.progress.Slider:DOValue(lotteryData.pb_high_lottery_point,  progressTime)
       self.Text.Text.text=string.format('%d/%d',self.model.lotteryData.pb_pre_lottery_point,self.model.PointConsume)
       --self.boxBtn.Button.enabled=self.model.lotteryData.pb_high_lottery_point>=self.model.PointConsume
       self.timerPro=Timer.Schedule(0.1,handler(self,self.UpdateText)) 
   elseif data.lottery_type==3 then
       --self.progress.Slider.value=lotteryData.pb_high_lottery_point
       --self.Text.Text.text=string.format('%d/%d',self.model.lotteryData.pb_high_lottery_point,self.model.PointConsume)
   end
end




function LotteryPopup:UpdateText()
    local lotteryData=self.model.lotteryData
    local startNum=lotteryData.pb_pre_lottery_point
    local endNum=lotteryData.pb_high_lottery_point
    local currTime=CS.Util.GetTime()
    --print( startNum,endNum,(currTime-self.startTime))
    local value=(currTime-self.startTime)/progressTime
    if value>1 then
        value=1
    end
    local currValue=math.floor(Mathf.Lerp( startNum,endNum,value))


    self.Text.Text.text=string.format('%d/%d',currValue,self.model.PointConsume)
    self.boxScript.enabled=(currValue>=self.model.PointConsume)
    --print(currValue,"currValue")
    if value>=1 then
        self:UnProgress()
        if self.data.lottery_type==3 then
            self:StartAnimation()
        end
    end
end



function LotteryPopup:LotteryPoint()
    if not self.endAni then
        return 
    end
    if self.model.lotteryData.pb_high_lottery_point>=self.model.PointConsume then
        SendPacket("ReqLotteryAction", {lottery_type=3, fee_type=0, lottery_times=1})
    else
        if self.helpTip==nil then
            self.helpTip=HelpTip.New(self)
        end
        local pos=Vector3(self.boxBtn.RectTransform.position.x-2,self.boxBtn.RectTransform.position.y-2,self.boxBtn.RectTransform.position.z)
        self.helpTip:Show()
        self.helpTip:ShowTip(pos,99012)
    end
end

function LotteryPopup:UnProgress()
    if self.timerPro then
        Timer.Unschedul(self.timerPro )
        self.timerPro =nil
    end
end


function LotteryPopup:CreateGradient()
    local g= CS.UnityEngine.Gradient();

    --gck = new GradientColorKey[2];
    local gck ={} 
    gck[1]={}
    gck[1].color ={r=105,g=195,b=255};
    gck[1].time = 0.25;

    gck[2]={}
    gck[2].color = CS.UnityEngine.Color.white;
    gck[2].time = 1.0;

    --gak = new GradientAlphaKey[2];
    local gak ={}
    gak[1]={}
    gak[1].alpha = 1.0;
    gak[1].time = 0.0;
    gak[2]={}
    gak[2].alpha = 0.0;
    gak[2].time = 1.0;
    g:SetKeys(gck, gak);
    return g
end



function LotteryPopup:ShopShipTip(shipItem)
    if self.endAni then
        self.shipTipsPopup:Show()
        local shipdata = self.shipModel:GetShipDataByID(self.selectShipId)
        self.shipTipsPopup:SetData(shipItem.data)
    end
    
end


function LotteryPopup:GetOneShip(data)
    local go = App:GetResourceManager():GetPrefab("UI/Prefabs/common/shipItem.prefab")
    go = CS.UnityEngine.GameObject.Instantiate(go)
    local item = ShipItem.New(go,handler(self,self.ShopShipTip))
    item:SetData(data)
    item:SetIconVisible(false)
    item.AddBg=self.AddBg;
    item.shipImg.Image.material= App:GetResourceManager():GetMeterial("Effect/common/Materials/FXshipItem_shipImg.mat","")
    item.shipImg.gameObject:AddComponent(typeof(CS.VertIndexAsUV1))
    local script=item.shipImg.gameObject:AddComponent(typeof(CS.AnimationUICurve))
    script.Gradient=LotteryPopup:CreateGradient()
    script.changeColor=true
    item.quality.Image.material= App:GetResourceManager():GetMeterial("Effect/common/Materials/FXshipItem_quality.mat","")
    item.quality.gameObject:AddComponent(typeof(CS.VertIndexAsUV1))
    local script=item.quality.gameObject:AddComponent(typeof(CS.AnimationUICurve))
    script.Gradient=LotteryPopup:CreateGradient()
    script.changeColor=true
    local trans=go:GetComponent(typeof(CS.UnityEngine.RectTransform))
    trans.anchorMax=CS.UnityEngine.Vector2(0.5,0.5)
    trans.anchorMin=CS.UnityEngine.Vector2(0.5,0.5)
    trans.pivot=CS.UnityEngine.Vector2(0.5,0.5)
    --go.transform:SetParent(self['ship'..index].gameObject.transform,false)
    if self.center then
        go.transform.position=self.center.gameObject.transform.position
    end
    go.transform.localScale=CS.UnityEngine.Vector3.zero
    return item
end




function LotteryPopup:AnimaitonOneShip(flag)
    local data=self.data
    local index=self.aniIndex
    local go = App:GetResourceManager():GetPrefab("UI/Prefabs/common/shipItem.prefab")
    go = CS.UnityEngine.GameObject.Instantiate(go)

    local item = ShipItem.New(go,handler(self,self.ShopShipTip))
    item:SetData(data.ships[index])
    item:SetIconVisible(false)
    item.AddBg=self.AddBg;
    item:SetLongClickCallBack(handler(self,self.ShopShipTip))

    item.shipImg.Image.material= App:GetResourceManager():GetMeterial("Effect/common/Materials//FXshipItem_shipImg.mat","")
    item.shipImg.gameObject:AddComponent(typeof(CS.VertIndexAsUV1))
    local script=item.shipImg.gameObject:AddComponent(typeof(CS.AnimationUICurve))
    script.Gradient=LotteryPopup:CreateGradient()
    script.changeColor=true
    item.quality.Image.material= App:GetResourceManager():GetMeterial("Effect/common/Materials//FXshipItem_quality.mat","")
    item.quality.gameObject:AddComponent(typeof(CS.VertIndexAsUV1))
    local script=item.quality.gameObject:AddComponent(typeof(CS.AnimationUICurve))
    script.Gradient=LotteryPopup:CreateGradient()
    script.changeColor=true


    local trans=go:GetComponent(typeof(CS.UnityEngine.RectTransform))
    trans.anchorMax=CS.UnityEngine.Vector2(0.5,0.5)
    trans.anchorMin=CS.UnityEngine.Vector2(0.5,0.5)
    trans.pivot=CS.UnityEngine.Vector2(0.5,0.5)

    go.transform:SetParent(self['ship'..index].gameObject.transform,false)
    if self.center then
        go.transform.position=self.center.gameObject.transform.position
    end
    go.transform.localScale=CS.UnityEngine.Vector3.zero
    local Tween=CS.DG.Tweening.DOTween
    local animation = Tween.Sequence();
    if flag then
        animation:AppendCallback(handler(item,item.AddBg));
    end
    animation:Append(go.transform:DOAnchorPos(CS.UnityEngine.Vector2.zero,AnimationInternal));
    animation:Join(go.transform:DOScale(CS.UnityEngine.Vector3.one, AnimationInternal));
    if not flag then
        animation:AppendCallback(handler(item,item.AddBg));
    end
    if data.ships[index].baseShip then
        if data.ships[index].baseShip.star>= SPECIAL_STAR then
            animation:Append(go.transform:DOPunchScale(CS.UnityEngine.Vector3.one/2,AnimationInternal,0.25,0.05));
        end
    end


    animation:AppendCallback(handler(item,item.SetIconVisible));
    --animation:Insert(0,go.transform:DOScale(CS.UnityEngine.Vector3.one, 2));
    --animation:Prepend(go.transform:DOScale(CS.UnityEngine.Vector3.one, 0.1));
    --Insert(1, transform.DOMoveX(45, 1));
    self.aniIndex=self.aniIndex+1 

end



function LotteryPopup:AddBg()
    if self.data.baseShip.star>=SPECIAL_STAR  then
        local go = App:GetResourceManager():GetPrefab("UI/Prefabs/summon/Particle_shipItem.prefab")
        go = CS.UnityEngine.GameObject.Instantiate(go)
        go.transform:SetParent(self.go.transform.parent.transform,false)
        go.transform.localPosition=CS.UnityEngine.Vector3(0,0,0)
        return go
    end
end




function LotteryPopup:ShowOneInfo()

    self.shipName.Text.color=CS.UnityEngine.Color.white
    self.shipDetails.Text.color=CS.UnityEngine.Color.white
    self.decLine.Image.color=CS.UnityEngine.Color.white

    --self.shipName.Text:DOFade(1, 0.3)
    --self.shipDetails.Text:DOFade(1, 0.3)
    --self.decLine.Image:DOFade(1, 0.3)
end



function LotteryPopup:SetData(data)
    self:SetTopActive(false)
    self.endAni=false
    self:UnProgress()
    self.data=data
    if data.showUI==nil then
        self.showUI=true --是否显示动画以及ui
    else
        self.showUI=false
    end

    if self.lotteryShow==nil then
        self.lotteryShow=LotteryShow.New(self,self.popup.gameObject)
    end

    if data.lottery_times==1 then
        --[[if self.shipShow ==nil  then
            local prefab = App:GetResourceManager():GetPrefab("UI/Prefabs/ship/UILotteryShow.prefab")
            local go = CS.UnityEngine.GameObject.Instantiate(prefab)
            self.shipShow = ShipShow.New(go)
        end
        if data.ships[1] then
            self.shipShow:SetData(data.ships[1],true)
        end
        self.shipShow.go:SetActive(false)
        --]]
    end

    self.proId=data.proId
    self.type=data.lottery_type
    self.normalBtn.gameObject:SetActive(false)
    self.goldBtn.gameObject:SetActive(false)
    self.normalBtn2.gameObject:SetActive(false)
    self.summonProg.gameObject:SetActive(true)
    self.result1.gameObject:SetActive(false)
    self.result2.gameObject:SetActive(false)
    self.result3.gameObject:SetActive(false)
    self.summonAnimation.gameObject:SetActive(false)
    self.FXback.gameObject:SetActive(false)
    self.summonAnimation.gameObject:SetActive(true)
    self:InitResData()


    for i=1,20 do
        if self['ship'..i] ~=nil then
            self['ship'..i].gameObject.transform:DestroyAllChildren()
        else
            break;
        end
    end
    self.target.gameObject.transform:DestroyAllChildren()
    if not self.showUI then
        self.summonAnimation.gameObject:SetActive(false)
        self:EndAnimation()
    else
        if  data.lottery_type==3 then
            self.summonAnimation.gameObject:SetActive(false)
            local lotteryData=self.model.lotteryData
            self.startTime=CS.Util.GetTime()
            self.progress.Slider.value=lotteryData.pb_pre_lottery_point
            self.progress.Slider:DOValue(lotteryData.pb_high_lottery_point,  progressTime)
            self.Text.Text.text=string.format('%d/%d',self.model.lotteryData.pb_pre_lottery_point,self.model.PointConsume)
            self.timerPro=Timer.Schedule(0.1,handler(self,self.UpdateText)) 

        else
            self:StartAnimation()
        end
    end
end

function LotteryPopup:StartAnimation()
    self.summonAnimation.gameObject:SetActive(true)
    local data=self.data
    if data.lottery_times==1 then   
        if data.ships[1].baseShip then
            if data.ships[1].baseShip.star>=SPECIAL_STAR then
                self.aniIndex=1
                Timer.ScheduleOne(4.5,handler(self,self.PauseAni))
                return
            end
        end
    end
    Timer.ScheduleOne(4.5,handler(self,self.EndAnimation))
end



function LotteryPopup:InitResData()
    --self.gold.Text.text=NumberFormat(self.PlayerModel:GetResourceByType(AppConst.PRICE_TYPE.RES4))
    self.diamond.Text.text=NumberFormat(self.PlayerModel:GetResourceByType(AppConst.PRICE_TYPE.Gold))
    self.reelIc1.Image.sprite=App:GetResourceManager():GetPropIcon(self.model:GetProId(1))
    self.reelIc2.Image.sprite=App:GetResourceManager():GetPropIcon(self.model:GetProId(2))
    self.pro1.Text.text=tostring(self.propModel:GetPropItemNum(self.model:GetProId(1)))
    self.pro2.Text.text=tostring(self.propModel:GetPropItemNum(self.model:GetProId(2)))

    local lotteryData=self.model.lotteryData
    self.progress.Slider.value=lotteryData.pb_pre_lottery_point
    self.Text.Text.text=string.format('%d/%d',self.model.lotteryData.pb_pre_lottery_point,self.model.PointConsume)
end

function  LotteryPopup:UpdteView()

    local time=self.model:GetCd(self.type)
    local itemNum=self.propModel:GetPropItemNum(self.proId)

    if self.data.lottery_times==1 then

    end
    --奖券数量 一次
    if time>0 then 
        if  itemNum>0 then
            self.icon.Image.sprite=App:GetResourceManager():GetResIcon(self.model:GetProId(self.type))
            self.goldNum.Text.text=tostring(1)
        else
            if self.type==1 then
                self.icon.Image.sprite=App:GetResourceManager():GetResIcon(self.model:GetProId(self.type))
                self.goldNum.Text.text=tostring(1)
            else
                local data=self.model:GetConsumeData(self.type,1)
                self.icon.Image.sprite=App:GetResourceManager():GetResIcon(data.ctype)
                self.goldNum.Text.text=tostring(data.num[1][1])
            end
        end
    else

    end

    if  itemNum>=10 then
        self.diamond.Image.sprite=App:GetResourceManager():GetResIcon(self.model:GetProId(self.type))
        self.diamondNum.Text.text=tostring(10)
    else
        if self.type==1 then
            self.diamond.Image.sprite=App:GetResourceManager():GetResIcon(self.model:GetProId(self.type))
            self.diamondNum.Text.text=tostring(10)
        else
            local data=self.model:GetConsumeData(self.type,10)
            self.diamond.Image.sprite=App:GetResourceManager():GetResIcon(data.ctype)
            self.diamondNum.Text.text=tostring(data.num[1][1])
        end
    end
end

function LotteryPopup:Buy()
    --self:Close()
    self.data.fun() 

end

function LotteryPopup:OnShow()
end


function LotteryPopup:UnActive()
    --self.data.unFun()
    --self:Close()
    self:SetActive(false)
end


function LotteryPopup:OnBack()
    --self:Close()
    self:SetActive(false)
end



function LotteryPopup:Close()
    self:UnProgress()
    if self.shipShow then
        self.shipShow:Destroy()
        self.shipShow=nil
    end
    CS.UnityEngine.RenderSettings.ambientLight=self.preAmbientLight
    App:dispatchEvent({name = AppEvent.SHOW_LOTTERY_ANI})
end

return LotteryPopup
