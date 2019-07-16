local ResBar = require("scenes.game.common.TitleBar")
local LotteryItem = Class("LotteryItem")
local HelpTip=require("scenes.game.help.HelpTip")


local LotteryView = Class("LotteryView",require("components.View"))
local LotteryTop = require("scenes.game.lottery.LotteryTop")
-- local LotteryPop=require("scenes.game.lottery.LotteryPopup")



local LotteryModel = App:GetModel("LotteryModel")
local PropsModel = App:GetModel("PropsModel")
local PlayerModel = App:GetModel("PlayerModel")

local OtherModel = App:GetModel("OtherModel")



local AppEvent = const("AppEvent")
local AppConst = const("AppConst")


function LotteryItem:ctor(delegate,gameObject,type)
    self.gameObject=gameObject
    self.type=type
    self.delegate=delegate
    self.shipModel = App:GetModel("ShipModel")
    self.proId=LotteryModel:GetProId(type)
	local LuaBehaviour = gameObject:GetComponent(typeof(CS.LuaGameObjectHelper))
	LuaBehaviour:loadGameObjects(self)
    self:UpdteView()
end


function LotteryItem:InitData()
    self.userTypeOne=0  --一次使用的道具类型
    self.userTypeTen=0  
    self.resOne=true  --抽一次道具是否足够
    self.resTen=true
    self.resOneValue=nil
    self.resTenValue=nil
end



function LotteryItem:UpdteView()
    self:InitData()
    local time=LotteryModel:GetCd(self.type)
    self.noFree.gameObject:SetActive(time>0)
    self.btnText.gameObject:SetActive(time<=0)


    if self.type==1 then --普通
        self.barBg.gameObject:SetActive(true)
        if time>0 then
            self.countDown.Text.text=lang('LotteryCountDown',TimeUtil.getSeconds2String(time,"%H:%M:%S"))
        else
            local maxNum=App:GetModel("CityModel"):GetSumEffect(99020)
            self.countDown.Text.text=lang('dailyfree', maxNum-OtherModel:GetDailyDataCountByType(AppConst.Daily_Count_Type.tdyNormalLotteryFreeTimes), maxNum)
        end
    else
        self.barBg.gameObject:SetActive(time>0)
        self.countDown.Text.text=lang('LotteryCountDown',TimeUtil.getSeconds2String(time,"%H:%M:%S"))
    end


    local itemNum=PropsModel:GetPropItemNum(self.proId)
    --奖券数量 一次
    if time>0 then --未冷却 
       if  itemNum>0 then
            self.icon.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
            self.goldNum.Text.text=tostring(1)
            self.resOne = true  --道具够
            self.userTypeOne=3  -- 道具
       else
           
            if self.type==1 then --普通
                self.icon.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
                self.goldNum.Text.text=tostring(1)
                self.resOneValue=nil
                self.resOne=false   
                self.userTypeOne=3  --道具
            else  --高级
                local data=LotteryModel:GetConsumeData(self.type,1)
                self.icon.Image.sprite=App:GetResourceManager():GetResIcon(data.ctype)
                self.goldNum.Text.text= NumToFormatString(data.num[1][1])
                self.resOne=PlayerModel:GetResourceByType(data.ctype) >=data.num[1][1]
                self.resOneValue=data
                self.userTypeOne=AppConst.PRICE_TYPE.Gold  --钻石
            end
       end
    else
        self.userTypeOne=0  --时间
    end

   if  itemNum>=10 then
       self.diamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
       self.diamondNum.Text.text=tostring(10)
        self.resTen=true
       self.userTypeTen=3
   else
       if self.type==1 then
           self.diamond.Image.sprite=App:GetResourceManager():GetPropIcon(self.proId)
           self.diamondNum.Text.text=tostring(10)
           self.resTen=false
           self.resTenValue=nil
           self.userTypeTen=3
       else
           local data=LotteryModel:GetConsumeData(self.type,10)
           self.diamond.Image.sprite=App:GetResourceManager():GetResIcon(data.ctype)
           self.diamondNum.Text.text= NumToFormatString(data.num[1][1])
           self.resTen=PlayerModel:GetResourceByType(data.ctype) >=data.num[1][1]
           self.resTenValue=data
           self.userTypeTen=AppConst.PRICE_TYPE.Gold
       end
   end
end

