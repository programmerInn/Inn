--聊天
local ChatView = Class("ChatView")
local ShipTipsPopup = require("scenes.game.ship.ShipTips")
local DefenceAssist= require("scenes.game.chatnew.DefenceAssist")
local TimeBar = Class("TimeBar")
local CharBar = Class("CharBar")
local ChatInfoCell = Class("ChatInfoCell")
local MailModel=App:GetModel("MailModel")
local MailDetail= require("scenes.game.mail.MailDetail")
local ChatModel = App:GetModel("ChatModel")
local MapModel=App:GetModel("MapModel")

local AppEvent = const("AppEvent")

local lang = require("utils.LangsUtil")
local language = lang.language


local Nav_Type = {
    World_Chat = 1,
    Ally_Chat = 2,
    Group_Chat = 3,
    Friend_Chat = 4
}








---------------------------------CharBar-----------------------------------------
function CharBar:ctor(cellPrefab,delegate)
    cellPrefab.LuaTable = self
    self.delegate = delegate
    self.rt = cellPrefab:GetComponent(typeof(CS.UnityEngine.RectTransform))
    self.bgRt = self.chatBg.RectTransform
    self.go = cellPrefab.gameObject
    self.chatText1 =  self.chatText.gameObject:GetComponent(typeof(CS.LinkImageText))
end


function CharBar:UpDataView()
    local isLeft = self.isLeft
        if isLeft then
            local scale = Vector3(-1,1,1)
            self.rt.localScale = scale
            self.vipNode.RectTransform.localScale = scale
            self.headImg.RectTransform.localScale = scale
            self.playerName.RectTransform.localScale = scale
            self.chatText.RectTransform.localScale = scale
            self.Icon.RectTransform.localScale = scale
            self.chatText1.alignment = CS.UnityEngine.TextAnchor.UpperLeft
            self.playerName.Text.alignment = CS.UnityEngine.TextAnchor.MiddleRight
            self.chatBg.Image.sprite = App:GetResourceManager():GetSocialTextrue("myChat")
        else
            local scale = Vector3(1,1,1)
            self.rt.localScale = scale
            self.vipNode.RectTransform.localScale = scale
            self.headImg.RectTransform.localScale = scale
            self.playerName.RectTransform.localScale = scale
            self.chatText.RectTransform.localScale = scale
            self.Icon.RectTransform.localScale = scale
            self.chatText1.alignment = CS.UnityEngine.TextAnchor.UpperLeft
            self.playerName.Text.alignment = CS.UnityEngine.TextAnchor.MiddleLeft
            self.chatBg.Image.sprite = App:GetResourceManager():GetSocialTextrue("otherChat")
        end
end


