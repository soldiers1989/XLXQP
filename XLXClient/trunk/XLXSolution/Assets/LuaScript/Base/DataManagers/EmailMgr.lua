
SEND_MAIL_ERROR ={
	SUCCESS = 0,				-- 发送成功
	ACCOUNT_ERROR = 1,			-- 账号错误
	GOLD_NOT_ENOUGH = 2,		-- 金币不足
	NO_ACCOUNT = 3,				-- 对方账号不存在
	GOLD_NUM_ERROR = 4,			-- 金币数量错误
	TIME_MAX = 5,				-- 次数达到上限
	SEND_TO_SELF = 6,			-- 发邮件给自己
}

if EmailMgr == nil then
	EmailMgr =
	{
		mails = nil,
        -- 有附件的新邮件
        NewMailHasAttach = nil,
        -- 没有附件的新邮件
        NewMailNoAttach = nil,
        -- 未领取附件的已读邮件
        ReadMailHasAttach = nil,
        -- 已领取附件的已读邮件
        ReadMailGotAttach = nil,
        -- 没有附件的已读邮件
        ReadMailNoAttach = nil,
		SortedMailIDList = nil,
	}
end

--邮件结构体
local MailStruct = 
{
	MailID = 0,					--邮件ID
	nSendType = 0, 				--1为系统邮件2为玩家邮件
	sTitle = '',				--邮件的标题
	sContent = '',				--邮件的文字内容
	nSenderID = 0,				--发送者id，如果是系统发的则为1
	sSenderName = "",			--发送者名称
	nSendDate = '',				--发送日期，东八区时间戳
	nGold = 0,					--邮件附带的金币数
	nRoomCard = 0,				--邮件附带的房卡数
	bIsRead = 0,				--0表示未读 1表示已读
	hasAttachment = 0, 			--0没有， 1表示有附件
}

function EmailMgr:GetSendMailError(errorType)
	return data.GetString("Send_Mail_".. errorType)
end

local UpdateMailEventArgs = 
{	
	Reason = 0,			-- 更新的原因(1， 增加，2 删除， 3，内容更新)
	MailID = 0,			-- 更新的邮件ID	
}

function MailStruct:New()
	local tObj = {}
	Extends(tObj, MailStruct)
	return tObj
end

function EmailMgr:InitList()
	self.mails = {}
    -- 有附件的新邮件
    self.NewMailHasAttach = {}
    -- 没有附件的新邮件
    self.NewMailNoAttach = {}
    -- 未领取附件的已读邮件
    self.ReadMailHasAttach = {}
    -- 已领取附件的已读邮件
    self.ReadMailGotAttach = {}
    -- 没有附件的已读邮件
    self.ReadMailNoAttach = {}

	self.SortedMailIDList = {}
end

function EmailMgr:ClearAll()
	self.mails = nil
    self.NewMailHasAttach = nil
    self.NewMailNoAttach = nil
    self.ReadMailHasAttach = nil
    self.ReadMailGotAttach = nil
    self.ReadMailNoAttach = nil
	self.SortedMailIDList = nil
end

function EmailMgr:AddMail(nMailID, nSendType, sTitle, sContent, nSenderID, sSenderName, nSendDate, nGold, bIsRead, hasAttachment)
	if self.mails[nMailID] ~= nil then
		return
	end
	local mail = MailStruct:New()
	mail.MailID = nMailID
	mail.nSendType = nSendType
	mail.sTitle = sTitle
	mail.sContent = sContent
	mail.nSenderID = nSenderID
	mail.sSenderName = sSenderName
	mail.nSendDate = nSendDate
	mail.nGold = nGold
	mail.bIsRead = bIsRead
	mail.hasAttachment = hasAttachment
    if mail.bIsRead == 0 and mail.hasAttachment == 1 then
        --self.NewMailHasAttach[nMailID] = mail
        table.insert(self.NewMailHasAttach, mail)
    elseif mail.bIsRead == 0 and mail.hasAttachment == 0 then
        --self.NewMailNoAttach[nMailID] = mail
        table.insert(self.NewMailNoAttach, mail)
    elseif mail.bIsRead == 1 and mail.nGold > 0 then
        --self.ReadMailHasAttach[nMailID] = mail
        table.insert(self.ReadMailHasAttach, mail)
    elseif mail.bIsRead == 1 and mail.hasAttachment == 1 and mail.nGold == 0 then
        --self.ReadMailGotAttach[nMailID] = mail
        table.insert(self.ReadMailGotAttach, mail)
    else
        --self.ReadMailNoAttach[nMailID] = mail
        table.insert(self.ReadMailNoAttach, mail)
    end
	--self.mails[nMailID] = mail
end

