
if MusicMgr == nil then

    MusicMgr = 
    {
        tAudioClips = {},
        tPlayers = {},
        backMusicPlayer = nil,
        playerCount = 18,
        isMuteBackMusic = false,
        isMuteSoundEffect = false,
        AudioGroups = {},                   -- 音效播放组 exp:audiGroupInfo = {AudioCountMax = configGroup.AudioSourceCount, UseAudioIndexList = {},}
        PlayingAudios = {},                 -- 播放中的Audio关联音效组ID exp：playingAudioInfo = {index = audioIndex, groupid = configData.MusicGroup,}
        pausePlaySoundEffect = false,       -- 是否暂停音效播放
        isApplicationQuit = false,          -- 游戏是否退出
    }
end

-- 播放音效
function MusicMgr.PlaySoundAudio(musicID)
    --print("==================",musicID)
    MusicMgr:PlaySoundEffect(tostring(musicID))
end

-- 获取指定Audio的时长 单位:毫秒
function MusicMgr.GetSoundAudioTime(musicid)
    local configData = data.MusicConfig[musicid]
    if nil ~= configData then
        return configData.Time
    end
    return 0
end

-------内部函数 起------------------------------------------------

--==============================--
--desc:播放音效接口
--time:2018-01-09 03:48:01
--@musicID:音效ID(string类型 便于音效变更插入功能)
--@return 
--==============================--
function MusicMgr:PlaySoundEffect(musicID)

    --print(string.format( "=====播放音效ID:[%d] =====Time:[%f]", musicID, CS.UnityEngine.Time.time))
    -- 暂停播放检测
    if true == MusicMgr.pausePlaySoundEffect then
        return
    end

    --获取空闲的播放器
    local item = nil
    local audioIndex = 1
    for index = 1, MusicMgr.playerCount, 1  do
        if MusicMgr.tPlayers== nil or MusicMgr.tPlayers[index] == nil then
            return
        end
        
        if MusicMgr.tPlayers[index].isPlaying == false then
            item = MusicMgr.tPlayers[index]
            audioIndex = index
        end
    end
    if item == nil then
        print('已经没有可用的音效播放器')
        return
    end

    local configData = data.MusicConfig[musicID]
    if configData == nil then
        print('音效配置有误1,ID:',musicID, CS.UnityEngine.Time.time)
        return
    end

    if MusicMgr.tAudioClips[configData.Name] == nil then
        print('音效配置有误2,ID:',configData.Name)
        return
    end

    if configData.MusicGroup ~= 0 then
        --该音效处于播放组
        if false == CanPlayAudioInAudioGroup(configData.MusicGroup) then
            print(string.format("音效组:[%d]播放池已满...",configData.MusicGroup))
            return
        else
            local playingAudioInfo = {index = audioIndex, groupid = configData.MusicGroup,}
            table.insert(MusicMgr.PlayingAudios,playingAudioInfo)
            table.insert(MusicMgr.AudioGroups[configData.MusicGroup].UseAudioIndexList,audioIndex)
        end
    end

    --播放音频剪辑
    item.clip = MusicMgr.tAudioClips[configData.Name]
    item:Play()
end

-- 停止播放所有音效
function MusicMgr:StopAllSoundEffect()
    -- body
    if true == MusicMgr.isApplicationQuit then
        return
    end

    local playerCount = #MusicMgr.tPlayers
    for index = 1, playerCount, 1  do
        local item = MusicMgr.tPlayers[index]
        if nil ~= item then
            if item.isPlaying == true then
                item:Stop()
            end
        end
    end
end

-- 设置是否赞同音效播放
function PausePlaySoundEffect( isPause)
    MusicMgr.pausePlaySoundEffect = isPause
end

--当前Audio组能否继续播放音效
function CanPlayAudioInAudioGroup(groupid)
    local audiGroupInfo = MusicMgr.AudioGroups[groupid]
    if nil == audiGroupInfo then
        local configGroup = data.MusicGroupConfig[groupid]
        if nil == configGroup then
            print("MusicGroupConfig find groupid: " .. groupid .. " fail! Please check MusicGroupConfig.lua!")
            return false
        end
        audiGroupInfo = {AudioCountMax = configGroup.AudioSourceCount, UseAudioIndexList = {},}
        MusicMgr.AudioGroups[groupid] = audiGroupInfo
    end
    if #audiGroupInfo.UseAudioIndexList >= audiGroupInfo.AudioCountMax then
        return false
    end
    return true
end

