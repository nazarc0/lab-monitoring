#!/bin/sh

MSG="${WELCOME_MSG:-Hello, this is a default message. Parameter Store didn't work.}"

echo "<!DOCTYPE html>
<html>
<head><title>Lab ECS</title></head>
<body>
    <h1>$MSG</h1>
</body>
</html>" > /usr/share/nginx/html/index.html

exec "$@"