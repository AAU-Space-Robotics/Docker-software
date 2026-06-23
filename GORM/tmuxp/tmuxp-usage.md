tmuxp has a global workspace that is located at $HOME/.config/tmuxp/
here you can make a yaml file that can be loaded from anywhere on the system.
To load it simply type:

    tmuxp load <name_of_file>

this will then load the session either from your current working directory or
from globale workspace.

if you do not know the avaiable sesssions then you can type:

    tmuxp ls

this will give the avable sessions in the gloable workspace.


To kill a session press ctrl-b + q.


For more guidance look at [tmuxp documentation](https://tmuxp.git-pull.com/cli/)