-- 更新Audio组count
function UpdateAudioGroupCount()
    -- body
    local count = #MusicMgr.PlayingAudios
    if count == 0 then
        return
    end
    for i = count, 1, -1 do
        local playingAudioItem = MusicMgr.PlayingAudios[i]
        local item = MusicMgr.tPlayers[playingAudioItem.index]
        if nil ~= item and item.isPlaying == false then
            --该Audio已经播放完毕
            local groupInfo = MusicMgr.AudioGroups[playingAudioItem.groupid]
            for k,v in pairs(groupInfo.UseAudioIndexList) do
                if v == playingAudioItem.index then
                    table.remove(groupInfo.UseAudioIndexList,k)
                    break
                end
            end
            table.remove(MusicMgr.PlayingAudios,i)
        end
    end
end

-- 当前播放的背景音乐信息
local mCurrentPlayBackGroundAudioName = ""
local mCurrentPlayBackGrouneAudio = nil

function MusicMgr:PlayBackMusic(musicID)
    if MusicMgr.backMusicPlayer:IsNull() == true then
        print(string.format("===1==背景音乐AudioSources:%s 不存在", musicID))
        return
    end
    local configData = data.MusicConfig[musicID]
    if configData == nil then
        print(string.format( "===2==背景音乐配置数据:%s 不存在", musicID))
        return
    end

    if mCurrentPlayBackGroundAudioName == configData.Name then
        -- 已经在播放该背景音乐
        if mCurrentPlayBackGrouneAudio ~= nil then
            MusicMgr.backMusicPlayer.clip = mCurrentPlayBackGrouneAudio
            MusicMgr.backMusicPlayer:Play()
        else
            -- 可能正在加载....
            print(string.format("===1==背景音效播放过快：", musicID))
        end
    else
        -- 还未播放(加载)
        MusicMgr:LoadBackGroundAudioClip(musicID)
    end 
end

function MusicMgr:LoadBackGroundAudioClip(musicID)
    local configData = data.MusicConfig[musicID]
    if configData == nil then
        return
    end
    mCurrentPlayBackGroundAudioName = configData.Name
    if CS.LuaAsynFuncMgr.Instance:IsNull() then
        print("===== CS.LuaAsynFuncMgr IsNull!")
        return 
    end
    CS.LuaAsynFuncMgr.Instance:LoadAudioClip(configData.Name,MusicMgr.LoadBackGroundCallback)
end

function MusicMgr.LoadBackGroundCallback(audioClip, name)
    if mCurrentPlayBackGroundAudioName == name then
        mCurrentPlayBackGrouneAudio = nil
        mCurrentPlayBackGrouneAudio = audioClip
        MusicMgr.backMusicPlayer.clip = audioClip    
        MusicMgr.backMusicPlayer:Play()
    else
        print("===2==背景音效切换过快,资源Name:", name, mCurrentPlayBackGroundAudioName)
    end
    
end

-- 停止播放背景音效
function MusicMgr:StopBackMusic()
    if MusicMgr.backMusicPlayer == nil then
        return
    end
    MusicMgr.backMusicPlayer:Stop()
end

-- 继续播放背景音乐
function ContinueBackMusic()
    if MusicMgr.backMusicPlayer == nil then
        return
    end
    MusicMgr.backMusicPlayer:Play()
end

-- 暂停播放背景音乐
function MusicMgr:PauseBackMusic()
    if MusicMgr.backMusicPlayer == nil then
        return
    end
    MusicMgr.backMusicPlayer:Pause()
end

function MusicMgr:LoadAudioClip(musicID)
    local configData = data.MusicConfig[musicID]
    if configData == nil then
        return
    end

    if MusicMgr.tAudioClips[configData.Name] ~= nil then
        return
    end
    CS.LuaAsynFuncMgr.Instance:LoadAudioClip(configData.Name,MusicMgr.LoadCallback)
end

function MusicMgr.LoadCallback(audioClip, name)
	MusicMgr.tAudioClips[name] = audioClip
end

function MusicMgr:LoadAllAudioClip()
    for k,v in pairs(data.MusicConfig) do
        --print(string.format('key = %s, value = %s', k, v.Name))
        -- 背景音乐无须预加载
        local bkFlag =  string.find(v.Name, 'back_')
        if v.Name ~= 'null' and (bkFlag == nil or bkFlag ~= 1) then
            MusicMgr:LoadAudioClip(k)
        end
    end
end

function MusicMgr:OnLoadAudioCallBack(musicID, resource)
	
end

--------内部函数 止-------------------------------------

-------------------------------系统函数 开始-----------------------

