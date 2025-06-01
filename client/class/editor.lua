local screenX, screenY = guiGetScreenSize()
local wWidth, wHeight = 350, 225

Editor = {}
Editor.__index = Editor

local BONE_TYPES = {
    "yaw", "pitch", "roll"
}

local boneIDs = {
    0, 1, 2, 3, 4, 5, 6, 7, 8, 21,
    22, 23, 24, 25, 26, 31, 32, 33,
    34, 35, 36, 41, 42, 43, 44, 51,
    52, 53, 54, 201, 301, 302
}

local function centerAngle(angle)
    angle = angle % 360

    if angle > 180 then
        angle = angle - 360
    end

    return angle
end

function Editor.create()
    local data = {
        bones = {},
        visible = false
    }
    local x, y = screenX - (wWidth + 10), (screenY - wHeight) / 2

    -- Editor
    data.window = guiCreateWindow(x, y, wWidth, wHeight, "Bone Rotation Preview", false)
    guiSetVisible(data.window, false)
    guiWindowSetMovable(data.window, false)
    guiWindowSetSizable(data.window, false)

    data.bone_list = guiCreateGridList(5, 25, 150, 100, false, data.window)
    guiGridListSetSortingEnabled(data.bone_list, false)
    guiGridListAddColumn(data.bone_list, "Bone ID", 0.85)

    data.add_bone = guiCreateButton(5, 130, 150, 25, "Add bone", false, data.window)
    data.remove_bone = guiCreateButton(5, 160, 150, 25, "Remove bone", false, data.window)
    guiSetVisible(data.remove_bone, false)

    local offsetY, height, margin = 25, 25, 20
    for index, boneType in pairs(BONE_TYPES) do
        local label = guiCreateLabel(165, offsetY, 80, 15, boneType:upper(), false, data.window)
        data[boneType] = guiCreateScrollBar(165, offsetY + 15, 200, height, true, false, data.window)

        offsetY = offsetY + height + margin
    end

    data.preview_box = guiCreateEdit(10, 190, wWidth - 20, 25, "", false, data.window)
    guiEditSetReadOnly(data.preview_box, true)
    guiSetVisible(data.preview_box, false)

    -- Form
    local formWidth, formHeight = 300, 95
    data.form = guiCreateWindow((screenX - formWidth) / 2, (screenY - formHeight) / 2, formWidth, formHeight, "", false)
    guiSetVisible(data.form, false)
    guiWindowSetMovable(data.form, false)
    guiWindowSetSizable(data.form, false)

    data.form_input = guiCreateEdit(30, 25, formWidth - 60, 30, "", false, data.form)
    guiEditSetMaxLength(data.form_input, 3)

    local inputWidth, inputHeight = guiGetSize(data.form_input, false)
    data.form_cancel = guiCreateButton(30, 60, inputWidth / 2 - 5, 30, "Cancel", false, data.form)
    guiSetProperty(data.form_cancel, "NormalTextColour", "FFFF5555")

    data.form_ok = guiCreateButton(30 + inputWidth / 2, 60, inputWidth / 2, 30, "OK", false, data.form)
    guiSetProperty(data.form_ok, "NormalTextColour", "FF55FF55")

    setmetatable(data, Editor)
    return data
end

function Editor:updateBones()
    for bone, data in pairs(self.bones) do
        setElementBoneRotation(localPlayer, bone, data.yaw, data.pitch, data.roll)
    end
    updateElementRpHAnim(localPlayer)

    if self.current_bone then
        for index, boneType in pairs(BONE_TYPES) do
            local scrollbar = self[boneType]
            if scrollbar then
                local value = guiScrollBarGetScrollPosition(scrollbar)
                local progress = (value / 100) * 360
                self.bones[self.current_bone][boneType] = progress
            end
        end

        local rot = self.bones[self.current_bone]
        local yaw, pitch, roll = rot.yaw, rot.pitch, rot.roll
        guiSetText(self.preview_box, ("%s, %s, %s"):format(yaw, pitch, roll))
    end

    showCursor(not getKeyState("mouse2"))
