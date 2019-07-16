--聊天
local ChatNew = Class("ChatNew",require("components.ViewController"))
local ChatMainView = Class("ChatMainView",require("components.View"))
local GroupChatView = require("scenes.game.chatnew.GroupChatView")

local FriendView = require("scenes.game.chatnew.FriendView")
local ChatView = require("scenes.game.chatnew.ChatView") 
local ChatModel = App:GetModel("ChatModel")
local FriendModel = App:GetModel("FriendModel")
local AppEvent = const("AppEvent")

local Nav_Type = {
    World_Chat = 1,
    Ally_Chat = 2,
    Group_Chat = 3,
    Friend_Chat = 4
}


local ChatSetView = Class("ChatSetView")
function ChatSetView:ctor(luaObj)
    luaObj:loadGameObjects(self)
    self.VipToggle.Toggle.isOn = ChatModel:GetSet(0) == 1
end

function ChatSetView:OnToggle(  )
    ChatModel:SetSet(0,self.VipToggle.Toggle.isOn and 1 or 0)
end

function ChatSetView:OnBlacklist()
    local popup = require("scenes.game.chatnew.BlockListPopup").New()
    popup:Show()
end

---------------------------------ChatView-----------------------------------------

function ChatMainView:ctor()
    ChatMainView.super.ctor(self,ctrl)
    local go = App:GetResourceManager():GetPrefab("UI/Prefabs/social/chatMain.prefab")
    local view = App:GetGUIManager():PushChat(go,self)
    self.chatArea = ChatView.New(self.chatNode)

    if ChatModel.homeShowType==2 then
        self.union.Toggle.isOn=true
    end
    self:OnToggle()
end


function ChatMainView:OnSetCallBack()
    if  self.chatSetView==nil then
        self.chatSetView = ChatSetView.New(self.blackListSet.LuaGameObjectHelper)
    end
    self.blackListSet.gameObject:SetActive(not self.blackListSet.gameObject.activeSelf)
end


function ChatMainView:OnToggle()
    local chatType=nil
    self.FriendArea.gameObject:SetActive(self.friend.Toggle.isOn)
    self.groupNode.gameObject:SetActive(self.group.Toggle.isOn)
    if  self.world.Toggle.isOn then
        chatType = 1
    elseif self.union.Toggle.isOn then
        chatType = 2
    elseif self.group.Toggle.isOn then
        if self.groupChatView == nil then
            self.groupChatView = GroupChatView.New(self.groupNode,self)
        end
        self.groupChatView:OnRefreshList()
        self.chatNode.gameObject:SetActive(false)
        self.ChatType = nil
        self.groupTag.gameObject:SetActive(false)
        ChatModel.chatNewNum[3]=0
        ChatModel.chatNewNum[4]=0
        return
    elseif self.friend.Toggle.isOn then
        if self.friendView == nil then
            self.friendView = FriendView.New(self.FriendArea,self)
        end
        self.chatNode.gameObject:SetActive(false)
        self.ChatType = nil
        return
    end
    if chatType == self.ChatType then return end
    self.ChatType = chatType
    self.chatNode.gameObject:SetActive(false)
    self:SetChatType(chatType)
    self.chatNode.gameObject:SetActive(true)
    ChatModel:ChangeHomeType(chatType)
    ChatModel.chatNewNum[chatType]=0
    self:UpDataTagView()
    self:UpDataFirendViewTag()
end



function ChatMainView:EnterPrivateById(data)
    self:SetToggleChat()
    self.groupChatView:CreatPrivateChat({data})
end

function ChatMainView:SetToggleChat()
    self.world.Toggle.isOn=false
    self.union.Toggle.isOn=false
    self.group.Toggle.isOn=true
    self.friend.Toggle.isOn=false
end

function ChatMainView:UpDataTagView()
    self.worldTag.gameObject:SetActive(ChatModel.chatNewNum[1]>0)
    self.unionTag.gameObject:SetActive(ChatModel.chatNewNum[2]>0)
    self.groupTag.gameObject:SetActive(ChatModel.chatNewNum[3]>0 or ChatModel.chatNewNum[4]>0)
    if self.group.Toggle.isOn then
        self.groupTag.gameObject:SetActive(false)
        ChatModel.chatNewNum[3]=0
        ChatModel.chatNewNum[4]=0
    end
