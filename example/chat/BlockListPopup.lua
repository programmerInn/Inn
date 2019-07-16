
-- 通用确认弹出框
-- Created by jk on 16-11-8
-- Copyright (c) 2016年 tjf. All rights reserved.


local BlockListPopup = Class("BlockListPopup",require("components.Popup"))
local AppEvent = const("AppEvent")

local FriendModel = App:GetModel("FriendModel")

local BlockCell = Class("BlockCell")


function BlockCell:ctor(cellPrefab)
    cellPrefab.LuaTable = self
end


function BlockCell:SetData(data)
	self.head.Image.sprite = App:GetResourceManager():GetPlayHeadIcon(data.pb_m_nPicID)
    self.playerName.Text.text = data.pb_m_wzName.."  Lv."..data.pb_m_nUserGrade
    if data.pb_m_wzAllyShortName~="" then
    self.union.Text.text='['.. data.pb_m_wzAllyShortName..']'
	else
    self.union.Text.text=lang("canJoinAlly")
	end

	self.data = data
end


function BlockCell:OnDelete()
	SendPacket("ReqFriendAction",{m_nActType=7,item={{m_nUserID=self.data.pb_m_nUserID}}})
end



function BlockListPopup:ctor(ctrl)
    BlockListPopup.super.ctor(self,ctrl,"UI/Prefabs/social/blockList.prefab") 
end


function BlockListPopup:OnShow()
    self:Binding(FriendModel, self, self.OnUpdateList, AppEvent.FRIEND_LIST_REFRESH)
    self:InitView()
end



function BlockListPopup:OnUpdateList()
	self.DTableViewLua.CellsCount = #FriendModel.blockData
	self.DTableViewLua:reloadData()
end

function BlockListPopup:InitView()
    self.DTableViewLua=self.list.DTableViewA
	self.DTableViewLua.CellsCount = #FriendModel.blockData
    self.DTableViewLua.onDataSourceAdapterHandler = function(cell, idx)
	    if cell.LuaTable == nil then
	        local blockCell = BlockCell.New(cell)
	    end
	    cell.LuaTable:SetData(FriendModel.blockData[idx+1])
	    return cell
    end
	self.DTableViewLua:reloadData()
end





return BlockListPopup
