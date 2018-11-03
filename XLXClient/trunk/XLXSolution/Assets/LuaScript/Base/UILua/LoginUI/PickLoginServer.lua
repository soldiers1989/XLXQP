function Start()
    -- if	GameConfig.IsSelectServer == 0 then
    --     this.gameObject:SetActive(false)
    --     return
    -- end

    for	 index = 1, 6, 1 do
        local toggleTrans = this.transform:Find('Toggle'.. index)
        if toggleTrans ~= nil then
            toggleScript = toggleTrans:GetComponent("Toggle")
            toggleScript.onValueChanged:AddListener(function (isOn) Toggle_OnValueChanged(isOn, index) end)
            if toggleScript.isOn == true then
                Toggle_OnValueChanged(true, index)
            end
        end
    end
end

function Toggle_OnValueChanged(isOn, index)
    if isOn then
        if index == 1 then
            GameConfig.HubServerURL = "clysz.hub.changlaith.com"
        elseif index == 2 then
            GameConfig.HubServerURL = "clsdp.v140hub.changlaith.com"
        elseif index == 3 then
            GameConfig.HubServerURL = "clysz.hub.out.changlaith.com"
        elseif index == 4 then
            GameConfig.HubServerURL = "clysz.hub.in.changlaith.com"
        elseif index == 5 then
            GameConfig.HubServerURL = "10.8.3.140"
        elseif index == 6 then
            GameConfig.HubServerURL = "10.8.3.231"
        end
    end
end