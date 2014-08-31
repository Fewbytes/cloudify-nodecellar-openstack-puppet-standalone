#!/bin/bash -e

tar --exclude='*.swp' -czf puppet.tar.gz -C puppet manifests
