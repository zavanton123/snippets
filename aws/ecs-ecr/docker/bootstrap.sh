#!/bin/sh
set -e

echo "<pre>" >> /usr/local/apache2/htdocs/index.html
curl $ECS_CONTAINER_METADATA_URI | jq '.' >> /usr/local/apache2/htdocs/index.html
echo "</pre>" >> /usr/local/apache2/htdocs/index.html

httpd-foreground
