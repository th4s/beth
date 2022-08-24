if [ ! -x "$(command -v curl)" ]; then
    echo "Please install curl to use this script." && return
fi

if [ ! -x "$(command -v jq)" ]; then
    echo "Please install jq to use this script." && return
fi

DEFAULT_ETH_RPC_URL="https://cloudflare-eth.com"

if [ -z "${ETH_RPC_URL}" ]; then
    ETH_RPC_URL=${DEFAULT_ETH_RPC_URL}
fi

eth_syncing() {
    echo "$(__parse_result "$(__request "eth_syncing")")"
}
    
eth_coinbase() {
    echo "$(__parse_result "$(__request "eth_coinbase")")"
}

eth_protocol_version() {
    echo "$(__parse_result "$(__request "eth_protocolVersion")")"
}

eth_mining() {
    echo "$(__parse_result "$(__request "eth_mining")")"
}
    
eth_accounts() {
    echo "$(__parse_result "$(__request "eth_accounts")")"
}

eth_txpool_status() {
    echo "$(__parse_result "$(__request "txpool_status")")"
}

eth_txpool_content() {
    echo "$(__parse_result "$(__request "txpool_content")")"
}

eth_txpool_inspect() {
    echo "$(__parse_result "$(__request "txpool_inspect")")"
}

eth_hashrate() {
    local response="$(__parse_result "$(__request "eth_hashrate")")"
    if test "${response#*error}" != "${response}"; then
        echo "${response}"
    else
        echo "$(__hex_to_dec "${response}")"
    fi
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
    echo "$(__parse_result "$(__request "eth_getBlockByNumber"  "$(__prepend_blocknumber 2 "$@")")")"
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

eth_get_block_by_hash() {
    echo "$(__parse_result "$(__request "eth_getBlockByHash" "$@")")"
}

eth_get_transaction_by_block_hash_and_index() {
    echo "$(__parse_result "$(__request "eth_getTransactionByBlockHashAndIndex" "$1" "$(__dec_to_hex "$2")")")"
}

eth_get_transaction_by_block_number_and_index() {
    local args=($(__prepend_blocknumber 2 "$@"))
    args[$((1+$(__is_zsh)))]="$(__dec_to_hex ${args[$((1+$(__is_zsh)))]})"
    echo "$(__parse_result "$(__request "eth_getTransactionByBlockNumberAndIndex" "${args[@]}")")"
}

eth_get_uncle_by_block_hash_and_index() {
    echo "$(__parse_result "$(__request "eth_getUncleByBlockHashAndIndex" "$1" "$(__dec_to_hex "$2")")")"
}

eth_get_uncle_by_block_number_and_index() {
    local args=($(__prepend_blocknumber 2 "$@"))
    args[$((1+$(__is_zsh)))]="$(__dec_to_hex ${args[$((1+$(__is_zsh)))]})"
    echo "$(__parse_result "$(__request "eth_getUncleByBlockNumberAndIndex" "${args[@]}")")"
}

eth_call() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"${2}\"}" \"latest\")")"
}

# ERC20 call

erc20_decimals() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0x313ce567\"}" \"latest\")")"
}

erc20_name() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0x06fdde03\"}" \"latest\")")"
}

erc20_symbol() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0x95d89b41\"}" \"latest\")")"
}

erc20_total_supply() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0x18160ddd\"}" \"latest\")")"
}

erc20_balance() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0x70a08231000000000000000000000000${2}\"}" \"latest\")")"
}

erc20_allowance() {
    echo "$(__parse_result "$(__request_call "eth_call" "{\"to\":\"${1}\",\"data\":\"0xdd62ed3e000000000000000000000000${2}000000000000000000000000${3}\"}" \"latest\")")"
}

2mwei() {
    local values
    if [ $(__is_zsh) -eq 1 ]; then
        read -rA values <<<"$(cat | tr '\n,' ' ')"
    else
        read -ra values <<<"$(cat | tr '\n,' ' ')"
    fi
    for i in "${values[@]}"; do
        if [ ! -z "$i" -a "$i" != " " ]; then
            echo "scale=2;${i}/10^6" | bc
        fi
    done
}

