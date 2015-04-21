Packrat = Packrat or {}
Packrat.PackratUI = Packrat.PackratUI or {}

function Packrat.PackratUI.Initialize()
    Packrat.PackratUI.window = PackratUIWindow
    Packrat.PackratUI.treeScrollChild = PackratUIWindowTreeScrollChild

    PackratUIWindowLabel:SetText(GetString(SI_PACKRAT_TITLE))
    PackratUIWindowMail:SetText(GetString(SI_PACKRAT_MAIL_BUTTON))
    PackratUIWindowScan:SetText(GetString(SI_PACKRAT_SCAN_BUTTON))

    Packrat.PackratUI.CreateTree()
    Packrat.PackratUI.PopulateTree()
end

function Packrat.PackratUI.CreateTree()
    Packrat.PackratUI.navigationTree = ZO_Tree:New(Packrat.PackratUI.treeScrollChild, 25, 0, 1000)

    local openTexture = "EsoUI/Art/Buttons/tree_open_up.dds"
    local closedTexture = "EsoUI/Art/Buttons/tree_closed_up.dds"
    local overOpenTexture = "EsoUI/Art/Buttons/tree_open_over.dds"
    local overClosedTexture = "EsoUI/Art/Buttons/tree_closed_over.dds"

    local function TreeHeaderSetup(node, control, data, open)
        if open then end

        local text = control:GetNamedChild("Text")
        local icon = control:GetNamedChild("Icon")
        local iconHighlight = icon:GetNamedChild("Highlight")

        text:SetModifyTextType(MODIFY_TEXT_TYPE_UPPERCASE)
        text:SetFont("ZoFontWinH4")
        text:SetText(data)
        text:SetSelected(open)
        icon:SetTexture(open and openTexture or closedTexture)
        iconHighlight:SetTexture(open and overOpenTexture or overClosedTexture)
    end

    Packrat.PackratUI.navigationTree:AddTemplate("PackratUITreeHeader", TreeHeaderSetup, nil, nil, nil, 0)

    local function TreeEntrySetup(node, control, data, open)
        control:SetFont("ZoFontWinH4")
        control:SetText(data)
        control:SetSelected(false)
    end

    local function TreeEntryOnSelected(control, data, selected, reselectingDuringRebuild)
        control:SetSelected(selected)

        local texture = GetControl(control, "Icon")
        texture.selected = selected
        if selected then
            texture:SetTexture("EsoUI/Art/Journal/journal_Quest_Selected.dds")
            texture:SetAlpha(1.00)
            texture:SetHidden(false)
        else
            texture:SetHidden(true)
        end
    end

    local function TreeEntryEquality(left, right)
        return left.name == right.name
    end

    Packrat.PackratUI.navigationTree:AddTemplate("PackratUITreeNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)

    Packrat.PackratUI.navigationTree:SetExclusive(false)
    Packrat.PackratUI.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")
end

function Packrat.PackratUI.PopulateTree()
    Packrat.PackratUI.navigationTree:Reset()

    local categoryNodes = {}

    categoryNodes[ARMORTYPE_NONE] = Packrat.PackratUI.navigationTree:AddNode("PackratUITreeHeader", GetString(SI_PACKRAT_HEADERNODE_OTHER), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[ARMORTYPE_LIGHT] = Packrat.PackratUI.navigationTree:AddNode("PackratUITreeHeader", GetString(SI_PACKRAT_HEADERNODE_LIGHT), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[ARMORTYPE_MEDIUM] = Packrat.PackratUI.navigationTree:AddNode("PackratUITreeHeader", GetString(SI_PACKRAT_HEADERNODE_MEDIUM), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[ARMORTYPE_HEAVY] = Packrat.PackratUI.navigationTree:AddNode("PackratUITreeHeader", GetString(SI_PACKRAT_HEADERNODE_HEAVY), nil, SOUNDS.QUEST_BLADE_SELECTED)

    Packrat.PackratUI.AddNodes(Packrat.savedVars.sets[ARMORTYPE_NONE], categoryNodes[ARMORTYPE_NONE])
    Packrat.PackratUI.AddNodes(Packrat.savedVars.sets[ARMORTYPE_LIGHT], categoryNodes[ARMORTYPE_LIGHT])
    Packrat.PackratUI.AddNodes(Packrat.savedVars.sets[ARMORTYPE_MEDIUM], categoryNodes[ARMORTYPE_MEDIUM])
    Packrat.PackratUI.AddNodes(Packrat.savedVars.sets[ARMORTYPE_HEAVY], categoryNodes[ARMORTYPE_HEAVY])

    Packrat.PackratUI.navigationTree:Commit()
end

local function PairsByKeys(tbl, sortFunction)
    local array = {}
    for key in pairs(tbl) do table.insert(array, key) end
    table.sort(array, sortfunction)
    local i = 0 --iterator variable
    local iter = function() --iterator function
        i = i + 1
        if array[i] == nil then 
            return nil
        else 
            return array[i], tbl[array[i]] --key, table
        end
    end
    return iter
end

function Packrat.PackratUI.AddNodes(dataTable, baseNode)
    for setName,setTable in PairsByKeys(dataTable) do
        local parentNode = Packrat.PackratUI.navigationTree:AddNode("PackratUITreeHeader", setName, baseNode, SOUNDS.QUEST_BLADE_SELECTED)
        for itemName, itemTable in PairsByKeys(setTable) do
            Packrat.PackratUI.navigationTree:AddNode("PackratUITreeNavigationEntry", itemName, parentNode, SOUNDS.QUEST_SELECTED)
        end
    end
end

--[[XML Functions]]
function Packrat.PackratUI.ToggleWindow(upInside)
    if upInside == nil or upInside == true then
        Packrat.PackratUI.window:SetHidden(not Packrat.PackratUI.window:IsHidden())
    end
end

local function TreeHeader_OnMouseEnter(control)
    ZO_SelectableLabel_OnMouseEnter(control:GetNamedChild("Text"))
    control:GetNamedChild("Icon"):GetNamedChild("Highlight"):SetHidden(false)
end

local function TreeHeader_OnMouseExit(control)
    ZO_SelectableLabel_OnMouseEnter(control:GetNamedChild("Text"))
    control:GetNamedChild("Icon"):GetNamedChild("Highlight"):SetHidden(true)
end

local function TreeHeader_OnMouseUp(control, upInside)
    if not upInside then return end

    local node = control.node
    if not node.open and not node.children then
        Packrat.PackratUI.AddNodes(node.data.nodeTable, node)
    end

    ZO_TreeHeader_OnMouseUp(control, upInside)
end

function Packrat.PackratUI.TreeHeader_OnInitialized(self)
    self.OnMouseEnter = TreeHeader_OnMouseEnter
    self.OnMouseExit = TreeHeader_OnMouseExit
    self.OnMouseUp = TreeHeader_OnMouseUp
end

function Packrat.PackratUI.TreeNavigationEntry_OnEnter(self)
end

function Packrat.PackratUI.TreeNavigationEntry_OnExit(self)
end

function Packrat.PackratUI.TreeNavigationEntry_OnMouseUp(self, button, upInside)
    if not upInside then return end

    if button == 1 then
        if(upInside and self.node.tree.enabled) then
            -- Play the selected sound if not already selected
            if(not self.node.selected and self.node.selectSound) then
                PlaySound(self.node.selectSound)
            end
            self.node:GetTree():ToggleNode(self.node)
            self.node:GetTree():SelectNode(self.node)
        end
    --[[elseif button == 2 then
    end
    if(button == 2 and upInside) then]]
    end
end

--[[function Packrat.PackratUI.Initialize()
	Packrat.PackratUI.CreateScene()
	Packrat.PackratUI.RefreshTree()
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
	Packrat.PackratUI.navigationTree = ZO_Tree:New(container, 40, -10, 300)

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
    Packrat.PackratUI.navigationTree:AddTemplate("ZO_QuestJournalHeader", TreeHeaderSetup, nil, nil, nil, 0)

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
    Packrat.PackratUI.navigationTree:AddTemplate("PR_SetNavigationEntry", TreeEntrySetup, TreeEntryOnSelected, TreeEntryEquality)
    
    Packrat.PackratUI.navigationTree:SetExclusive(true)
    Packrat.PackratUI.navigationTree:SetOpenAnimation("ZO_TreeOpenAnimation")

    local parent = GetControl("ZO_SharedTreeUnderlay")
    container:SetAnchor(TOPLEFT, parent, TOPLEFT, 75, 200)
    PACKRAT_LEFT_NAVIGATION_FRAGMENT = ZO_FadeSceneFragment:New(container)
end

function Packrat.PackratUI.CreateRightFragment()
end

function Packrat.PackratUI.RefreshTree()
	local questIndexToTreeNode = {}
	categoryNodes = {}

	Packrat.PackratUI.navigationTree:Reset()

    categoryNodes[0] = Packrat.PackratUI.navigationTree:AddNode("ZO_QuestJournalHeader", GetString(SI_PACKRAT_HEADERNODE_OTHER), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[1] = Packrat.PackratUI.navigationTree:AddNode("ZO_QuestJournalHeader", GetString(SI_PACKRAT_HEADERNODE_LIGHT), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[2] = Packrat.PackratUI.navigationTree:AddNode("ZO_QuestJournalHeader", GetString(SI_PACKRAT_HEADERNODE_MEDIUM), nil, SOUNDS.QUEST_BLADE_SELECTED)
    categoryNodes[3] = Packrat.PackratUI.navigationTree:AddNode("ZO_QuestJournalHeader", GetString(SI_PACKRAT_HEADERNODE_HEAVY), nil, SOUNDS.QUEST_BLADE_SELECTED)

    for i,v in pairs(Packrat.savedVars.sets) do
        for k = 0, 3 do
            for j, w in pairs(v[k]) do
                Packrat.PackratUI.navigationTree:AddNode("ZO_QuestJournalHeader", j, categoryNodes[k], SOUNDS.QUEST_SELECTED)
            end
        end
    end
end]]