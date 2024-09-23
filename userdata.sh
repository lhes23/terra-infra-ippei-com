#!/bin/bash
sudo yum install -y amazon-cloudwatch-agent
cat <<'EOT' > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "metrics": {
    "namespace": "CustomMetrics",
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_free"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOT
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
