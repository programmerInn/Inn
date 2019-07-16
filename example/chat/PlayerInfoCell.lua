local PlayerInfoCell = Class("PlayerInfoCell")



function PlayerInfoCell:ctor(cellPrefab,callback)
    self.callback = callback
    cellPrefab.LuaTable = self
    self.ckToggle.Toggle.interactable=true
end


function PlayerInfoCell:SetData(model,type)
    self.type=type
    if self.type==1 then  --好友
        self.head.Image.sprite= App:GetResourceManager():GetPlayHeadIcon(model.pb_m_nPicID)
        self.name.Text.text=model.pb_m_wzName
        self.ckToggle.gameObject:SetActive(true)
        self.id=model.pb_m_nFriendID
        self.nameStr=model.pb_m_wzName
        self.headPic=model.pb_m_nPicID
        self.ckToggle.Toggle.isOn = false
        self.view.gameObject:SetActive(false)
    elseif self.type==2 then --联盟成员
        self.head.Image.sprite= App:GetResourceManager():GetPlayHeadIcon(model.pb_user_pic)
        self.name.Text.text=model.pb_user_name
        self.ckToggle.gameObject:SetActive(true)
        self.id=model.pb_user_id
        self.nameStr=model.pb_user_name
        self.headPic=model.pb_user_pic
        self.ckToggle.Toggle.isOn = self.id == App:GetModel("PlayerModel").playInfo.pb_my_uid
        self.ckToggle.Toggle.interactable=self.id~=App:GetModel("PlayerModel").playInfo.pb_my_uid
        self.view.gameObject:SetActive(false)
    elseif self.type==3 then --群组成员列表
        self.head.Image.sprite= App:GetResourceManager():GetPlayHeadIcon(model.pb_m_nPicID)
        self.name.Text.text=model.pb_m_wzName
        self.ckToggle.gameObject:SetActive(false)
        self.id=model.pb_m_nUserID
        self.nameStr=model.pb_m_wzName
        self.headPic=model.pb_m_nPicID
        self.ckToggle.Toggle.isOn = false
        self.view.gameObject:SetActive(self.id ~= App:GetModel("PlayerModel").playInfo.pb_my_uid)
    elseif self.type==4 then --删除群组成员列表
        self.head.Image.sprite= App:GetResourceManager():GetPlayHeadIcon(model.pb_m_nPicID)
        self.name.Text.text=model.pb_m_wzName
        self.ckToggle.gameObject:SetActive(true)
        self.id=model.pb_m_nUserID
        self.nameStr=model.pb_m_wzName
        self.headPic=model.pb_m_nPicID
        self.ckToggle.Toggle.interactable=self.id~=App:GetModel("PlayerModel").playInfo.pb_my_uid
        self.ckToggle.Toggle.isOn = false
        self.view.gameObject:SetActive(false)
    end
end

function PlayerInfoCell:OnView()
    SendPacket("ReqGetUserProfile",{dst_user_id=self.id})
end



function PlayerInfoCell:SetIsOn(isOn)
    isOn = isOn or false
    self.ckToggle.Toggle.isOn=isOn
end



function PlayerInfoCell:OnCheck()--加入
    if self.callback ~= nil then
        self.callback(self.id,self.ckToggle.Toggle.isOn)
    end
end


return PlayerInfoCell