function CharBar:SetData(data,idx)
    self.idx=idx
    if data ==nil then return end
    local isTime = type(data)=="string"
    self.chatNode.gameObject:SetActive(not isTime)
    self.timeChat.gameObject:SetActive(isTime)
    self.header.gameObject:SetActive(false)

    --本机发送
    self.isMySend= data.pb_m_nSenderID==App:GetModel("PlayerModel"):GetUID()

    local isLeft = data.pb_m_nSenderID==App:GetModel("PlayerModel"):GetUID()
    if isLeft~=self.isLeft then
        self.isLeft = isLeft
        self:UpDataView()
    end
    self.data=data
    if isTime then
        self.time.Text.text=data
        return
    end

    self.menu.gameObject:SetActive(false)
    self.translate.gameObject:SetActive(false)
    if data.pb_m_nMsgType==50 then --联盟援防信息
        self.linkType=nil
        self.linkValue=nil
        local titleParam=string.split(data.pb_m_wzMsg, ",")
        local id=tonumber(titleParam[1])
        local titlePrime=lang(id)
        local valueParam=string.split(titleParam[2],"|")
        for index,paramPair in pairs(valueParam) do
            local valuePair=string.split(paramPair,";")
            local typeParam=tonumber(valuePair[1])
            local valuepara1=valuePair[2]
            if typeParam==3 then 
                valuepara1=lang(tonumber(valuePair[2]))
            elseif typeParam==4 or typeParam==5 then
                valuepara1=valuePair[2]
            end
            if  valuepara1~=nil then
                if titlePrime then
                    titlePrime = string.gsub(titlePrime, string.format("{%d}",index-1), valuepara1) 
                else
                    titlePrime=tostring(id)
                end
            end
        end
        if #titleParam>2 and titleParam[3]~='' then
            local valueParam=string.split(titleParam[3],"|")
            self.linkType=tonumber(valueParam[1])
            self.linkValue=tonumber(valueParam[2])
            if self.linkType==2 then
                titlePrime=titlePrime.."\n"..lang("GotoLink")
            end
        end
        self.chatText1.text=titlePrime
    elseif data.pb_m_nMsgType~=0 then --联盟援防信息
        local params=string.split(data.pb_m_wzMsg, ",")
        self.params=params
        if data.pb_m_nMsgType>=11 and data.pb_m_nMsgType<=12 then  --地点分享
            local name=data.pb_m_wzSenderName
            self.headImg.Image.sprite=App:GetResourceManager():GetPlayHeadIconSmall(data.pb_m_nSenderPicID)
            self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..data.pb_m_nMsgType)
            self.header.gameObject:SetActive(true)

            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
            local info=lang("ChatShare"..data.pb_m_nMsgType,params[2],self.posX,self.posY)
            if data:IsInAlly() then
                info='['..data.pb_m_wzSenderAllyShortName..']'..info
            end
            self.chatText1.text=info.."\n"..lang("ShareTip",data.pb_m_wzSenderName)
        elseif data.pb_m_nMsgType==32 then --科技升级
            local techData=App:GetModel("AllyModel"):GetTechData(tonumber(params[1]))
            self.Icon.Image.sprite = App:GetResourceManager():GetAllyTechIcon(techData.image)
            self.header.gameObject:SetActive(true)
            self.chatText1.text=lang("AllyTechUpChat",lang(techData.name))--.."\n"..lang("AllyTechUpTip")
        elseif data.pb_m_nMsgType>=13 and data.pb_m_nMsgType<=16 then --地点分享

            self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..data.pb_m_nMsgType)
            self.header.gameObject:SetActive(true)
            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
            local info=lang("ChatShare"..data.pb_m_nMsgType,self.posX,self.posY)
            self.chatText1.text=info.."\n"..lang("ShareTip",data.pb_m_wzSenderName)


        elseif data.pb_m_nMsgType==20 then --战报分享
            self.Icon.Image.sprite=App:GetResourceManager():GetPlayHeadIconSmall(data.pb_m_nSenderPicID)
            self.header.gameObject:SetActive(true)
            self.chatText1.text=params[2].."\n"..lang("ScoutShareTip",data.pb_m_wzSenderName)

        elseif data.pb_m_nMsgType==34 then --联盟援防求助			地图编号,目标类型（1=玩家城池，其他待定）,战役类型（0＝单人，1＝联合攻击）,对方玩家名称,对方玩家联盟简称,对方战力（0=未知)
            self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..16)
            self.header.gameObject:SetActive(true)
            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
            local mapModel=App:GetModel("MapIslandModel")
            local info=""
            if params[5]~="" then
                info='['..params[5]..']'..info
            end
            info=lang("AssistShare",params[4],self.posX,self.posY)
            self.chatText1.text=info.."\n"..lang("AssistShareTip",data.pb_m_wzSenderName)
        elseif data.pb_m_nMsgType==35 then --35=岛屿建筑维修求助 地图编号,建筑编号ID,建筑类型编号GID,当前等级
            self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..16)
            self.header.gameObject:SetActive(true)
            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
            local mapModel=App:GetModel("MapIslandModel")
            self.repairId=tonumber(params[2]);
            local info=lang("RepairShare",lang(mapModel:GetBuildData(tonumber(params[3])).name),tonumber(params[4]),self.posX,self.posY)
            self.chatText1.text=info.."\n"..lang("RepairShareTip",data.pb_m_wzSenderName)
        elseif data.pb_m_nMsgType==36 then --36=岛屿建筑援防求助	 地图编号,建筑编号ID,建筑类型编号GID,当前等级,已有舰队数量,舰队上限
            self.Icon.Image.sprite=App:GetResourceManager():GetSocialTextrue("chatIcon"..16)
            self.header.gameObject:SetActive(true)
            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[1]))
            self.assistId=tonumber(params[2])
            local info=lang("AllyAssistShare",lang(App:GetModel("MapIslandModel"):GetBuildData(tonumber(params[3])).name),self.posX,self.posY,params[5],params[6])
            self.chatText1.text=info.."\n"..lang("AllyAssistShareTip",data.pb_m_wzSenderName)
        elseif data.pb_m_nMsgType==37 then --侦察分享 --37=侦察分享			用户id,title,战报编号
            --37=战报分享			用户id,title,坐标，战报编号
            if not tonumber(params[3]) then
                params[3]=0
            end
            self.Icon.Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nSenderPicID)
            self.header.gameObject:SetActive(true)
            self.posX,self.posY=MapModel:GetMapPos(tonumber(params[3]))
            self.chatText1.text=params[2]..lang("ScoutShareTip",data.pb_m_wzSenderName)
        elseif data.pb_m_nMsgType==40 then --40  --40 uid ,seq,gid,rank,grede,name  --舰船分享
            local shipModel=App:GetModel("ShipModel")
            local baseShip=shipModel:GetShipDataByID(tonumber(params[3]))
            App:GetResourceManager():LoadShipIcon(baseShip.pic_head, self.Icon.Image)

            local info=lang("ShipShareTip",data.pb_m_wzSenderName,params[6]..baseShip.star)
            self.chatText1.text=info
            self.header.gameObject:SetActive(true)
        end
    else
        if not self.isLeft  then
            if data.isTrans  then
                self.translate.Image.sprite=App:GetResourceManager():GetCommonUI("translateIc02")
            else
                self.translate.Image.sprite=App:GetResourceManager():GetCommonUI("translateIc01")
            end
            self.translate.gameObject:SetActive(true)
        end
        if data.isTrans then
            self.chatText1.text=data.transText
        else
            self.chatText1.text=data.pb_m_wzMsg
        end
        self.menu.gameObject:SetActive(true)
    end
    self.vipNode.gameObject:SetActive(data.pb_m_nSenderVIPGrade~=-1)
    self.vipNum.Text.text=tostring(data.pb_m_nSenderVIPGrade)

    --self.translate.gameObject:SetActive(false)
    --

    if self.delegate:GetCurrLan()==self.data.pb_m_wzLanguage then
        self.translate.gameObject:SetActive(false)
    end


    local name=data.pb_m_wzSenderName
    if data:IsInAlly() then
        name='['..data.pb_m_wzSenderAllyShortName..']'..name
    end
    self.headImg.Image.sprite=App:GetResourceManager():GetPlayHeadIconSmall(data.pb_m_nSenderPicID)
    self.playerName.Text.text=name

    local w = self.chatText1.preferredWidth

    if w>285 or (data.pb_m_nMsgType~=0 and data.pb_m_nMsgType~=50) then
        w = 285
    end
    self.chatText.RectTransform:SetSizeWithCurrentAnchors(w,self.chatText1.preferredHeight)
    if data.pb_m_nMsgType==0 or data.pb_m_nMsgType==50 then
        self.bgRt:SetSizeWithCurrentAnchors(w+30,self.chatText1.preferredHeight+20)
    else
        self.bgRt:SetSizeWithCurrentAnchors(410,110)
    end
    return self.chatText1.preferredHeight;
    --self.chatText1.text=self.chatText1.text..'type'..data.pb_m_nMsgType
