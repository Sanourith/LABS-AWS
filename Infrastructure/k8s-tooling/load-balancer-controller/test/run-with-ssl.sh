#!/usr/bin/env bash

base_domain=$(aws route53 list-hosted-zones --query "HostedZones[0].Name" --output text | rev | cut -c2- | rev)
helm upgrade --install sample-app --set baseDomain="${base_domain}" --set ssl.enabled=true .