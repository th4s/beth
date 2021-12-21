if [ ! -x "$(command -v curl)" ]; then
    echo "Please install curl to use this script." && return
fi

DEFAULT_ETH_RPC_URL="https://cloudflare-eth.com"

if [ -z "${ETH_RPC_URL}" ]; then
    ETH_RPC_URL=${DEFAULT_ETH_RPC_URL}
fi

eth_syncing() {
    echo "$(__parse_result "$(__request "eth_syncing")")"
}
    
eth_mining() {
    echo "$(__parse_result "$(__request "eth_mining")")"
}
    
eth_hashrate() {
    echo "$(__parse_result "$(__request "eth_hashrate")")"
}

eth_accounts() {
    echo "$(__parse_result "$(__request "eth_accounts")")"
}

eth_gas_price() {
    local response="$(__parse_result "$(__request "eth_gasPrice")")"
    if [ $? -eq 0 ]; then
        echo "$(__hex_to_dec "${response}")"
    else
        echo "${response}"
    fi
}

eth_block_number() {
    local response="$(__parse_result "$(__request "eth_blockNumber")")"
    if [ $? -eq 0 ]; then
        echo "$(__hex_to_dec "${response}")"
    else
        echo "${response}"
    fi
}

eth_get_balance() {
    local response="$(__parse_result "$(__request "eth_getBalance" "$(__append_blocknumber 2 "$@")")")"
    if [ $? -eq 0 ]; then
        echo "$(__hex_to_dec "${response}")"
    else
        echo "${response}"
    fi
}

eth_get_transaction_by_hash() {
    echo "$(__parse_result "$(__request "eth_getTransactionByHash" "$@")")"
}


gwei() {
    local value
    read value <<<$(cat)
    echo "scale=2;${value}/10^9" | bc
}

eth() {
    local value
    read value <<<$(cat)
    echo "scale=2;${value}/10^18" | bc
}

__request() {
    local curlArgs=('-H' "Content-Type: application/json")
    if [ ! -z "${ETH_RPC_AUTH_BASIC}" ]; then
        curlArgs+=('-H' "Authorization: Basic ${ETH_RPC_AUTH_BASIC}")
    elif [ ! -z "${ETH_RPC_AUTH_BEARER}" ]; then
        curlArgs+=('-H' "Authorization: Bearer ${ETH_RPC_AUTH_BEARER}")
    fi
    echo $(curl ${ETH_RPC_URL} -s "${curlArgs[@]}" \
        -d "{\"jsonrpc\": \"2.0\",\"method\": \"${1}\",\"params\": [$(__to_str_arr ${@:2})],\"id\": ${RANDOM}}")
}

__parse_result() {
    if test "${1#*result}" != "${1}"; then
        echo "$(sed -e 's/.*"result": *\(.*\)}.*/\1/' <<<"${1}" | sed -e 's/\"//g')"
    else
        echo "$1"
        return 1
    fi
}

__hex_to_dec() {
    printf "%d\n" "${1}"
}

__dec_to_hex() {
    printf "0x%x\n" "${1}"
}

__to_str_arr() {
    printf -v joined '"%s",' "$@"
    echo "${joined%,}"
}


__append_blocknumber() {
    local tmp_arr=("${@:2}")
    local len=${#tmp_arr[@]}
    if [ ! ${len} -eq ${1} ]; then
        tmp_arr+=("latest")
    elif [ "$(__get_last_arg ${tmp_arr[@]})" !=  "latest" ]; then
        tmp_arr[$((${len}-1))]=$(__dec_to_hex ${tmp_arr[$((${len}-1))]})
    fi
    echo ${tmp_arr[@]}
}

__get_last_arg() {
    local last
    for last; do : ; done
    echo "${last}"
}