end

function Editor:setVisible(bool)
    if type(bool) ~= "boolean" then
        return false
    end
    guiSetInputMode("no_binds_when_editing")
    guiSetVisible(self.window, bool)
    showCursor(bool)
    showChat(not bool)

    if bool then
        self.handler = function()
            self:updateBones()
        end
        addEventHandler("onClientPedsProcessed", root, self.handler)
    else
        removeEventHandler("onClientPedsProcessed", root, self.handler)
        self.handler = nil
    end
    self.visible = bool
end

function Editor:getVisible()
    return self.visible
end

function Editor:setEvent(element, event, callback)
    local gui = self[element]
    if not gui then
        return false
    end
    addEventHandler(event, gui, function(button, state)
        local isLeft = button == "left"
        local isUp = state == "up"
        callback(isLeft, isUp, source)
    end, false)
end

function Editor:ask(callback, question)
    if guiGetVisible(self.form) == true then
        return false
    end

    guiSetVisible(self.form, true)
    guiSetText(self.form, question)

    self.form_callback = function(button, state)
        local isLeft = button == "left"
        local isUp = state == "up"
        if isLeft and isUp then
            if getElementType(source) ~= "gui-button" then
                return false
            end
            if source == self.form_ok then
                local input = guiGetText(self.form_input)
                callback(input)
            end
            guiSetText(self.form_input, "")
            guiSetVisible(self.form, false)
            removeEventHandler("onClientGUIClick", self.form, self.form_callback)
        end
    end
    addEventHandler("onClientGUIClick", self.form, self.form_callback)
end

function Editor:isBone(id)
    for index, boneId in pairs(boneIDs) do
        if boneId == id then
            return true
        end
    end
    return false
end

function Editor:addBone(boneId)
    if self.bones[boneId] then
        return false
    end

    if not self:isBone(boneId) then
        return false
    end

    local yaw, pitch, roll = getElementBoneRotation(localPlayer, boneId)

    local row = guiGridListAddRow(self.bone_list)
    guiGridListSetItemText(self.bone_list, row, 1, tostring(boneId), false, false)
    self.bones[boneId] = {yaw = yaw, pitch = pitch, roll = roll}
end

function Editor:removeBone(boneId)
    if not self.current_bone or not self.bones[self.current_bone] then
        return false
    end
    self.bones[self.current_bone] = nil
    self:refreshList()
    self:selectBone(false)
end

function Editor:refreshList()
    guiGridListClear(self.bone_list)
    for boneId in pairs(self.bones) do
        local row = guiGridListAddRow(self.bone_list)
        guiGridListSetItemText(self.bone_list, row, 1, tostring(boneId), false, false)
    end
end

function Editor:selectBone(boneId)
    if type(boneId) == "number" and not self.bones[boneId] then
        return false
    end

    if type(boneId) == "number" then
        for index, boneType in pairs(BONE_TYPES) do
            local scrollbar = self[boneType]
            if scrollbar then
                local value = self.bones[boneId][boneType]
                local progress = (value / 360) * 100
                guiScrollBarSetScrollPosition(scrollbar, progress)
            end
        end
    end

    self.current_bone = boneId
    guiSetVisible(self.remove_bone, type(boneId) == "number" and true or false)
    guiSetVisible(self.preview_box, type(boneId) == "number" and true or false)
end

function Editor:getRawBoneAngles(mode)
    local list = {}

    for boneId, data in pairs(self.bones) do
        local yaw, pitch, roll = data.yaw, data.pitch, data.roll

        if mode == "center" then
            yaw, pitch, roll = centerAngle(yaw), centerAngle(pitch), centerAngle(roll)
        end

        list[boneId] = { yaw, pitch, roll }
    end

    return inspect(list)
end