#!/bin/bash

# Paramètres
DIROUT=output
FILEOUT=decp-stats.csv

# Lecture des fichiers quotidens DECP sur data.gouv.fr
echo "Lecture du datasets DECP sur data.gouv.fr"
results=( $(curl -sS -X GET "https://www.data.gouv.fr/api/1/datasets/donnees-essentielles-de-la-commande-publique-fichiers-consolides/" -H "accept: application/json" | jq '.resources[]|select(.format == "json" and .type == "update")|.url') )

# Vérification du nombre de fichiers traités
echo "Nb de fichiers sur data.gouv.fr : ${#results[@]}"

# Création du répertoire si absent
[ ! -d ${DIROUT} ] && echo "Création du répertoire : ${DIROUT}" && mkdir ${DIROUT}

# Suppression des anciens fichiers pour faciliter la reprise sur incident
echo "Suppresion des anciens fichiers pour recalculer les statistiques"
find ${DIROUT} -mtime +100 -exec rm -f {} \;

# Contrôle du répertoire DIROUT
nbfilesjq=$(ls -al ${DIROUT}/*.jq 2> /dev/null | wc -l)
echo "Nb de fichiers déjà présents dans ${DIROUT} : ${nbfilesjq}"

# Pour chaque fichier : calcul du nombre de sources
echo "Traitement des nouveaux fichiers"
for el in "${results[@]}"
do
	el=$(sed 's/\"//g' <<< ${el})       # Suppression des doubles quotes
	elname=$(basename ${el})            # Extraction du nom du fichier
	eldate=$(cut -c6-15 <<< ${elname})  # Extraction de la date
	# Téléchargement des fichiers manquants
	if [ ! -f ${DIROUT}/${elname}.jq ] ; then
		echo ${elname}
		wget -q ${el} -O ${DIROUT}/${elname}
		jq 'map({ "date": '\"$eldate\"', "sources": (group_by(.source) | map({"key":.[0].source, "value": length}) | from_entries)})' ${DIROUT}/${elname} |jq '.[]' > ${DIROUT}/${elname}.jq 
		rm -fr ${DIROUT}/${elname}
	fi
done

# Export en CSV : d'abord l'entête, puis les données
echo "Création du fichier CSV contenant les comptages par jour et par partenaire"
echo "date,aife,pes,emarchespublics,grandlyon,marchespublicsinfo" > ${DIROUT}/${FILEOUT}
jq --raw-output '[.date, .sources."data.gouv.fr_aife", .sources."data.gouv.fr_pes" , .sources."e-marchespublics", .sources."grandlyon", .sources."marches-publics.info"] | @csv' ${DIROUT}/*.jq >> ${DIROUT}/${FILEOUT}

# Contrôle du répertoire DIROUT
nbfilesjq=$(ls -al ${DIROUT}/*.jq | wc -l)
echo "Nb de fichiers maintenant présents dans ${DIROUT} : ${nbfilesjq}"
