del h:\uploads\bbslist.zip
if exist h:\uploads\bbslist.zip goto error
proecho %1 ~Creating new BBSLIST.ZIP....
pkz -! h:\uploads bbslist.zip f:\listbbs\bbslist
pkz -! h:\uploads bbslist.zip h:\bullet\avail
goto end

:error
proecho %1 ~BBSLIST.ZIP is being downloaded on another node...~
proecho %1 Please try again later...
:end
proecho %1 ~~