end


function CharBar:Goto()
    if self.data.pb_m_nMsgType==32 then
        App.game:navigateTo(constModel("NavigateModel").NAV_ALLY_TECH)

    elseif self.data.pb_m_nMsgType==50 then
        if self.linkType==2 then --集结
            App:dispatchEvent({name = const("AppEvent").ASK_MASS_DATA, data = self.linkValue})
        end
    else
        App:dispatchEvent({name = AppEvent.CHAT_CLOSE})
        App.game:OnEnterMap( self.posX,self.posY)
    end
end


function CharBar:AllyAssist()
    if self.data.pb_m_nMsgType==36 then--援防
        --App.game:navigateTo(constModel("NavigateModel").NAV_INTERVENE, self.assistId)
        App:dispatchEvent({name = AppEvent.ASK_INTERVENE_PORT, data = self.assistId})
    end
end


function CharBar:Repair()
    if self.data.pb_m_nMsgType==34 then
        -- App.game:navigateTo(constModel("NavigateModel").NAV_MASS, self.linkValue)
        App:dispatchEvent({name = const("AppEvent").ASK_MASS_DATA, data = self.linkValue})
    elseif self.data.pb_m_nMsgType==35 then
        App:dispatchEvent({name = AppEvent.ASK_BUILD_REPAIR, data = self.repairId})
        --App.game:navigateTo(constModel("NavigateModel").NAV_BUILDREPAIR, self.repairId)
    end
