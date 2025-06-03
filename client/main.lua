addCommandHandler("pbone", function()
    if Interface then
        Interface:setVisible(not Interface:getVisible())
    end
end)

addCommandHandler("copybones", function(_, mode)
    if not (Interface and Interface:getVisible()) then
        return false
    end

    local mode = mode and mode:lower()

    if not (mode == "positive" or mode == "center") then
        outputChatBox("Invalid mode. Use 'positive' or 'center'.", 255, 0, 0)
        return false
    end

    setClipboard(Interface:getListRaw(mode))
    outputChatBox("Bones copied to clipboard.", 0, 255, 0)
end)