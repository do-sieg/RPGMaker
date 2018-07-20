# Window_Selectable Reworked
RPG Maker XP has a main class for all windows allowing selection: `Window_Selectable`.  
Unfortunately, a lot of useful functions are missing from this class for some reason, and scripters are forced to code them on their own to have dynamic windows.  
There is also a `Window_Command` class that has some of the useful functions that `Window_Selectable` should have.

I made three scripts to solve these issues. To use them, put them under the original `Window_Selectable` and `Window_Command` (the point is having those above your other windows). Use the order from the list below.
* `Window_Selectable 2`: this script rewrites some of the functions from `Window_Selectable`
* `Window_Selectable 3`: this script adds new functions for `Window_Selectable`
* `Window_Command 2`: this script disables some functions that have been moved to `Window_Selectable`.  
The idea is that `Window_Selectable` becomes the true superclass for all windows with selection, while `Window_Command` is just an easy class to create simple command windows.

## Features
* The use of directional and L/R buttons can be restricted.
* Commands can be updated and the window refreshes automatically.
* Commands can be disabled and enabled with a lot of ease.
* Any command information can be accessed easily by other classes.
* Commands and their texts are now two separate things. Other objects can be stored and their name displayed for example.
* Text and cursor display are easier to change.
* Alignment can be changed for commands.

## Functions
Now, here are a few useful functions that can be used for all selectable windows:
* `row_height`: similar to `line_height` from RPG Maker VX Ace, this sets the height for each command row, independently of the content displayed. It is set at 32 by default.
* `command_display_x`: changing the value here (4 by default) changes the margin on the left and right of the command.
* `draw_cursor`: the cursor drawing has now its own method that can be easily manipulated.
* `update_dir4`: this updates all directional buttons input. It can be deactivated by setting `@dir4_input`to false in the initialization of the window.
* `update_triggers`: this updates the L and R buttons input. It can be deactivated by setting `@trigger_input`to false in the initialization of the window.
* `setup_contents(width, height, padding)`: this draws the bitmap where all window content is drawn. It has been isolated to manipulate it in some windows where the content is larger than the window. Without any argument, it simply draws the content fitting the window's width and height. It is advised to leave the `padding` value at 16 unless you know what you're doing.
* `set_commands(commands)`: this updates the commands in the window and refreshes its content. It allows to update the command list in a dynamic way, something that was heavily missing from the original scripts.
* `set_align(value)`: this function changes the alignment of all commands. Using 0 (left), 1 (center) or 2 (right), it changes the variable `@align` and refreshes the window.
* `draw_item(index)`: this function was originally in `Window_Command`. It has been moved here and it handles the drawing of a command at the spot given by `index`. Font color doesn't have to be defined anymore for disabled commands, it is done automatically.
* `command_rect(index)`: this handles the area where the command will be displayed.
* `command_text_rect(index)`: this handles the area where the command text will be displayed it is the same as the previous method except it uses `command_display_x` to set a margin. It can be used to move slightly the text, etc.
* `clear_row(index)`: this is only useful if you need to clear the area for a command for some reason. The script uses it before drawing a command, avoiding to refresh the whole window for just one command.
* `command(index)`: another extremely useful function returning the command for the given `index`. Without argument, it returns the selected item.
* `command_text(index)`: this is used to display the text for each command. By default, it is the same than the previous function but it can be used for windows storing anything else than text like actors, skills, items, etc.
* `enable(index)`: this enables a previously disabled command (see below).
* `disable(index)`: this disables a command. Instead of only redrawing it grey, the index is stored in an array and the information is kept in case of a refresh.
* `disabled?(index)`: this returns `true` or `false` depending if the given index is disabled or not.

I have been using this for a while and can guarantee it lightens up the code a lot.
