#!/bin/bash
vim $1<<END
:1
"m2yy
:edit tmp
/Bounding
D
"mP
:wq
END
