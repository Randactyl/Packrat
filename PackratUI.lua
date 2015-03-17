Packrat = Packrat or {}
Packrat.PackratUI = Packrat.PackratUI or {}

function Packrat.PackratUI.Initialize()
	Packrat.PackratUI.CreateScene()
end

function Packrat.PackratUI.CreateScene()
	--create fragments
	Packrat.PackratUI.CreateLeftFragment()
	Packrat.PackratUI.CreateRightFragment()

	--add default fragments
	PACKRAT_SCENE = ZO_Scene:New("packrat", SCENE_MANAGER)
	PACKRAT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.MOUSE_DRIVEN_UI_WINDOW)
    PACKRAT_SCENE:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_STANDARD_RIGHT_PANEL)
    PACKRAT_SCENE:AddFragment(RIGHT_BG_FRAGMENT)
    PACKRAT_SCENE:AddFragment(TITLE_FRAGMENT)
    PACKRAT_SCENE:AddFragment(PLAYER_PROGRESS_BAR_FRAGMENT)
    PACKRAT_SCENE:AddFragment(PLAYER_PROGRESS_BAR_CURRENT_FRAGMENT)
    PACKRAT_SCENE:AddFragment(TREE_UNDERLAY_FRAGMENT)

    --add custom fragments
    PACKRAT_SCENE:AddFragment(PACKRAT_LEFT_NAVIGATION_FRAGMENT)

    local pos = #MAIN_MENU.sceneGroupInfo.journalSceneGroup.menuBarIconData + 1
    MAIN_MENU.sceneGroupInfo.journalSceneGroup.menuBarIconData[pos] = {
    	categoryName = SI_PACKRAT_TITLE,
    	descriptor = "packrat",
    	normal = "EsoUI/Art/Campaign/campaign_tabIcon_summary_up.dds",
        pressed = "EsoUI/Art/Campaign/campaign_tabIcon_summary_down.dds",
        highlight = "EsoUI/Art/Campaign/campaign_tabIcon_summary_over.dds",
	}

	SCENE_MANAGER:GetSceneGroup("journalSceneGroup").scenes[pos] = "packrat"
	PACKRAT_SCENE:AddFragment(ZO_FadeSceneFragment:New(MAIN_MENU.sceneGroupBar))

	MAIN_MENU:AddRawScene("packrat", 6, MAIN_MENU.categoryInfo[6], "journalSceneGroup")
end

function Packrat.PackratUI.CreateLeftFragment()
	local container = WINDOW_MANAGER:CreateTopLevelWindow("PackratNavigationContainer")
	--local scroll = WINDOW_MANAGER:CreateControl("($Parent)Scroll", container, CT_SCROLL)
	local navigationTree = ZO_Tree:New(container, 40, -10, 300)

	local openTexture = "EsoUI/Art/Buttons/tree_open_up.dds"
    local closedTexture = "EsoUI/Art/Buttons/tree_closed_up.dds"
    local overOpenTexture = "EsoUI/Art/Buttons/tree_open_over.dds"
    local overClosedTexture = "EsoUI/Art/Buttons/tree_closed_over.dds"

    local function TreeHeaderSetup(node, control, name, open)
        control.text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        control.text:SetText(name)

        control.icon:SetTexture(open and openTexture or closedTexture)
        control.iconHighlight:SetTexture(open and overOpenTexture or overClosedTexture)

        control.text:SetSelected(open)
    end
    navigationTree:AddTemplate("PR_SetHeader", TreeHeaderSetup, nil, nil, nil, 0)

    local function TreeEntrySetup(node, control, data, open)
        control:SetText(data.name)
        control.con = GetCon(data.level)
        control.questIndex = data.questIndex
        control:SetSelected(false)
        
        local texture = GetControl(control, "Icon")
        texture.selected = false
        texture:SetTexture(self:GetIconTexture(data.displayType))
        texture.tooltipText = self:GetTooltipText(data.displayType)

        if data.displayType == INSTANCE_DISPLAY_TYPE_NONE then
            texture:SetHidden(true)
        else
            texture:SetAlpha(0.50)
            texture:SetHidden(false)
        end
    end
    local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        self:FireCallbacks("QuestSelected", data.questIndex)
        control:SetSelected(selected)
        if selected and not reselectingDuringRebuild then
            self:SetFocusIndex(data.questIndex)
            self:RefreshDetails()
            -- The quest tracker performs focus logic on quest/remove/update, only force focus if the player has clicked on the quest through the journal UI
            if SCENE_MANAGER:IsShowing(self.sceneName) then
                QUEST_TRACKER:ForceAssist(data.questIndex)
            end
        end

        local texture = GetControl(control, "Icon")
        texture.selected = selected
        if selected then
            texture:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
            texture:SetAlpha(1.00)
            texture:SetHidden(false)
        else
            texture:SetTexture(self:GetIconTexture(data.displayType))
            if data.displayType == INSTANCE_DISPLAY_TYPE_NONE then
                texture:SetHidden(true)
            else
                texture:SetAlpha(0.50)
                texture:SetHidden(false)
            end
        end
    end
    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end
    navigationTree:AddTemplate("PR_SetNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)
    
    navigationTree:SetExclusive(true)
    navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")

    local parent = GetControl("ZO_SharedTreeUnderlay")
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
    PACKRAT_LEFT_NAVIGATION_FRAGMENT = ZO_FadeSceneFragment:New(container)
end

function Packrat.PackratUI.CreateRightFragment()
end