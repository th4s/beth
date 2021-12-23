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
    local response="$(__parse_result "$(__request "eth_hashrate")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_accounts() {
    echo "$(__parse_result "$(__request "eth_accounts")")"
}

eth_gas_price() {
    local response="$(__parse_result "$(__request "eth_gasPrice")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_block_number() {
    local response="$(__parse_result "$(__request "eth_blockNumber")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_balance() {
    local response="$(__parse_result "$(__request "eth_getBalance" "$(__append_blocknumber 2 "$@")")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_transaction_by_hash() {
    echo "$(__parse_result "$(__request "eth_getTransactionByHash" "$@")")"
}

eth_get_transaction_receipt() {
    echo "$(__parse_result "$(__request "eth_getTransactionReceipt" "$@")")"
}

eth_get_storage_at() {
    echo "$(__parse_result "$(__request "eth_getStorageAt" "$(__append_blocknumber 3 "$@")")")"
}

eth_get_transaction_count() {
    local response="$(__parse_result "$(__request "eth_getTransactionCount" "$(__append_blocknumber 2 "$@")")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_block_by_number() {
    echo "$(__parse_result "$(__request "eth_getBlockByNumber" "$@")")"
}

eth_get_block_transaction_count_by_hash() {
    local response="$(__parse_result "$(__request "eth_getBlockTransactionCountByHash" "$@")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_block_transaction_count_by_number() {
    local response="$(__parse_result "$(__request "eth_getBlockTransactionCountByNumber" "$(__append_blocknumber 1 "$@")")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_uncle_count_by_block_hash() {
    local response="$(__parse_result "$(__request "eth_getUncleCountByBlockHash" "$@")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_uncle_count_by_block_number() {
    local response="$(__parse_result "$(__request "eth_getUncleCountByBlockNumber" "$(__append_blocknumber 1 "$@")")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
}

eth_get_code() {
    echo "$(__parse_result "$(__request "eth_getCode" "$(__append_blocknumber 2 "$@")")")"
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
        echo "$(sed -e 's/.*"result": *\(.*\)}.*/\1/' <<<"${1}")"
    else
        echo "$1"
        return 1
    fi
}

__hex_to_dec() {
    local parsed="$(sed -e 's/\"//g' <<<"${1}")"
    echo "ibase=16; $(echo ${parsed#0x} | tr a-f A-F)" | bc
}

__dec_to_hex() {
    local parsed="$(sed -e 's/\"//g' <<<"${1}")"
    echo "0x$(echo "obase=16; ${parsed}" | bc | tr A-F a-f)" 
}

__to_str_arr() {
    if [ ! $# -eq 0 ]; then
        printf -v joined '"%s",' "$@"
        joined=$(echo $joined | sed -e 's/\"true\"/true/g')
        joined=$(echo $joined | sed -e 's/\"false\"/false/g')
        echo "${joined%,}"
    fi
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
