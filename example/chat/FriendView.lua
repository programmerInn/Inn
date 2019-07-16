local FriendView = Class("FriendView",require("components.View"))
local AppEvent = const("AppEvent")

local FriendModel = App:GetModel("FriendModel")


local FRIEND_TYPE = {
    LIST = 1,
    ALLPY = 2,
    ADD = 3
}


local FriendCell= Class("FriendCell")
function FriendCell:ctor(cellPrefab,delegate)
    cellPrefab.LuaTable = self
end

function FriendCell:SetData(data,ftype)
    self.data = data
    self.sendAdd.Button.interactable=true
    local allyShort=data.pb_m_wzAllyShortName
    if ftype==FRIEND_TYPE.ADD then
        allyShort=data.pb_m_wzAllyFlag
    end
    if allyShort~="" and allyShort~=0  then
        self.union.Text.text='['.. allyShort..']'
    else
        self.union.Text.text=lang("canJoinAlly")
    end


    local level=data.pb_m_nGrade
    if data.pb_m_nGrade<data.pb_m_nUserGrade then
        level=data.pb_m_nUserGrade
    end

    self.playerName.Text.text = data.pb_m_wzName.."  Lv."..level--pb_m_nUserGrade

    self.head.Image.sprite = App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nPicID)
    self.newIcon.gameObject:SetActive(ftype == FRIEND_TYPE.ALLPY)
    self.view.gameObject:SetActive(ftype == FRIEND_TYPE.LIST)
    self.applyItem.gameObject:SetActive(ftype == FRIEND_TYPE.ALLPY)
    self.sendAdd.gameObject:SetActive(ftype == FRIEND_TYPE.ADD)

end

function FriendCell:UnNew()
    self.data.pb_isNew=false
end

function FriendCell:OnSendAdd()
    SendPacket("ReqFriendAction",{m_nActType=1,item={{m_nUserID=self.data.pb_m_nUserID}}})
    self.sendAdd.Button.interactable=false
    self:UnNew()
end


function FriendCell:CheckPlayer()
    if self.data.pb_m_nFriendID==0 then
        SendPacket("ReqGetUserProfile",{dst_user_id=self.data.pb_m_nUserID})
    else
        SendPacket("ReqGetUserProfile",{dst_user_id=self.data.pb_m_nFriendID})
    end
    self:UnNew()
end

function FriendCell:OnView()
    if self.data.pb_m_nFriendID==0 then
        SendPacket("ReqGetUserProfile",{dst_user_id=self.data.pb_m_nUserID})
    else
        SendPacket("ReqGetUserProfile",{dst_user_id=self.data.pb_m_nFriendID})
    end
    self:UnNew()
end

function FriendCell:OnDelete()
    SendPacket("ReqFriendAction",{m_nActType=4,item={{m_nUserID=self.data.pb_m_nUserID}}})
    self:UnNew()
end


function FriendCell:OnAgree()
    SendPacket("ReqFriendAction",{m_nActType=3,item={{m_nUserID=self.data.pb_m_nUserID}}})
    self:UnNew()
end




--------------------------------------FriendView-----------------------------------
function FriendView:ctor(luaObj,ctrl)
    FriendView.super.ctor(self,ctrl)

    luaObj.LuaGameObjectHelper:loadGameObjects(self)
    self.DTableViewLua = self.friendList.DTableViewA
    self.DTableViewLua.onDataSourceAdapterHandler = handler(self, self.InitListCell)
    self.listData={}
    self:Binding(FriendModel, self, self.UpdateRecommend, AppEvent.FRIEND_RECOMMEND_REFRESH)
    self:Binding(FriendModel, self, self.UpDataView, AppEvent.FRIEND_LIST_REFRESH)
    self:OnToggle()
end

function FriendView:InitListCell(cell, idx)
    if cell.LuaTable == nil then
        local friendCell = FriendCell.New(cell,self)
    end
    cell.LuaTable:SetData(self.listData[idx+1],self.ftype)
    return cell
end

function FriendView:InitView()
    self.DTableViewLua.CellsCount = #self.listData
    self.DTableViewLua:reloadData()
end


function FriendView:UpDataView()
    if self.list.Toggle.isOn then
        self.ftype = FRIEND_TYPE.LIST
        self.listData = FriendModel.friendData
        self.friendList.RectTransform.offsetMax = Vector2(0,0)
        self.topBar.gameObject:SetActive(true)
        self.privateTitle.Text.text = lang("friendList")
        self.TipTxt.Text.text = lang("noFriend")
        self.TipTxt.gameObject:SetActive(#self.listData==0)

        self:InitView()
    elseif self.addTo.Toggle.isOn then
        self.topBar.gameObject:SetActive(false)
        self.ftype = FRIEND_TYPE.ADD
        self.friendList.RectTransform.offsetMax = Vector2(0,-33)
        SendPacket("ReqGetFriendRecommendList",{})
        self.TipTxt.gameObject:SetActive(false)
    elseif self.apply.Toggle.isOn then
        self.friendList.RectTransform.offsetMax = Vector2(0,0)
        self.topBar.gameObject:SetActive(true)
        self.ftype = FRIEND_TYPE.ALLPY
        self.listData = FriendModel.inviteData
        self.privateTitle.Text.text = lang("applyList")
        self:InitView()
        self.TipTxt.gameObject:SetActive(#self.listData==0)
        self.TipTxt.Text.text = lang("noapply")
    end
    self.DTableViewLua:reloadData()

    self:UpDataViewTag()
end


function FriendView:UpdateRecommend()
    self.listData = FriendModel.recommendList
    self:InitView()
    self:UpDataViewTag()
end


function FriendView:UpDataViewTag()
    self.applyTag.gameObject:SetActive(#FriendModel.inviteData >0)
end




function FriendView:OnToggle()
    self:UpDataView()
    self.searchNode.gameObject:SetActive(self.addTo.Toggle.isOn)
end


function FriendView:CheckValid(length,bottom,up)
    return length>bottom and length<=up
end

function  FriendView:OnPlayerSearch()
    local infoLen=string.len(self.searchInput.InputField.text)
    if self:CheckValid(infoLen,5,20) then
        SendPacket("ReqSearchUserByName",{m_wzSearchName=self.searchInput.InputField.text,m_nPageID=1})
    else
        toast(lang('FriendSearchLimit',5+1))
    end
end


function FriendView:RecommendButton()
    SendPacket("ReqGetFriendRecommendList",{})
end


function FriendView:CheckValid(length,bottom,up)
    return length>bottom and length<=up
end





return FriendView
