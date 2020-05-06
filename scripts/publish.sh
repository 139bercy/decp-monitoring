#!/bin/bash

# fail on error
set -e

case ${CIRCLE_BRANCH} in
    # La publication n'est appliquée que sur la branche master.
    master)


    if [[ ! -f  /tmp/workspace/decp-monitoring/scripts/index.html ]]
    then
        echo "Le fichier index.html n'existe pas et doit d'abord être généré par Render"
        exit 1
    fi

    echo "Mise à jour des pages gh du projet"
    git config --global user.email ""
    git config --global user.name "circle-bot"
    #ssh-keygen -F github.com || ssh-keyscan github.com > ~/.ssh/known_hosts
    git clone -b gh-pages https://${GITHUB_PAT}@github.com/139bercy/decp-monitoring gh-pages
    cd gh-pages
    rm -fr *.html
    cp  /tmp/workspace/decp-monitoring/scripts/index.html .
    git add index.html
    git commit -m "update build ${CIRCLE_BUILD_NUM} - [ci skip]"
    git push origin gh-pages
;;
esac
