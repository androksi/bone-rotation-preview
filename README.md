# Bone Rotation Preview  
An easy tool to get the rotation of the character bones.

## How to open the window  
Basically, all you need to do is start the resource on your server. Once running, type `/pbone` to toggle the window.

## How to copy the bone rotation

You can use the `/copybones` command to copy the rotation of all listed bones to your clipboard in a clean format.

### Syntax
`/copybones [mode]`

### Modes
- `positive`: Values are in the range of `0°–360°`
- `center`: Values are centered in the range `-180°–180°`

Make sure the bone editor window is visible (`/pbone`) before using the command, otherwise it won't do anything.

Example:  
`/copybones center`

After running the command, the data will be copied to your clipboard and you’ll see a confirmation message in chat.

## Usage  
Add a bone to the list, select it, then slide the scrollbars. You can have multiples bones at once.

## Features  
- Add bone to list  
- Remove bone, when selected  
- Preview the rotation on your character  
- Sliders to change the rotation (yaw, pitch, roll)  
- Press `right mouse button` and hold to toggle cursor  
- **New:** Use `/copybones [mode]` to copy bone angles to clipboard (`positive` or `center`)

## What's the purpose?  
People may want to create animations or whatever their creativity tells. I was in need of something like this, so I did one by myself, and now, I'm sharing with the community. Hope you guys like it! You are allowed to edit and use the way you prefer. But **please**, do not sell.

## Images  
Some images to show you.

### Main Window  
![Main Window](https://i.imgur.com/BzDoU9o.png)

### Pop-up Window  
![Main Window](https://i.imgur.com/1xTay90.png)