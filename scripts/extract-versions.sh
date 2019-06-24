#!/bin/bash

REPODIR=~/cord

for CHART in $REPODIR/helm-charts/xos-services/*
do
    APPVERSION=$( awk '/^appVersion:/ { print $2 }' $CHART/Chart.yaml )
    SVCNAME=$( basename $CHART)

    case $SVCNAME in
        volt)
        SVCNAME=olt-service
        ;;
        kubernetes)
        SVCNAME=kubernetes-service
        ;;
    esac

    if [ ! -e $REPODIR/orchestration/xos-services/$SVCNAME/VERSION ]
    then
        #echo "WARN: $SVCNAME has no VERSION file"
        continue
    fi

    SVCVERSION=$( cat $REPODIR/orchestration/xos-services/$SVCNAME/VERSION )
    echo $SVCNAME
    echo "  Chart:   $APPVERSION"
    echo "  Service: $SVCVERSION"
done
