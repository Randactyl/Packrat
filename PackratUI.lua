Packrat = Packrat or {}
Packrat.PackratUI = Packrat.PackratUI or {}

function Packrat.PackratUI.Initialize()
	PACKRAT_SCENE = ZO_Scene:New("packrat", SCENE_MANAGER)
	PACKRAT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    PACKRAT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    PACKRAT_SCENE:AddFragment(RIGHT_BG_FRAGMENT)

    PACKRAT_SCENE:AddFragment(TITLE_FRAGMENT)

    PACKRAT_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
    PACKRAT_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)

    local pos = #MAIN_MENU.sceneGroupInfo.journalSceneGroup.menuBarIconData + 1
    MAIN_MENU.sceneGroupInfo.journalSceneGroup.menuBarIconData[pos] = {
    	categoryName = "Packrat",
    	descriptor = "packrat",
    	normal = "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
        pressed = "EsoUI/Art/Campaign/campaign_tabIcon_summary_down.dds",
        highlight = "EsoUI/Art/Campaign/campaign_tabIcon_summary_over.dds",
	}

	SCENE_MANAGER:GetSceneGroup("journalSceneGroup").scenes[pos] = "packrat"
	PACKRAT_SCENE:AddFragment(ZO_FadeSceneFragment:New(MAIN_MENU.sceneGroupBar))

	MAIN_MENU:AddRawScene("packrat", 6, MAIN_MENU.categoryInfo[6], "journalSceneGroup")
end