function EmailMgr:ReadMail(nMailID)
    local mail = GetMail(self.NewMailHasAttach, nMailID)
    if mail ~= nil then
        mail.bIsRead = 1
        table.insert(self.ReadMailHasAttach, mail)
        table.sort(self.ReadMailHasAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
        DeleteMail(self.NewMailHasAttach, nMailID)
    else
        mail = GetMail(self.NewMailNoAttach, nMailID)
        if mail ~= nil then
            mail.bIsRead = 1
            table.insert(self.ReadMailNoAttach, mail)
            table.sort(self.ReadMailNoAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
            DeleteMail(self.NewMailNoAttach, nMailID)
        end
    end
end

function EmailMgr:GetMailReward(nMailID)
    local mail = GetMail(self.ReadMailHasAttach, nMailID)
    if mail ~= nil then
        mail.nGold = 0
        table.insert(self.ReadMailGotAttach, mail)
        table.sort(self.ReadMailGotAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
        DeleteMail(self.ReadMailHasAttach, nMailID)
    end
end

function EmailMgr:SortMail()
    table.sort(self.NewMailHasAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
    table.sort(self.NewMailNoAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
    table.sort(self.ReadMailHasAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
    table.sort(self.ReadMailGotAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
    table.sort(self.ReadMailNoAttach, function(a, b) return a.nSendDate > b.nSendDate; end)
end

function GetTableCount(tab)
    local count = 0

    for k, v in pairs(tab) do
        count = count + 1
    end

    return count
end

function GetMail(tab, mailId)
    for k, v in pairs(tab) do
        if v.MailID == mailId then
            return v
        end
    end
end

function DeleteMail(tab, mailId)
    for k, v in pairs(tab) do
        if v.MailID == mailId then
            tab[k] = nil
            break
        end
    end
end

--function EmailMgr:SortMail()
	--table.sort(self.mails, function (a, b)
     --   if b == nil or a == nil then
     --       return true
     --   end
    --
     --   local bool
	--	if a.bIsRead == 0 and b.bIsRead == 0 then
	--		if a.hasAttachment == 1 and b.hasAttachment == 1 then
	--			bool = a.nSendDate > b.nSendDate
	--		else
	--			bool = a.hasAttachment > b.hasAttachment
	--		end
	--	elseif a.bIsRead == 1 and b.bIsRead == 1 then
	--		if a.hasAttachment == 1 and b.hasAttachment == 1 then
	--			bool = a.nGold > b.nGold
	--		else
	--			bool = a.hasAttachment > b.hasAttachment
	--		end
	--	else
	--		bool = a.bIsRead < b.bIsRead
	--	end
    --
	--	return bool
	--end)
--end

function EmailMgr:DelMail(nMailID)
	if self.mails[nMailID] == nil then
		print('删除邮件时，找不到邮件 id = '..nMailID)
		return
	else
		local mailInfo = self.mails[nMailID]
		if mailInfo.bIsRead == 0 then
			GameData.ResetUnreadMailCount(GameData.RoleInfo.UnreadMailCount - 1)	
		end
		self.mails[nMailID] = nil
	end
	EmailMgr:RefreshSortMailIDList()
	-- 事件通知
	local eventArg = lua_NewTable(UpdateMailEventArgs)
	eventArg.Reason = 2
	eventArg.MailID = nMailID
 	CS.EventDispatcher.Instance:TriggerEvent(EventDefine.UpdateEmailInfo, eventArg)
end

function EmailMgr:IsReadEmail(nMailID)
	if self.mails[nMailID] == nil then
		print('检查邮件阅读状态时，找不到邮件 id = '..nMailID)
		return
	end
	
	return self.mails[nMailID].bIsRead == 1
end

function EmailMgr:GetMailList()
	return self.mails
end

function EmailMgr:RefreshSortMailIDList()
	print("刷新邮件排序列表")
	local forSortItem = {}
	for	key, value in pairs(self.mails) do
		local item = {}
		item.Date = value.nSendDate
		item.MailID = value.MailID
		table.insert(forSortItem, item)
	end
	table.sort(forSortItem, function(a,b) return a.Date > b.Date end)
	local resultTable = {}
	for k, v in pairs(forSortItem) do
		resultTable[k] = v.MailID
	end
	self.SortedMailIDList = resultTable
end

function EmailMgr:GetMailIDListOfSortBySendData()
	return self.SortedMailIDList
end

function EmailMgr:RefreshUnreadMailCount()
	local unreadCount = 0
	for key,mailInfo in pairs(self.mails) do
		if mailInfo.bIsRead == 0 then
			unreadCount = unreadCount + 1
		end		
	end
	GameData.ResetUnreadMailCount(unreadCount)
end

-- 获取邮件显示内容
function EmailMgr:GetMailDisplayContent(mailInfo)
	local sendType = mailInfo.nSendType
	if sendType == MAIL_TYPE.INVITE then
		return data.MailContentConfig[sendType].Value
	elseif sendType == MAIL_TYPE.PROMOTER then
		local formatStr = data.MailContentConfig[sendType].Value
		return string.format(formatStr, mailInfo.sContent, tostring(GameData.RoleInfo.AccountID))
	elseif sendType == MAIL_TYPE.PASSWORD then
		local formatStr = data.MailContentConfig[sendType].Value
		return string.format(formatStr, mailInfo.sContent)
	elseif sendType == MAIL_TYPE.REBATE then
		local formatStr = data.MailContentConfig[sendType].Value
		return string.format(formatStr, lua_CommaSeperate(GameConfig.GetFormatColdNumber(mailInfo.sContent)))
	else	
		return mailInfo.sContent
	end
end