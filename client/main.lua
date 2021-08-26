addCommandHandler("pbone", function()
    if Interface then
        Interface:setVisible(not Interface:getVisible())
    end
end)