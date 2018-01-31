#!/bin/bash

curl https://sh.rustup.rs -sSf | sh
source .cargo/env
apt-get install libssl-dev
cargo install --git https://github.com/ovh/beamium

cp .cargo/bin/beamium /usr/local/bin/

mkdir -p /etc/beamium

cat << EOF > /etc/beamium/config.yaml

sinks: # Sinks definitions
  source1:                             # Sink name                                (Required)
    url: https://warp.io/api/v0/update # Warp10 endpoint                          (Required)
    token: mywarp10token               # Warp10 write token                       (Required)
    token-header: X-Custom-Token       # Warp10 token header name                 (Optional, default: X-Warp10-Token)
    selector: metrics.*                # Regex used to filter metrics             (Optional, default: None)
    ttl: 3600                          # Discard file older than ttl (seconds)    (Optional, default: 3600)
    size: 1073741824                   # Discard old file if sink size is greater (Optional, default: 1073741824)
    parallel: 1                        # Send parallelism                         (Optional, default: 1)

labels: # Labels definitions
  label_name: label_value # Label definition             (Required)

parameters: # Parameters definitions
  source-dir: sources # Beamer data source directory                    (Optional, default: sources)
  sink-dir: sinks       # Beamer data sink directory                    (Optional, default: sinks)
  scan-period: 1000     # Delay(ms) between source/sink scan            (Optional, default: 1000)
  batch-count: 250      # Maximum number of files to process in a batch (Optional, default: 250)
  batch-size: 200000    # Maximum batch size                            (Optional, default: 250)
  log-file: beamium.log # Log file                                      (Optional, default: beamium.log)
  log-level: 4          # Log level                                     (Optional, default: info)
  timeout: 500          # Http timeout (seconds)                        (Optional, default: 500)

EOF

