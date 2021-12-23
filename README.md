# beth.sh

## What is it?

beth.sh supports (a part of) Ethereum JSON-RPC in terminal for `zsh` and `bash`.
Focus is on portability, (nearly) no dependencies and ease of use. I wanted
an easy and ergonomic way to query some data.

## What is supported?

Supported are read-only RPCs, excluding filters, tx signing and that kind of stuff.

## Installation

The only dependency is `curl` and some fairly widespread UNIX tools. Just do

#### Bash

```
cd && git clone https://github.com/th4s/beth && echo 'source "$HOME/beth/.beth.sh"' >> .bashrc && source .bashrc
```

#### Zsh

```
cd && git clone https://github.com/th4s/beth && echo 'source "$HOME/beth/.beth.sh"' >> .zshrc && source .zshrc
```

That's it. You can now enter `eth_` and press `TAB` in you terminal to see the supported RPCs.

## Configuration

Per default `https://cloudflare-eth.com` is used. In order to use another node just set
the `ETH_RPC_URL` variable, e.g.:

```
ETH_RPC_URL=https://my-node-endpoint.xyz/geth/
```

You can also inject auth headers into the requests. This is useful if your node 
is behind some reverse proxy for authentication. Just set either `ETH_RPC_AUTH_BASIC`
or `ETH_RPC_AUTH_BEARER`, e.g.:

```
ETH_RPC_AUTH_BASIC=dGg..........Mg==
```

## Examples

Some of these examples use [jq](https://stedolan.github.io/jq/) for JSON processing
in the terminal.

```bash
# Get current block number 
eth_block_number

# Get current block including transactions and pretty-print
eth_get_block_by_number latest true | jq .
```

