#!/bin/bash

http -a karaf:karaf POST http://127.0.0.1:30120/onos/v1/flows < $( dirname "$0" )/add-trap-flow.json
