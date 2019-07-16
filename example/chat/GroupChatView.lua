local GroupChatView = Class("GroupChatView",require("components.View"))
local AppEvent = const("AppEvent")

local FriendSelect=require("scenes.game.chatnew.FriendSelect")
local ChatModel = App:GetModel("ChatModel")


local Group_Status = {
    List = 1,
    Admin = 2,
    Create = 3,
    Chat = 4,
    Admin_ADD = 5,
    Admin_DEL = 6,
}



local PrivateChatItem = Class("PrivateChatItem")
function PrivateChatItem:ctor(cellPrefab,delegate)
    cellPrefab.LuaTable = self
    self.delegate = delegate
    self.callback=nil
    self.drag=cellPrefab.gameObject:GetComponent(typeof(CS.Drag))

end



function PrivateChatItem:OnEnter()
    if not self.drag.m_Dragging then
        self.delegate:EnterCroupChat(self.data)
    end
end

function PrivateChatItem:SetBG(rect)
end


function PrivateChatItem:Readed()
    if self.callButton1 then
        self.callButton1(self,self.data)
    end
end


function PrivateChatItem:Delete()
    self.delegate:DeletePrivateData(self.data)
    --if self.callButton2 then
        --self.callButton2(self,self.data)
    --end
end


function PrivateChatItem:SetData(data)
    self.data=data
    if self.data.type==3 then--Ë½ÁÄ
        self.groupHead.gameObject:SetActive(false)
        self.playerHead.gameObject:SetActive(true)
        self.playerHead.Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.talkerData.head)
        self.playerName.Text.text=data.talkerData.name
    elseif self.data.type==4 then--ÈºÁÄ
        self.groupHead.gameObject:SetActive(true)
        self.playerHead.gameObject:SetActive(false)
        for index=1,4 do
            self["head"..index].gameObject:SetActive(index<=#data.groupData.members)
            if index<=#data.groupData.members then
                self["head"..index].Image.sprite=App:GetResourceManager():GetPlayHeadIcon(data.groupData.members[index].pb_m_nPicID)
            end
        end
        self.playerName.Text.text=lang("GroupChatTitle",#data.groupData.members)
    end

    local newData = ChatModel.chatNewNum[targetId] 
    self.newMessage.gameObject:SetActive(newData ~= nil and newData > 0)

    if #data.chatList>0 then
        self.groupDate.Text.text=TimeUtil.formatTime(data.chatList[1].pb_m_nSendTime, "%Y-%m-%d  %H:%M")
        self.groupInfo.Text.text=data.chatList[1].pb_m_wzMsg
    else
        self.groupDate.Text.text=""
        self.groupInfo.Text.text=""
    end
end


--------------------------------------FriendView-----------------------------------
function GroupChatView:ctor(luaObj,ctrl)
    GroupChatView.super.ctor(self,ctrl)
    luaObj.LuaGameObjectHelper:loadGameObjects(self)
    self.DTableViewLua=self.groupArea.DTableViewA
    self.DTableViewLua.onDataSourceAdapterHandler = function(cell, idx)
        if cell.LuaTable == nil then
            local privateChatItem = PrivateChatItem.New(cell,self)
        end
        if  self.Status == Group_Status.List then
            cell.LuaTable:SetData(ChatModel.privateChatItemList[idx+1])
        end
        return cell
    end


end


function GroupChatView:DeletePrivateData(data)
    ChatModel:DeletePrivateData(data.type,data.targetId)
    self:OnRefreshList()
end

---------------------------------是否是管理员------------
function GroupChatView:IsGroupMaster()
    return self.privateChatData.groupData.pb_m_nCreatorID==App:GetModel("PlayerModel"):GetUID()
end


function GroupChatView:ShowSetIcon( value )
     self.privateSet.gameObject:SetActive(value)
end


function GroupChatView:OnRefreshList()
    if self.Status== Group_Status.List then
        local len = #ChatModel.privateChatItemList
        self.DTableViewLua.CellsCount = len
        self.DTableViewLua:reloadData()
    else
        self:OnList()
    end
end



---------------------------------显示群聊列表------------
function GroupChatView:OnList(value)
    if self.Status== Group_Status.List and value == nil then return end
    self:GetCtrl():HideChatView()
    self.privateback.gameObject:SetActive(false)
    self.Status= Group_Status.List
    App:GetModel("AllyModel"):ConfirmGetMember()
    self.btmBg.gameObject:SetActive(true)
    self.friendAdd.gameObject:SetActive(false) 
    self.groupDel.gameObject:SetActive(false) 
    self.groupExit.gameObject:SetActive(false) 
    self.normalBtn.gameObject:SetActive(false)
    self.groupChat.gameObject:SetActive(true)
    self:ShowSetIcon(false)
    self.groupArea.gameObject:SetActive(true)
    self:OnUpDataGroupView()
    self.addArea.gameObject:SetActive(false)
    self.privateTitle.Text.text = lang("chatList",#ChatModel.groupList.list)
    self.TipTxt.gameObject:SetActive(len==0)
end


function GroupChatView:OnUpDataGroupView()
     for i=1,#ChatModel.groupList.list do
        ChatModel:GetPrivateChat(4,ChatModel.groupList.list[i].pb_m_nGroupID)
    end
    local len = #ChatModel.privateChatItemList
    self.DTableViewLua.CellsCount = len
    self.DTableViewLua:reloadData()
end


function GroupChatView:CallBackGroupMemberUpdate()
    if self.Status == Group_Status.Admin_ADD or self.Status == Group_Status.Admin_DEL then
        self:OnList()
    elseif self.Status == Group_Status.List then
        self:OnUpDataGroupView()
    elseif self.Status == Group_Status.Chat then
        self.privateTitle.Text.text = lang("groupChatList",#self.privateChatData.groupData.members) 
    end
end



---------------------------------管理群聊天------------
function GroupChatView:OnAdmin()
    self.TipTxt.gameObject:SetActive(false)
    self.privateback.gameObject:SetActive(true)
    self.Status= Group_Status.Admin
    self:GetCtrl():HideChatView()
    self.addArea.gameObject:SetActive(false)
    self.groupArea.gameObject:SetActive(true)
    self.btmBg.gameObject:SetActive(true)
    self.groupChat.gameObject:SetActive(false)
    self.friendAdd.gameObject:SetActive(true)
    self.groupDel.gameObject:SetActive(self:IsGroupMaster())
    self.groupExit.gameObject:SetActive(true)
    self.normalBtn.gameObject:SetActive(false)
    self:ShowSetIcon(false)
    self:ShowFriendSelect()
    self.FriendSelect:SetType(3,self.privateChatData.groupData.members)
    self.privateTitle.Text.text = lang("chatinfo",#self.privateChatData.groupData.members) 
end





---------------------------------添加群聊玩家------------
function GroupChatView:OnAddPlay(  )
        self.TipTxt.gameObject:SetActive(false)

    self.privateback.gameObject:SetActive(true)
    self.Status= Group_Status.Admin_ADD
    self:ShowFriendSelect()
    local alreadySelect={}
    for i,v in pairs(self.privateChatData.groupData.members) do
        alreadySelect[v.pb_m_nUserID]=true
    end
    self.FriendSelect.seleteIDS = alreadySelect
    self.FriendSelect:OnToggle()
    self.normalBtn.gameObject:SetActive(true)
    self.groupChat.gameObject:SetActive(false)
    self.friendAdd.gameObject:SetActive(false)
    self.groupDel.gameObject:SetActive(false)
    self.groupExit.gameObject:SetActive(false)
    self:ShowSetIcon(false)
    self.privateTitle.Text.text = lang("chat1")
    self.btnText.Text.text = lang("chat2")
end




---------------------------------删除群聊玩家------------
function GroupChatView:OnDelPlay()
        self.TipTxt.gameObject:SetActive(false)

    self.Status= Group_Status.Admin_DEL
    self.privateback.gameObject:SetActive(true)
    self:ShowFriendSelect()
    self.FriendSelect:SetType(4,self.privateChatData.groupData.members)
    self.normalBtn.gameObject:SetActive(true)
    self.groupChat.gameObject:SetActive(false)
    self.friendAdd.gameObject:SetActive(false)
    self.groupDel.gameObject:SetActive(false)
    self.groupExit.gameObject:SetActive(false)
    self.privateSet.gameObject:SetActive(false)
    self.btnText.Text.text = lang("chat3")
    self.privateTitle.Text.text = lang("chat4")
end




---------------------------------创建群聊------------
function GroupChatView:OnCreateGroupChat()
        self.TipTxt.gameObject:SetActive(false)

    self.privateTitle.Text.text = lang("chat5")
    self.Status= Group_Status.Create
    self:ShowFriendSelect()
    self.FriendSelect:OnToggle()
    self.btnText.Text.text = lang("chat6")
    self:ShowSetIcon(false)
    self.privateback.gameObject:SetActive(true)
    self.normalBtn.gameObject:SetActive(true)
    self.groupChat.gameObject:SetActive(false)
    self.friendAdd.gameObject:SetActive(false)
    self.groupDel.gameObject:SetActive(false)
    self.groupExit.gameObject:SetActive(false)
end


function GroupChatView:OnBack()
   if self.Status == Group_Status.Create then
        self:OnList()
    elseif self.Status == Group_Status.Admin then
        self:EnterCroupChat(self.privateChatData)
    elseif self.Status == Group_Status.Create then
        self:OnList()
    elseif self.Status == Group_Status.Chat then
        self:OnList()
    elseif self.Status == Group_Status.Admin_ADD then
        self:OnAdmin()
    elseif self.Status == Group_Status.Admin_DEL then
        self:OnAdmin()
    end
end


---------------------------------退出群聊------------
function GroupChatView:OnEixtChat(  )
    if self:IsGroupMaster() then
        SendPacket("ReqChatGroupMemberAction",{m_nActType=4,m_nGroupID=self.privateChatData.groupData.pb_m_nGroupID,item={{m_nUserID=App:GetModel("PlayerModel"):GetUID()}}})
    else
        SendPacket("ReqChatGroupMemberAction",{m_nActType=3,m_nGroupID=self.privateChatData.groupData.pb_m_nGroupID,item={{m_nUserID=App:GetModel("PlayerModel"):GetUID()}}})
        ChatModel:DeleteGroupList(self.privateChatData.groupData.pb_m_nGroupID)
    end
end


--回调
function GroupChatView:CreatPrivateChat(ids)
    print("create",#ids)
    if #ids>1 then
        local sendData={}
        for i,v in ipairs(ids) do
            sendData[#sendData+1] = {m_nUserID=v.id}
        end
        SendPacket("ReqCreateChatGroup",{item=sendData})
        self.privateTitle.Text.text=lang("GroupChatTitle",#ids+1)
    elseif #ids==1 then --私聊
        print("sefefsfe")
        self:EnterCroupChat(ChatModel:GetPrivateChat(3,ids[1].id,ids[1].name,ids[1].head))
    end
end



---------------------------------进入群聊------------
function GroupChatView:EnterCroupChat(data)
    self.privateback.gameObject:SetActive(true)
    self.Status= Group_Status.Chat
    self.privateChatData = data
    self.groupArea.gameObject:SetActive(false)
    self.addArea.gameObject:SetActive(false)
    self.privateSet.gameObject:SetActive(true)
    self.btmBg.gameObject:SetActive(false)
    if data.type==4 then
        self.privateTitle.Text.text = lang("groupChatList",#data.groupData.members)
        self:GetCtrl():SetChatType(4,self.privateChatData)
        self.exitText.Text.text = self:IsGroupMaster() and lang("chat7") or lang("chat8")
        self.privateSet.gameObject:SetActive(true)
    elseif data.type==3 then
        self.privateTitle.Text.text = data.talkerData.name
        self:GetCtrl():SetChatType(3,self.privateChatData)
        self.privateSet.gameObject:SetActive(false)
    end

    local newData = ChatModel.chatNewNum[data.targetId]
    if newData == nil then newData = 0 end
    ChatModel.chatNewNum[data.type] = ChatModel.chatNewNum[data.type]-newData
    ChatModel.chatNewNum[data.targetId] = 0
end






function GroupChatView:OnSelectPlay( ids )
    if self.Status == Group_Status.Create then
        self:CreatPrivateChat(ids)
    elseif self.Status == Group_Status.Admin_ADD then
        if #ids>0 then
           local sendData={}
            for i,v in ipairs(ids) do
                sendData[#sendData+1] = {m_nUserID=v.id}
            end
            SendPacket("ReqChatGroupMemberAction",{m_nActType=1,m_nGroupID=self.privateChatData.groupData.pb_m_nGroupID,item=sendData})
        end
    elseif self.Status == Group_Status.Admin_DEL then
        if #ids>0 then
           local sendData={}
           for i,v in ipairs(ids) do
                sendData[#sendData+1] = {m_nUserID=v.id}
           end
            SendPacket("ReqChatGroupMemberAction",{m_nActType=2,m_nGroupID=self.privateChatData.groupData.pb_m_nGroupID,item=sendData})
        end
    end
end




---------------------------------显示玩家列表------------
function GroupChatView:ShowFriendSelect(  )
    self.addArea.gameObject:SetActive(true)
    self.groupArea.gameObject:SetActive(false)
    self.groupChat.gameObject:SetActive(false)
    if self.FriendSelect==nil then
        self.FriendSelect = FriendSelect.New(self.addArea,handler(self,self.OnSelectPlay))
    end
    self.FriendSelect.seleteIDS = {}
end











return GroupChatView