end

function CharBar:Check()
    if self.data.pb_m_nMsgType==20 then
        local model= MailModel:CretetMailData()
        model.pb_seqno=tonumber(self.params[9])
        model.pb_rpt_type=401
        self.delegate.mailDetail:ShowDetail(model,self.typeIndx)
    elseif self.data.pb_m_nMsgType==37 then
        local model= MailModel:CretetMailData()
        model.pb_seqno=tonumber(self.params[4])
        model.pb_rpt_type=404
        self.delegate.mailDetail:ShowDetail(model,self.typeIndx)
    elseif self.data.pb_m_nMsgType==32 then
        App.game:navigateTo(constModel("NavigateModel").NAV_ALLY_TECH)
    elseif self.data.pb_m_nMsgType==40 then
        local shipData=App:GetModel("ShipModel"):CreateShipDataByInfo(tonumber(self.params[3]),tonumber(self.params[5]),tonumber(self.params[4]),self.params[6])
        shipData.pb_status=-1
        local shipTipsPopup = require("scenes.game.ship.ShipTips").New()
        shipTipsPopup:Show()
        shipTipsPopup:SetData(shipData)

    end
end


function CharBar:OnMenu()
    if  self.isLeft then return end
    local x,y,z = self.rt:GetLocalPosition()
    self.delegate:ShowChatTip(y-self.chatText1.preferredHeight-60,self.data)
end

function CharBar:Translate()
    if self.data.isTrans then
        self.data.isTrans =false
        ChatModel:SetTransChat(self.data,self.idx)
        ChatModel:dispatchEvent({name = AppEvent.CHAT_UPDATE_INDEX,index=ChatModel.transIndex})
        ChatModel:dispatchEvent({name = AppEvent.CHAT_ITEM_UPDATE,number=10})
    else

        local desLan=self.delegate:GetCurrLan()
        SendPacket("ReqTranslate",{src_txt=self.data.pb_m_wzMsg,to_lang=desLan,args={self.chatType,self.idx}})
        ChatModel:SetTransChat(self.data,self.idx)
        self.translate.gameObject:SetActive(false)
    end
end



function CharBar:OnView()
    if self.data.pb_m_nSenderID==App:GetModel("PlayerModel"):GetUID() then
        --App.game:navigateTo(constModel("NavigateModel").NAV_PLAYINFO)
    else
        SendPacket("ReqGetUserProfile",{dst_user_id=self.data.pb_m_nSenderID})
    end
end





---------------------------------ChatView-----------------------------------------

function ChatView:ctor(luaObj)
    luaObj.LuaGameObjectHelper:loadGameObjects(self)
    self.DTableViewLua = self.chatTableView.DTableViewA
    self.DTableViewLua.onDataSourceAdapterHandler = handler(self, self.InitChatCell)
    self.DTableViewLua.onDataLoadAdapterHandler=handler(self,self.LoadOldItems)
    self.DTableViewLua.onSizeSourceAdapterHandler = handler(self, self.GetCellSize)
    self.DTableViewLua.onInsertUpdateHandler= handler(self, self.DeLoad)



    self.addnum = 0
    self.chatTips.gameObject:SetActive(false)
    self.mailDetail=MailDetail.New(self,self.mailDetails.gameObject)
    self.tipChatData  = nil


    self.langData=nil
	self.dataList = App:GetModel("SettingModel"):GetAllLangData()
	for i = 1,#self.dataList do
		local data = self.dataList[i]
		if language == data.lang then
            self.langData=data
		end
	end
    if self.langData==nil then
        self.langData=self.dataList[1]
    end
end

function ChatView:CloseDetail()
    self.mailDetail:SetActive(false)
end

