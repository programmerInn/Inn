local FriendSelectView = Class("FriendSelectView",require("components.View"))
local AppEvent = const("AppEvent")

local PlayerInfoCell = require("scenes.game.chatnew.PlayerInfoCell")
local ToggleGroup= require("scenes.game.common.ToggleGroup")



local FriendType = {
    fiendList = 1,  --好友列表
    unionList = 2,  --联盟成员列表
    chatPlayerList = 3, --群聊成员列表
    changePlayerList = 4, --删除群聊成员
}
-------------------------------FriendSelectView----------------------------------

function FriendSelectView:ctor(luaObj,callback)
    self.seleteIDS = {}
    luaObj.LuaGameObjectHelper:loadGameObjects(self)
    self.DTableViewLua=self.playerAddList.DTableViewA
    self.DTableViewLua.onDataSourceAdapterHandler = function(cell, idx)
        if cell.LuaTable == nil then
            local playInfo = PlayerInfoCell.New(cell,handler(self,self.ChangeType))
        end
        local info = cell.LuaTable
        info:SetData(self.playerDataList[idx+1],self.type)
        self.idNames[info.id]={name=info.nameStr,head=info.headPic}
        local userId=info.id
        if self.seleteIDS[userId] then
            info:SetIsOn(true)
            info.ckToggle.Toggle.interactable=false
        end

        return cell
    end
    self.playerDataList = {}
    self.callback = callback
    self.typeSelect={}--是否选中的测试
    self.idNames={}
end



function FriendSelectView:SetType(type,list)
    self.playerDataList  = list
    self.type = type
    self.DTableViewLua.CellsCount =#self.playerDataList
    self.DTableViewLua:reloadData();
    self.menuBg.gameObject:SetActive(type == FriendType.fiendList or type == FriendType.unionList)

    if type == FriendType.fiendList or type == FriendType.unionList then
        self.playerAddList.RectTransform.offsetMax = Vector2(0,-107)
    else
        self.playerAddList.RectTransform.offsetMax = Vector2(0,-60)
    end

end


function FriendSelectView:OnToggle()
    if self.friendToggle.Toggle.isOn then
        self:SetType(FriendType.fiendList,App:GetModel("FriendModel").friendData)
    elseif self.unionToggle.Toggle.isOn then
        self:SetType(FriendType.unionList,App:GetModel("AllyModel").allyMembers)
    end
end


function FriendSelectView:SetSelete(ids)
    self.seleteIDS = true
end




function FriendSelectView:ChangeType(id,isOn)
    if self.seleteIDS~=nil and self.seleteIDS[id] then return end
    self.typeSelect[id]=isOn
end


function FriendSelectView:OnConfirm()
    local ids={}
    for id,value in pairs(self.typeSelect) do    
        if value then
            ids[#ids+1] = {id=id,name=self.idNames[id].name,head=self.idNames[id].head}
        end
    end
    self.callback(ids)
    --SendPacket("ReqGetChatMsgList",{m_nChatType=self.ChatType,m_nTargetID=0,m_llLastMsgSeqNo=self.Model:GetTypeLastId(self.ChatType)})
end


function FriendSelectView:OnCancel()

end


return FriendSelectView 
