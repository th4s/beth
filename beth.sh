if [ ! -x "$(command -v curl)" ]; then
    echo "Please install curl to use this script." && return
fi

DEFAULT_ETH_RPC_URL="https://cloudflare-eth.com"

if [ -z "${ETH_RPC_URL}" ]; then
    ETH_RPC_URL=${DEFAULT_ETH_RPC_URL}
fi
    
eth_gas_price() {
    __hex_to_dec $(__parse_result $(__request eth_gasPrice))
}

__request() {
    curl ${ETH_RPC_URL} -sH "Content-Type: application/json" \
        -d "{\"jsonrpc\": \"2.0\",\"method\": \"${1}\",\"params\": [${@:2}],\"id\": ${RANDOM}}"
}


__parse_result() {
    sed -e 's/.*"result": *"\(.*\)".*/\1/' <<<"${1}"
}

__hex_to_dec() {
   printf "%d\n" ${1}
}

gwei() {
    read value <<<$(cat)
    echo "scale=2;${value}/10^9" | bc
}

eth() {
    read value <<<$(cat)
    echo "scale=2;${value}/10^18" | bc
}