end


function ChatMainView:UpDataFirendViewTag()
    self.friendTag.gameObject:SetActive(#FriendModel.inviteData >0)
end


function ChatMainView:SetChatType(type,data)
    self.chatArea:SetChatType(type,data)
    self.chatNode.gameObject:SetActive(true)
end

function ChatMainView:HideChatView()
    self.chatNode.gameObject:SetActive(false)
end



function ChatMainView:initScrollRect(event)
    if self.chatArea~=nil then
        self.chatArea:initScrollRect(event)
    end
end

function ChatMainView:UpdateChat(event)
    if self.chatArea~=nil then
        self.chatArea:UpdateChat(event)
    end
    self:UpDataTagView()
end


function ChatMainView:UpdateChatItem(event)
    if self.chatArea~=nil then
        self.chatArea:UpdateChatItem(event)
    end
end


function ChatMainView:AddChatItem(event)
    if self.chatArea~=nil then
        self.chatArea:AddChatItem(event)
    end
end




function ChatMainView:CallBackDeleteGroup(evnet)
    if self.groupChatView ~=nil then
        self.groupChatView:OnRefreshList()
    end
end

function ChatMainView:CallBackGroupMemberUpdate()
    if self.groupChatView ~=nil then
        self.groupChatView:CallBackGroupMemberUpdate()
    end
end


function ChatMainView:CallBackCreateGroup(event)
    if self.groupChatView ~=nil then
        local groupId = event.groupId
        self.groupChatView:EnterCroupChat(ChatModel:GetPrivateChat(4,groupId))
    end
end



function ChatMainView:OnEnter(data)
    self:Binding(ChatModel, self, self.initScrollRect, AppEvent.CHAT_RELOAD)
    self:Binding(ChatModel, self, self.UpdateChat, AppEvent.CHAT_ITEM_UPDATE)
    self:Binding(ChatModel, self, self.AddChatItem, AppEvent.CHAT_ITEM_INSERT)
    self:Binding(ChatModel, self, self.UpdateChatItem, AppEvent.CHAT_UPDATE_INDEX)


    self:Binding(ChatModel, self, self.CallBackDeleteGroup, AppEvent.CHAT_GROUP_DELETE)
    self:Binding(ChatModel, self, self.CallBackGroupMemberUpdate, AppEvent.CHAT_GROUP_MEMBER_UPDATE)
    self:Binding(ChatModel, self, self.CallBackCreateGroup, AppEvent.CHAT_GROUP_CREATE)
    --self:Binding(ChatModel, self, self.HideChatView, AppEvent.CHAT_CLOSE)
    binding(App, self, self.OnClose, AppEvent.CHAT_CLOSE)
    self:Binding(FriendModel, self, self.UpDataFirendViewTag, AppEvent.FRIEND_LIST_REFRESH)
    
    self:UpDataTagView()
end


function ChatMainView:OnExit()
    ChatMainView.super.OnExit(self)
    --if  self.chatSetView~=nil then
        --self.chatSetView:OnExit()
        --self.chatSetView=nil
    --end
    if  self.chatArea~=nil then
        self.chatArea:OnExit()
        self.chatArea=nil
    end
    if  self.groupChatView~=nil then
        self.groupChatView:OnExit()
        self.groupChatView=nil
    end
    if  self.friendView~=nil then
        self.friendView:OnExit()
        self.friendView=nil
    end
end


function ChatMainView:OnClose()
    App:GetGUIManager():PopChat()
    ChatModel:WriteList()
    App.game:ExitChat()
end


---------------------------------ChatNew-----------------------------------------
function ChatNew:ctor(game)
    ChatNew.super.ctor(self,game)
    self:initView()
end



function ChatNew:initView()
    self.view = ChatMainView.New(self)
end


function ChatNew:OnEnter(navData)
  if navData ~=nil then 
      self.view:EnterPrivateById(navData)
   end
end


function ChatNew:OnExit()
    -- App:GetGUIManager():PopChat()
end





return ChatNew
