#!/bin/bash

git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /tmp/ruleset
cd /tmp/ruleset/
mv crs-setup.conf.example crs-setup.conf
# tähän rulesetin tiedostojen kopiointi lopulliseen paikkaansa
rm -rf /tmp/ruleset