function ChatView:GetCurrLan()
    local desLan=CS.PlatformManager.GetInstance():getLanguage()
        if string.lower(CS.PlatformManager.GetInstance():getLanguage())=='zh' then
            if string.lower(CS.PlatformManager.GetInstance():getCountry())=='cn' then
                desLan="zh-Hans";
            else
                desLan="zh-Hant";
            end
        end
        if desLan=="" then
            desLan="en"
        end
        return desLan
end



function ChatView:LoadOldItems()
    if self.ChatType==1 or self.ChatType==2 then 
        SendPacket("ReqGetChatMsgList",{m_nChatType = self.ChatType,m_nTargetID = 0,m_llLastMsgSeqNo = ChatModel:GetTypeLastId(self.ChatType)})
    else
        if not self.isPrivateList then
            SendPacket("ReqGetChatMsgList",{m_nChatType=self.ChatType,m_nTargetID=self.privateChatData.targetId,m_llLastMsgSeqNo=self.Model:GetPrivateLastId(self.privateChatData)})
        end
    end
end


function ChatView:ShowChatTip(y,chatData)
    self.tipChatData = chatData
    self.chatTips.gameObject:SetActive(true)
    self.chatTips.gameObject.transform:SetAsLastSibling()
    self.chatTips.RectTransform:SetPosition(0,y,0)
end

function ChatView:OnCloseChatTips()
    self.tipChatData = nil
    self.chatTips.gameObject:SetActive(false)
end

function ChatView:onCopyChat()
    if self.tipChatData~=nil then
        CS.SystemUtil.copyToPasteBoard(self.tipChatData.pb_m_wzMsg)
    end
    toast(lang("tips1"))
    self:OnCloseChatTips()
end

function ChatView:onBlockTalker()
    SendPacket("ReqFriendAction",{m_nActType=6,item={{m_nUserID=self.tipChatData.pb_m_nSenderID}}})
    self:OnCloseChatTips()
end

function ChatView:onReport()
    toast(lang("tips2"))
    self:OnCloseChatTips()
end

