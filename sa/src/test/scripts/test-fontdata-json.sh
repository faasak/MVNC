#!/bin/bash

fontdata_css='@font-face {
  font-family: '\''Open Sans'\'';
  font-style: normal;
  font-weight: 400;
  src: url(http://fonts.gstatic.com/s/opensans/v14/abc_foo.ttf);
  src2: local('\''Open Sans Regular'\''), local('\''OpenSans-Regular'\''), url(http://fonts.gstatic.com/s/opensans/v14/abc.ttf) format('\''truetype'\'');
}'

echo $fontdata_css >/tmp/fontdata.css

cssparser -o /tmp/fontdata.json /tmp/fontdata.css

jq '.value[0].value.src | tostring' /tmp/fontdata.json
jq '.value[0].value.src2 | tostring' /tmp/fontdata.json

exit 0

