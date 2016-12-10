#!/bin/sh -e

KCP=true
KCP_EXEC="/opt/kcptun/server_linux_amd64 -t 0.0.0.0:$SS_PORT -l :$KCP_PORT"
SSS_EXEC="/usr/local/bin/ss-server"

ARGS=`getopt -o c --long client,no-kcp,help -- "$@"` && eval set -- "$ARGS"

usage() {
	cat <<- EOF

		shadowsocks-kcp uses server mode with kcptun enabled by default

		Options:
		    -c|--client    start in client mode
		    --no-kcp       disable kcptun

	EOF
}

while true; do
	case "$1" in
		-c|--client)
			KCP_EXEC="/opt/kcptun/client_linux_amd64 -r $SS_SERVER:$KCP_PORT -l :$SS_PORT"
			SSS_EXEC="/usr/local/bin/ss-local -b 0.0.0.0 -l $SS_LOCAL_PORT -s $SS_SERVER"
			shift ;;
		--no-kcp) KCP=false; shift ;;
		--help) usage; exit 0 ;;
		--) shift; break ;;
		*) echo "Invalid arguments."; exit 1 ;;
    esac
done

KCP_EXEC=$KCP_EXEC" --crypt none --nocomp --mode $KCP_MODE --mtu $KCP_MTU --sndwnd $KCP_SNDWND --rcvwnd $KCP_RCVWND --datashard $KCP_DATASHARD --parityshard $KCP_PARITYSHARD"
SSS_EXEC=$SSS_EXEC" -p $SS_PORT -k $SS_PASSWORD -m $SS_METHOD -t $SS_TIMEOUT -u -A --fast-open"

$KCP && echo "Start:" $KCP_EXEC && $KCP_EXEC&
echo "Start:" $SSS_EXEC && $SSS_EXEC