2gwei() {
    local values
    if [ $(__is_zsh) -eq 1 ]; then
        read -rA values <<<"$(cat | tr '\n,' ' ')"
    else
        read -ra values <<<"$(cat | tr '\n,' ' ')"
    fi
    for i in "${values[@]}"; do
        if [ ! -z "$i" -a "$i" != " " ]; then
            echo "scale=2;${i}/10^9" | bc
        fi
    done
}

2eth() {
    local values
    if [ $(__is_zsh) -eq 1 ]; then
        read -rA values <<<"$(cat | tr '\n,' ' ')"
    else
        read -ra values <<<"$(cat | tr '\n,' ' ')"
    fi
    for i in "${values[@]}"; do
        if [ ! -z "$i" -a "$i" != " " ]; then
            echo "scale=2;${i}/10^18" | bc
        fi
    done
}

2hex() {
    local values
    if [ $(__is_zsh) -eq 1 ]; then
        read -rA values <<<"$(cat | tr '\n,' ' ')"
    else
        read -ra values <<<"$(cat | tr '\n,' ' ')"
    fi
    for i in "${values[@]}"; do
        if [ ! -z "$i" -a "$i" != " " ]; then
            echo $(__dec_to_hex ${i})
        fi
    done
}

2dec() {
    local values
    if [ $(__is_zsh) -eq 1 ]; then
        read -rA values <<<"$(cat | tr '\n,' ' ')"
    else
        read -ra values <<<"$(cat | tr '\n,' ' ')"
    fi
    for i in "${values[@]}"; do
        if [ ! -z "$i" -a "$i" != " " ]; then
            echo $(__hex_to_dec ${i})
        fi
    done
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

__request_call() {
    local curlArgs=('-H' "Content-Type: application/json")
    if [ ! -z "${ETH_RPC_AUTH_BASIC}" ]; then
        curlArgs+=('-H' "Authorization: Basic ${ETH_RPC_AUTH_BASIC}")
    elif [ ! -z "${ETH_RPC_AUTH_BEARER}" ]; then
        curlArgs+=('-H' "Authorization: Bearer ${ETH_RPC_AUTH_BEARER}")
    fi
    echo $(curl ${ETH_RPC_URL} -s "${curlArgs[@]}" \
        -d "{\"jsonrpc\": \"2.0\",\"method\": \"${1}\",\"params\": ["$2","$3"],\"id\": ${RANDOM}}")
}

__parse_result() {
    if test "${1#*result}" != "${1}"; then
        echo "$(echo "${1}" | jq .result)"
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
        # echo "$@" is a hack for parameter expansion in zsh shells
        printf -v joined '"%s",' $(echo "$@")
        joined=$(echo $joined | sed -e 's/\"true\"/true/g')
        joined=$(echo $joined | sed -e 's/\"false\"/false/g')
        joined=$(echo $joined | sed -e 's/\"{/{/g')
        joined=$(echo $joined | sed -e 's/}\"/}/g')
        echo "${joined%,}"
    fi
}

__append_blocknumber() {
    local tmp_arr=("${@:2}")
    local len=${#tmp_arr[@]}
    if [ ! ${len} -eq ${1} ]; then
        tmp_arr+=("latest")
    elif [ "$(__get_last_arg ${tmp_arr[@]})" !=  "latest" ]; then
        tmp_arr[$((${len}-1+$(__is_zsh)))]=$(__dec_to_hex ${tmp_arr[$((${len}-1+$(__is_zsh)))]})
    fi
    echo ${tmp_arr[@]}
}

__prepend_blocknumber() {
    local tmp_arr=("${@:2}")
    local first=${tmp_arr[$(__is_zsh)]}
    local len=${#tmp_arr[@]}
    if [ ! ${len} -eq ${1} ]; then
        tmp_arr=("latest" "${tmp_arr[@]}")
    elif [ "${first}" !=  "latest" ]; then
        tmp_arr[$(__is_zsh)]=$(__dec_to_hex ${tmp_arr[$(__is_zsh)]})
    fi
    echo ${tmp_arr[@]}
}

__get_last_arg() {
    local last
    for last; do : ; done
    echo "${last}"
}

__is_zsh() {
    # zsh starts array indexing at 1, so we need to differentiate
    if test "${ZSH_NAME#*zsh}" != "${ZSH_NAME}"; then
        echo 1
    else
        echo 0
    fi
}