--enum FeeType { FREE = 0; 	//免费 PROP = 3; 	//道具 RES_4 = 14; //资源4 GOLD = 99;	//金币 }
function  LotteryItem:One()
    if not self.delegate.isInitClick then
        return
    end
    if #self.shipModel.MyShipDataList+1<= self.shipModel:GetShipMax() then
        if self.resOne then
            if self.delegate:StartRequest() then
                SendPacket("ReqLotteryAction", {lottery_type=self.type, fee_type=self.userTypeOne, lottery_times=1})
            end
        else
            self:ShowOutRes()
        end
    else
        self:ShipCapacity(handler(self,self.One))
    end
end


function  LotteryItem:Ten()
    if not self.delegate.isInitClick then
        return
    end
    if #self.shipModel.MyShipDataList+10<= self.shipModel:GetShipMax() then
        if self.resTen then
            if self.delegate:StartRequest() then
                SendPacket("ReqLotteryAction", {lottery_type=self.type, fee_type=self.userTypeTen, lottery_times=10})
            end
        else
            self:ShowOutRes()
        end
    else
        self:ShipCapacity(handler(self,self.Ten))
    end
end


function  LotteryItem:ShowOutRes()
    if  self.type==1 then
        toast(lang('OutOfResource'))
    else
        toast(lang('Turnerr2'))
    end
end

function  LotteryItem:ShipCapacity(fun)
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
    self.delegate:SetBuyCallBack(fun)
end



-------------------------------home----------------------------------

function LotteryView:ctor(ctrl)
    LotteryView.super.ctor(self,ctrl)
    local go = App:GetResourceManager():GetPrefab("UI/Prefabs/summon/summon.prefab")
    local view = App:GetGUIManager():PushView(go,self,self)
    self.lotteryPanel={}
    self.handle  = Timer.Schedule(1,handler(self,self.UpTime)) 
    self.isInitClick=false
    if not App:GetModel("TutorialModel").isplay then
        self.handle2  = Timer.ScheduleOne(2,function()self.isInitClick=true end)
    else
        self.isInitClick=true
    end
    -- self.boxScript=self.boxBtn.gameObject:GetComponent(typeof(CS.AnimationUICurve))
    self.isInRequest=false
    self:InitView()
end


function LotteryView:StartRequest()
    if self.isInRequest then
        return false
    else
        self.isInRequest=true
        self.requestHandler=Timer.ScheduleOne(1,function() self.isInRequest=false end)
        return true
    end
end



function LotteryView:UpTime()
   for i,v in pairs(self.lotteryPanel) do 
       v:UpdteView()
   end
end

function LotteryView:BuyCapacitySuccess()
    self:UpTime()
    if self.capacityCallback then
        self.capacityCallback()
        self.capacityCallback=nil
    end
end

function LotteryView:SetBuyCallBack(fun)
    self.capacityCallback=fun
end

 

--显示兑换界面
function LotteryView:ShowChange()
    self:GetCtrl():GetGame():navigateTo(constModel("NavigateModel").NAV_CHANGE,{shopType=1})
end




--去资源管理界面
function LotteryView:OnResManagerClick()
    self:GetCtrl():GetGame():navigateTo(constModel("NavigateModel").NAV_RESMANAGER)
end


function LotteryView:ShowLottery(event)
    local data = event.data
    self.node.gameObject:SetActive(false)
    self.summonAnimation.gameObject:SetActive(true)
    self.lotteryTop:Show(false)
    self:SetEnablePartical(false) 
    self.lotteryTop:SetBackEnable(false)
    function ShowResult()
        local popup = require("scenes.game.lottery.LotteryResultPopup").New(self)
        popup:Show()
        popup:SetData(data)
        self.lotteryTop:Show(true)
    end
    self.aniTimer=Timer.ScheduleOne(4.5,ShowResult)
end


function LotteryView:EndShowLottery(value)
    self.node.gameObject:SetActive(value)
    self.summonAnimation.gameObject:SetActive(false)
    self:SetEnablePartical(true) 
    self.lotteryTop:SetBackEnable(true)
end


--帮助按钮

function LotteryView:OnShowTip()
    local helpTip=HelpTip.New(self)
    local pos=Vector3(self.sign.RectTransform.position.x-2,self.sign.RectTransform.position.y-2,self.sign.RectTransform.position.z)
    helpTip:Show()
    helpTip:ShowTip(pos,99012)
end


function LotteryView:SetEnablePartical(isEnable)
    if isEnable==null then
        isEnable=true
    end
    LotteryModel:SetInLottAni(not isEnable)
    self.FX_boxBtn_lan.gameObject:SetActive(isEnable)
    self.FX_boxBtn_huang.gameObject:SetActive(isEnable)
end


function LotteryView:InitView()
    self.lotteryPanel[1]=LotteryItem.New(self,self.normal.gameObject,1)
    self.lotteryPanel[2]=LotteryItem.New(self,self.senior.gameObject,2)
    self.lotteryTop = LotteryTop.New(self)
end




function LotteryView:OnEnter()
    self:Binding(LotteryModel, self, self.ShowLottery, AppEvent.Lottery)
    self:Binding(App, self, self.SetEnablePartical, AppEvent.SHOW_LOTTERY_ANI)
    self:Binding(PlayerModel, self, self.BuyCapacitySuccess, AppEvent.PLAYER_BUY_SHIP_MAX)
end

function LotteryView:OnExit()
    LotteryView.super.OnExit(self)
    Timer.Unschedul(self.handle)
    App:GetGUIManager():PopNavigation()
    if self.aniTimer then
        Timer.Unschedul(self.aniTimer)
    end

    if self.requestHandler then
        Timer.Unschedul(self.requestHandler)
    end

    if self.handle2 then
        Timer.Unschedul(self.handle2)
    end

    self.lotteryTop = nil

end


return LotteryView
