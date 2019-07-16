local DefenceAssist = Class("DefenceAssist")


function DefenceAssist:ctor(parent,isLeft,delegate)
    self.chatModel=App:GetModel("ChatModel")
    self.allyModel=App:GetModel("AllyModel")
    local cellPrefab = ASSIST_RIGHT_PATH
    if isLeft == true then
        cellPrefab = ASSIST_LEFT_PATH
    end
    self.delegate = delegate
    self.go =App:GetResourceManager():Spawn(cellPrefab)      
    local LuaBehaviour = self.go:GetComponent(typeof(CS.LuaGameObjectHelper))
    LuaBehaviour:loadGameObjects(self)
    if parent then
        self.go:SetParent(parent,false)
        local rt = parent:GetComponent(typeof(CS.UnityEngine.RectTransform))
        rt:SetSizeWithCurrentAnchors(630,120)
    end
    self.dec=self.decText.gameObject:GetComponent(typeof(CS.LinkImageText))
    self.decAssis=self.decTextAssis.gameObject:GetComponent(typeof(CS.LinkImageText))
end

function DefenceAssist:SetData(data)
    self.data=data
    local params=string.split(data.pb_m_wzMsg, ",")
    self.params=params
    local name=data.pb_m_wzSenderName
    self.headImg.Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nSenderPicID)
    local chatType=data.pb_m_nMsgType
    self.headBg.gameObject:SetActive(chatType>=11 and chatType<=16)
    self.header.gameObject:SetActive(not (chatType>=11 and chatType<=16))
    if data.pb_m_nMsgType>=11 and data.pb_m_nMsgType<=12 then
        if not tonumber(params[1]) then
            params[1]=0
        end
        self.headIcon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..data.pb_m_nMsgType)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
        local info=lang("ChatShare"..data.pb_m_nMsgType,params[2],self.posX,self.posY)
        if data:IsInAlly() then
            info='['..data.pb_m_wzSenderAllyShortName..']'..info
        end
        self.dec.text=info
        self.decAssis.text=lang("ShareTip",data.pb_m_wzSenderName)

    elseif data.pb_m_nMsgType==32 then --科技升级
        local techData=self.allyModel:GetTechData(tonumber(params[1]))
        self.Icon.Image.sprite=App:GetResourceManager():GetAllyTechIcon(techData.image)
        local params=string.split(data.pb_m_wzMsg, ",")
        self.dec.text=lang("AllyTechUpChat",lang(techData.name))
        self.decAssis.text=lang("AllyTechUpTip")
    elseif data.pb_m_nMsgType>=13 and data.pb_m_nMsgType<=16 then
        if not tonumber(params[1]) then
            params[1]=0
        end
        self.headIcon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..data.pb_m_nMsgType)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
        local info=lang("ChatShare"..data.pb_m_nMsgType,self.posX,self.posY)
        self.dec.text=info
        self.decAssis.text=lang("ShareTip",data.pb_m_wzSenderName)
    elseif data.pb_m_nMsgType==20 then --战报分享
        --20=战报分享           用户id,title, 地图编号,战役类型（0＝单人，1＝联合攻击）,攻防类型（1＝攻击，2＝防御）,对方玩家名称,对方玩家联盟简称,对面图片，战报编号
        if not tonumber(params[3]) then
            params[3]=0
        end
        self.Icon.Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nSenderPicID)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[3]))
        self.dec.text=params[2]
        self.decAssis.text=lang("ReportShareTip",data.pb_m_wzSenderName)
    elseif data.pb_m_nMsgType==37 then --侦察分享 --37=侦察分享         用户id,title,战报编号
        if not tonumber(params[3]) then
            params[3]=0
        end
        self.Icon.Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nSenderPicID)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[3]))
        self.dec.text=params[2]
        self.decAssis.text=lang("ScoutShareTip",data.pb_m_wzSenderName)
    elseif data.pb_m_nMsgType==35 then --35=岛屿建筑维修求助 地图编号,建筑编号ID,建筑类型编号GID,当前等级
        if not tonumber(params[1]) then
            params[1]=0
        end
        self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..16)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
        local model=App:GetModel("MapIslandModel")
        local info=lang("RepairShare",lang(model:GetBuildData(tonumber(params[3])).name),tonumber(params[4]),self.posX,self.posY)
        self.dec.text=info
        self.decAssis.text=lang("RepairShareTip",data.pb_m_wzSenderName)
     elseif data.pb_m_nMsgType==36 then --36=岛屿建筑维修求助 地图编号,建筑编号ID,建筑类型编号GID,当前等级,已有舰队数量,舰队上限
        if not tonumber(params[1]) then
            params[1]=0
        end
        self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..16)
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
        local model=App:GetModel("MapIslandModel")
        local info=lang("AllyAssistShare",lang(model:GetBuildData(tonumber(params[3])).name),self.posX,self.posY,params[5],params[6])
        self.dec.text=info
        self.decAssis.text=lang("AllyAssistShareTip",data.pb_m_wzSenderName)
    elseif data.pb_m_nMsgType==40 then --40  --40 uid ,seq,gid,rank,grede,name  --舰船分享
        local shipModel=App:GetModel("ShipModel")
        local baseShip=shipModel:GetShipDataByID(tonumber(params[3]))
        App:GetResourceManager():LoadShipIcon(baseShip.pic_head, self.Icon.Image)
        local info=lang("ShipShareTip",data.pb_m_wzSenderName,params[6]..baseShip.star)
        self.dec.text=info
        self.decAssis.text=""
    else
        self.posX,self.posY=MapModel:GetMapPos(tonumber(params[4]))
        self.dec.text=lang("AssistDefenceText",data.pb_m_wzSenderName,params[4],params[3],self.posX,self.posY)
        self.decAssis.text=lang("AssistDefenceText2",data.pb_m_wzSenderName)
    end

end


function DefenceAssist:Goto()
    App.game:OnEnterMap( self.posX,self.posY)
end

function DefenceAssist:Assist()
    print("Assist__TARGET")
end

function DefenceAssist:Check ()
    if self.data.pb_m_nMsgType==20 then
        local model= MailModel:CretetMailData()
        model.pb_seqno=tonumber(self.params[9])
        model.pb_rpt_type=401
        self.delegate.wt.delegate.mailDetail:ShowDetail(model,self.typeIndx)
    elseif self.data.pb_m_nMsgType==37 then
        local model= MailModel:CretetMailData()
        model.pb_seqno=tonumber(self.params[4])
        model.pb_rpt_type=404
        self.delegate.wt.delegate.mailDetail:ShowDetail(model,self.typeIndx)
    elseif self.data.pb_m_nMsgType==32 then
        App.game:navigateTo(constModel("NavigateModel").NAV_ALLY_TECH)
    elseif self.data.pb_m_nMsgType==40 then
        --40 uid ,seq,gid,rank,grede,name  --舰船分享
        local shipData=App:GetModel("ShipModel"):CreateShipDataByInfo(tonumber(self.params[3]),tonumber(self.params[5]),tonumber(self.params[4]),self.params[6])
        shipData.pb_status=-1
        if not self.shipTipsPopup then
            self.shipTipsPopup = ShipTipsPopup.New()
        end
        self.shipTipsPopup:Show()
        self.shipTipsPopup:SetData(shipData)
    end
end

function DefenceAssist:AllyAssist()
    print("Check")
end

function DefenceAssist:Repair()
    print("Repair")
end


return DefenceAssist