function ChatView:InitChatCell(cell, idx)
    if cell.LuaTable == nil then
        local info = CharBar.New(cell,self)
    end
    local data = nil
    if  self.ChatType==4 or  self.ChatType==3 then
       data = self.privateChatData.chatList[#self.privateChatData.chatList-idx]
    else
       data = ChatModel:GetChatIndex(self.ChatType,idx)
    end
    cell.LuaTable:SetData(data,idx)
    cell.LuaTable.chatType=self.ChatType
    cell.LuaTable.idx = idx
    cell.idx = idx
    return cell
end


function ChatView:LoadOldItems()

    self.loadBar.gameObject:SetActive(true)

    self.deLoadHandler=Timer.ScheduleOne(3,handler(self,self.DeLoad))

    if self.ChatType==1 or self.ChatType==2 then 
        SendPacket("ReqGetChatMsgList",{m_nChatType=self.ChatType,m_nTargetID=0,m_llLastMsgSeqNo=ChatModel:GetTypeLastId(self.ChatType)})
    elseif not self.isPrivateList then
        SendPacket("ReqGetChatMsgList",{m_nChatType=self.ChatType,m_nTargetID=self.privateChatData.targetId,m_llLastMsgSeqNo =ChatModel:GetPrivateLastId(self.privateChatData)})
    end
end


function ChatView:GetCellSize(idx)
    local  data = nil
    if self.ChatType==1 or self.ChatType==2 then
       data = ChatModel:GetChatIndex(self.ChatType,idx)
    elseif self.ChatType == 4 or  self.ChatType==3 then
       data =self.privateChatData.chatList[#self.privateChatData.chatList-idx]
    end

    if type(data)=="string" then
        return 33
    else
        return self:GetChatHeight(data)
    end

end


function ChatView:GetTempText()
    local cell=self.lChat.gameObject:GetComponent(typeof(CS.DLuaTableViewCell))
    if self.tempbar==nil then
        self.tempbar=CharBar.New(cell,self)
    end
    return self.tempbar
end

function ChatView:GetChatHeight(data)
    if data.pb_m_nMsgType==0 then
        local height=self:GetTempText():SetData(data)
        return height+70
    else
        return 155
    end
end



--设置聊天类型
function ChatView:SetChatType(ctype,data)
    self.ChatType = ctype
    if self.ChatType==4 or self.ChatType == 3 then
        local itemNo=ChatModel:GetPrivateLastId(data)
        if  itemNo==0 then
            SendPacket("ReqGetChatMsgList",{m_nChatType=self.ChatType,m_nTargetID=data.targetId,m_llLastMsgSeqNo=ChatModel:GetPrivateLastId(data)})
        end
        data.haveNew=false
        self.privateChatData = data
        self.privateIsEmpty = #data.chatList==0
    else
        self.privateChatData = nil
        self.privateIsEmpty = false
    end

    if self.ChatType==2 and not App:GetModel("AllyModel"):IsInAlly() then
        self.TipTxt.gameObject:SetActive(true)
    else
        self.TipTxt.gameObject:SetActive(false)
    end

    self:initScrollRect()
end


function ChatView:initScrollRect()
    local len = 0
    if self.ChatType == 1 or self.ChatType == 2 then
        len = ChatModel:GetChatCount(self.ChatType)
        self.chatTableView.RectTransform.offsetMax = Vector2(0,0)
    elseif self.ChatType == 4 or self.ChatType == 3 then
        len = #self.privateChatData.chatList
        self.chatTableView.RectTransform.offsetMax = Vector2(0,-56)
    end
    self.DTableViewLua.CellsCount = len
    self.DTableViewLua:reloadData(false,true)
    self.DTableViewLua:setContentOffsetToBottom()
    self.DTableViewLua:Refresh(true)
end


function ChatView:SetPrivateChatData( data )
    self.privateChatData = data
end


function ChatView:OnSendChat(obj)
    local language=self:GetCurrLan()
    if self.InputField.InputField.text~="" then
        if self.ChatType==1 or self.ChatType==2 then
            SendPacket("ReqSendChatMsg",{m_nChatType= self.ChatType,m_nTargetID=0,m_wzMsg=self.InputField.InputField.text,m_wzLanguage=language})
        elseif self.ChatType == 4 or self.ChatType == 3  then
            local msg = {}
            msg.m_nChatType = self.ChatType
            msg.m_nTargetID = self.privateChatData.targetId
            msg.m_wzMsg = self.InputField.InputField.text
            msg.m_wzLanguage =language
            SendPacket("ReqSendChatMsg",msg)
        end
        self.InputField.InputField.text="";
    end
end


function ChatView:UpdateChatItem(event)
    self.DTableViewLua:UpCellSizeZ(event.index,self:GetCellSize(event.index))
end

function ChatView:UpdateChat(event)
    if self.ChatType<=2 then
        ChatModel.chatNewNum[self.ChatType]=0
    end

    if self.privateIsEmpty == true then
        self.privateIsEmpty = self.addnum==0
        self.addnum = 0
        self:initScrollRect()
        return
    end

    if self.addnum ==0 then 
        self.DTableViewLua:updateView()
        return 
    end

    if self.addnum<=2 then
        self.DTableViewLua:finishInsert()
        self.DTableViewLua:setContentOffsetToBottom()
        self.DTableViewLua:updateView()
    else
        self.DTableViewLua:finishInsertAndUpView()
    end
    self.addnum = 0
end



function ChatView:DeLoad()
    self.loadBar.gameObject:SetActive(false)
    if self.deLoadHandler~=nil then
        Timer.Unschedul(self.deLoadHandler)
        self.deLoadHandler=nil
    end
end

function ChatView:AddChatItem(event)
    self.addnum = self.addnum+1
    self.add = true
    local eventType = event.chatType
    if eventType==self.ChatType then
        local size =  self:GetCellSize(event.index-1)
        self.DTableViewLua:insertItem(event.index-1,size);
        local len=0 
        if self.ChatType == 1 or self.ChatType == 2 then
            len = ChatModel:GetChatCount(self.ChatType)
        elseif self.ChatType == 4 or self.ChatType == 3 then
            len = #self.privateChatData.chatList
        end
        if len <10 then
            self:initScrollRect()
        end
    end
end


function ChatView:OnExit()
    if self.deLoadHandler~=nil then
        Timer.Unschedul(self.deLoadHandler)
        self.deLoadHandler=nil
    end
    self.mailDetail:OnExit()
end




return ChatView