function MusicMgr:Init()
    --检查舞台上是否有播放器依附的gameobject
    local musicObj = CS.UnityEngine.GameObject.Find('[AudioManager]')
    if musicObj ~= nil then
        print('已经初始化过musicmgr了')
        CS.UnityEngine.Object.Destroy(musicObj.gameObject)
    else
        
    end

    --创建gameobject
    local obj = CS.UnityEngine.GameObject()
    obj.name = '[AudioManager]'
    obj.transform.position = CS.UnityEngine.Vector3.zero
    obj.transform.localScale = CS.UnityEngine.Vector3.one
    CS.UnityEngine.Object.DontDestroyOnLoad(obj)
    --添加组件
    MusicMgr.backMusicPlayer = obj:AddComponent(typeof(CS.UnityEngine.AudioSource))
    MusicMgr.backMusicPlayer.loop = true
    MusicMgr.backMusicPlayer.volume = 0.4

    for index = 1, MusicMgr.playerCount, 1  do
        local item
        item = obj:AddComponent(typeof(CS.UnityEngine.AudioSource))
        table.insert(MusicMgr.tPlayers, item)
    end

    local sBackMusicMute = CS.UnityEngine.PlayerPrefs.GetString("Game_Music_Mute", "0")
    local iBackMusicNute = tonumber(sBackMusicMute)
    if iBackMusicNute == 1 then
        MusicMgr:MuteBackMusic(true)
    else
        MusicMgr:MuteBackMusic(false)
    end

    local sSoundEffectMute = CS.UnityEngine.PlayerPrefs.GetString("Game_Sound_Effect_Mute", "0")
    local iSoundEffectMute = tonumber(sSoundEffectMute)
    if iSoundEffectMute == 1 then
        MusicMgr:MuteSoundEffect(true)
    else
        MusicMgr:MuteSoundEffect(false)
    end

    --print(string.format('iBackMusicNute = %d, iSoundEffectMute = %d', iBackMusicNute, iSoundEffectMute))

    MusicMgr:LoadAllAudioClip()
    --添加Updata事件
    CS.LuaManager.UpdateEvent("-", MusicMgr.Update)
    CS.LuaManager.UpdateEvent("+", MusicMgr.Update)
    CS.EventDispatcher.Instance:RemoveEventListener("OnApplicationPause", MusicMgr.OnApplicationPauseEvent)
    CS.EventDispatcher.Instance:RemoveEventListener("OnApplicationQuit", MusicMgr.OnApplicationQuitEvent)
    CS.EventDispatcher.Instance:AddEventListener("OnApplicationPause", MusicMgr.OnApplicationPauseEvent)
    CS.EventDispatcher.Instance:AddEventListener("OnApplicationQuit", MusicMgr.OnApplicationQuitEvent)
end

-- 游戏切入切除
function MusicMgr.OnApplicationPauseEvent(pause)
    MusicMgr:StopAllSoundEffect()
end

-- APP 推出
function MusicMgr.OnApplicationQuitEvent(quit)
    MusicMgr.isApplicationQuit = quit
end

function MusicMgr.Update()
    UpdateAudioGroupCount()
end

function MusicMgr:Destory()
    MusicMgr.tPlayers = {}
    MusicMgr.backMusicPlayer = nil
    MusicMgr.AudioGroups = {}
    MusicMgr.PlayingAudios = {}
    MusicMgr.tAudioClips = {}
    CS.LuaManager.UpdateEvent("-", MusicMgr.Update)
    CS.EventDispatcher.Instance:RemoveEventListener("OnApplicationPause", MusicMgr.OnApplicationPauseEvent)
    CS.EventDispatcher.Instance:RemoveEventListener("OnApplicationQuit", MusicMgr.OnApplicationQuitEvent)
end

function MusicMgr:SetBackMusicVol(param)
    MusicMgr.backMusicPlayer.volume = param
end

function MusicMgr:SetPlayersVol(param)
    for index = 1, MusicMgr.playerCount, 1  do
        MusicMgr.tPlayers[index].volume = param
    end
end

function MusicMgr:MuteBackMusic(isMute)
    MusicMgr.isMuteBackMusic = isMute
    MusicMgr.backMusicPlayer.mute = isMute
    if isMute then
        CS.UnityEngine.PlayerPrefs.SetString("Game_Music_Mute", "1")
    else
        CS.UnityEngine.PlayerPrefs.SetString("Game_Music_Mute", "0")
    end
end

function MusicMgr:MuteSoundEffect(isMute)
    MusicMgr.isMuteSoundEffect = isMute
    for index = 1, MusicMgr.playerCount, 1  do
        MusicMgr.tPlayers[index].mute = isMute
    end
    if isMute then
        CS.UnityEngine.PlayerPrefs.SetString("Game_Sound_Effect_Mute", "1")
    else
        CS.UnityEngine.PlayerPrefs.SetString("Game_Sound_Effect_Mute", "0")
    end
end

-------------------------------系统函数 结束-----------------------