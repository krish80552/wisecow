#!/usr/bin/env bash

SRVPORT=4499
RSPFILE=response

rm -f $RSPFILE
mkfifo $RSPFILE

get_api() {
	read line
	echo $line
}

handleRequest() {
    # 1) Process the request
	get_api
	mod=`fortune`

echo "fortune output: $mod" >&2

    # 2) Generate the response
    cowsay_output=$(cowsay "$mod")
    echo "cowsay output: $cowsay_output" >&2

    cat <<EOF > $RSPFILE
HTTP/1.1 200 OK
Content-Type: text/html
<pre>$cowsay_output</pre>
EOF
}

prerequisites() {
	command -v cowsay >/dev/null 2>&1 &&
	command -v fortune >/dev/null 2>&1 || 
		{ 
			echo "Install prerequisites."
			exit 1
		}
}

main() {
	prerequisites
	echo "Wisdom served on port=$SRVPORT..."
	while [ 1 ]; do
		cat $RSPFILE | nc -lN $SRVPORT | handleRequest
		sleep 0.01
	done
}

main
