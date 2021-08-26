Interface:setEvent("add_bone", "onClientGUIClick", function(isLeft, isUp)
    if isLeft and isUp then
        Interface:ask(function(boneId)
            Interface:addBone(tonumber(boneId))
        end, "What's the bone ID you want to edit?")
    end
end)

Interface:setEvent("remove_bone", "onClientGUIClick", function(isLeft, isUp)
    if isLeft and isUp then
        Interface:removeBone()
    end
end)

Interface:setEvent("bone_list", "onClientGUIClick", function(isLeft, isUp, boneList)
    if isLeft and isUp then
        local row, column = guiGridListGetSelectedItem(boneList)
        if row < 0 then
            Interface:selectBone(false)
            return false
        end

        local boneId = tonumber(guiGridListGetItemText(boneList, row, 1))
        Interface:selectBone(boneId)
    end
end)