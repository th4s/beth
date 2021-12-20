if [ ! -x "$(command -v curl)" ]; then
    echo "Please install curl to use this script." && return
fi

set -o pipefail

DEFAULT_ETH_RPC_URL="https://cloudflare-eth.com"

if [ -z "${ETH_RPC_URL}" ]; then
    ETH_RPC_URL=${DEFAULT_ETH_RPC_URL}
fi

eth_syncing() {
    __request "eth_syncing"
}
    
eth_mining() {
    __request "eth_mining"
}
    
eth_hashrate() {
    __request "eth_hashrate" | __hex_to_dec
}

eth_gas_price() {
    __request "eth_gasPrice" | __hex_to_dec
}

eth_accounts() {
    __request "eth_accounts"
}

eth_block_number() {
    __request "eth_blockNumber" | __hex_to_dec
}

__request() {
    curlArgs=('-H' "Content-Type: application/json")
    if [ ! -z "${ETH_RPC_AUTH_BASIC}" ]; then
        curlArgs+=('-H' "Authorization: Basic ${ETH_RPC_AUTH_BASIC}")
    elif [ ! -z "${ETH_RPC_AUTH_BEARER}" ]; then
        curlArgs+=('-H' "Authorization: Bearer ${ETH_RPC_AUTH_BEARER}")
    fi
    out=$(curl ${ETH_RPC_URL} -s "${curlArgs[@]}" \
        -d "{\"jsonrpc\": \"2.0\",\"method\": \"${1}\",\"params\": [${@:2}],\"id\": ${RANDOM}}")
    if [[ $out == *result* ]]; then
        sed -e 's/.*"result": *\(.*\)}.*/\1/' <<<"${out}" | sed -e 's/\"//g'
    else
        echo $out
    fi
}

__hex_to_dec() {
    read value <<<$(cat)
    printf "%d\n" ${value}
}

gwei() {
    read value <<<$(cat)
    echo "scale=2;${value}/10^9" | bc
}

eth() {
    read value <<<$(cat)
    echo "scale=2;${value}/10^18" | bc
}
