

local LotteryShow = Class("LotteryShow",require("components.ViewController"))
local LotteryShowView = Class("LotteryShowView",require("components.View"))
local AppEvent = const("AppEvent")
local Tween=CS.DG.Tweening.DOTween
local yield_return = (require 'utils.cs_coroutine').yield_return
local ShipShow = require("scenes.game.ship.ShipShow")

-------------------------------home----------------------------------
function LotteryShowView:ctor(ctrl,obj)
    LotteryShowView.super.ctor(self,ctrl)
    self.go=obj
    local LuaBehaviour = self.go:GetComponent(typeof(CS.LuaGameObjectHelper))
    LuaBehaviour:loadGameObjects(self)
    self:SetActive(false)
end


function LotteryShowView:SetActive(isActive)
    self.go:SetActive(isActive)
end

function LotteryShowView:SetData(data)
    self:SetActive(true)
    self.data=data
    local material= self.popupbg.Image.material
    material:SetFloat("_Alpha",0)
    Tween.To( function() material:GetFloat("_Alpha") end, function(x) material:SetFloat("_Alpha",x) end, 2, 1.7);
    self.ParticleOneShip.gameObject:SetActive(false)
    Timer.ScheduleOne(0.3,handler(self,self.StartEffect))
end


function  LotteryShowView:ShowShip(shipData)
	self.ship.gameObject:RemoveAllChildren()
    --local co = coroutine.create(function()
        --yield_return(CS.UnityEngine.WaitForEndOfFrame())
        self.shipModel = App:GetResourceManager():GetWarShipMould(shipData.baseShip.modle)
        self.shipModel.transform:SetParent(self.ship.gameObject.transform, false)
        local hangBone = self.shipModel:GetComponent(typeof(CS.CharacterHangBone))
        if hangBone~=nil then
            hangBone:ShowTrail(false)
            self.shipModel.transform.localScale = hangBone.UIScaleSize*64
        end
        local targetScale=self.shipModel.transform.localScale
        self.shipModel:SetLayerRecursively("UI")
        self.shipModel.transform.localPosition=CS.UnityEngine.Vector3(0,-20,-300)
        self.shipModel.transform.rotation=CS.UnityEngine.Quaternion.Euler(CS.UnityEngine.Vector3(15,251,22));
        self.shipModel.transform.localScale=CS.UnityEngine.Vector3.zero
        local Tween=CS.DG.Tweening.DOTween
        local tweenSeq=Tween.Sequence();
        tweenSeq:Append(self.shipModel.transform:DOScale(targetScale, 0.5))

        if not self.showUI then
            tweenSeq:AppendInterval(1); 
            tweenSeq:AppendCallback(handler(self,self.ResumeLottery))
        end

        --[[local renders=self.shipModel:GetComponentsInChildren(typeof(CS.UnityEngine.Renderer))
        local material=App:GetResourceManager():GetMeterial("Avatar/Particle/FX_Resources/Shaders/P_Melt.mat","")
        material:SetFloat("_Slider",0)
        material:SetFloat("_Glow",3.5)
        material.color=CS.UnityEngine.Color(17/255,97/255,1,1)
        --material:SetTexture("_Mack",)
        for i=0,renders.Length-1 do
            local curr=CS.UnityEngine.Material(material);
            curr.mainTexture=renders[i].sharedMaterial.mainTexture
            renders[i].sharedMaterial=curr
            Tween.To( function() curr:GetFloat("_Slider") end, function(x)  curr:SetFloat("_Slider",x) end, 1, 1.5);
        end]]



        local changeMaterialShader =self.shipModel:GetOrAddComponent(typeof(CS.ChangeMaterialShader))
        changeMaterialShader:ChangeShaderMyFile("Avatar/Particle/FX_Resources/Shaders/P_Melt")
        changeMaterialShader:SetShaderColor("_Color",CS.UnityEngine.Color(17/255,97/255,1,1))
        changeMaterialShader:SetShaderFloat("_Slider",0)
        changeMaterialShader:SetShaderFloat("_Glow",3.5)
        changeMaterialShader.time = 1.5
        changeMaterialShader:Play(false)   


    --end)
    --assert(coroutine.resume(co))
end



function LotteryShowView:ResumeLottery()
    self.data.fun()
    self:SetActive(false)
	self.ship.gameObject:RemoveAllChildren()
end


function LotteryShowView:StartEffect()
    self.ParticleOneShip.gameObject:SetActive(true)
    self:ShowShip(self.data.ships[1])
end


function LotteryShowView:OnBack()

end

function LotteryShowView:OnExit()
    LotteryShowView.super.OnExit(self)
end
return LotteryShowView 
