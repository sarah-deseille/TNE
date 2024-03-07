#!/usr/bin/bash
SEARCH_PATH="/usr"
PICTURE_MIN_SIZE="10k"
GALLERY_SIZE=25
GALLERY_PICTURE_SIZE=200
PICTURE_TYPE="png"
GALLERY_DESTINATION_DIR="."
LAST_GALLERY=0

while getopts ":a:b:c:d:e:f:h" opt; do
    case $opt in
    a)
        SEARCH_PATH=$OPTARG #recupération de la valeur de l'option -a
        ;;
    b)
        PICTURE_MIN_SIZE=$OPTARG #recupération de la valeur de l'option -b
        ;;
    c)
        GALLERY_SIZE=$OPTARG #recupération de la valeur de l'option -c
        echo $GALLERY_SIZE
        ;;
    d)
        GALLERY_PICTURE_SIZE=$OPTARG #recupération de la valeur de l'option -d
        ;;
    e)
        PICTURE_TYPE=$OPTARG #recupération de la valeur de l'option -e
        ;;
    f)
        GALLERY_DESTINATION_DIR=$OPTARG #recupération de la valeur de l'option -f
        ;;

    h)
cat <<FIN >&2 #mise en place d'un here document nommé FIN
Le programme peut fonctionner sans options. Les fonctions possibles sont les suivantes :
    -a : chemin de recherche des images
    -b : taille minimale des images
    -c : nombre d'images par galerie
    -d : taille des images dans la galerie
    -e : type d'images
    -f : répertoire de destination des galeries
    -h : affiche l'aide
FIN
    exit 1
    ;;

    \?) #passe ici quand l'option n'est pas reconnue
    echo "L'option -$OPTARG est invalide" >&2
    exit 1
    ;;

    :) #passe ici quand il manque l'argument d'une option
    echo "L'option -$OPTARG attend un argument" >&2
    exit 1
    ;;
    esac
done

#fonction : création d'une galerie
#arguments de la fonction : chemin_gallerie ($1), taille_gallerie ($2), liste_images ($3), taille_images ($4)
#desription : créer des fics HTML de type gallerie
function create_gallery {
    local GALLERY_PATH=$1
    local GALLERY_SIZE=$2
    local PICTURE_LIST=$3
    local PICTURE_SIZE=$4
    local CURRENT_INDEX=$5 #index de la gallerie
    local IS_LAST_GALLERY=0 #0 si ce n'est pas la dernière gallerie
    local NEXT_INDEX=0 #$(printf "%03d" $(expr $CURRENT_INDEX + 1)) #index de la prochaine gallerie
    local PREVIOUS_INDEX=0 #$(printf "%03d" $(expr $CURRENT_INDEX - 1)) #index de la gallerie précédente
    local NEXT_URL="" #url de la prochaine gallerie
    local PREVIOUS_URL="" #url de la gallerie précédente
    local HTML_PICTURE_LIST=""
    #créer une chaîne qui contient les balises HTML image dans la limite de la taille de la galerie
    for picture in $PICTURE_LIST; do
        HTML_PICTURE_LIST="$HTML_PICTURE_LIST <img src=\"$picture\" width=\"$PICTURE_SIZE\">"
    done 
    #tests s'il n'y a pas de gallerie précédente ou suivante
    if [ $CURRENT_INDEX -eq 1 ]; then #si c'est la première gallerie
        PREVIOUS_INDEX=1
    else
        PREVIOUS_INDEX=$(printf "%03d" $(expr $CURRENT_INDEX - 1)) #index de la gallerie précédente
    fi
    if [ $LAST_GALLERY -eq 1 ]; then #si c'est la dernière gallerie
        NEXT_INDEX=$CURRENT_INDEX #on reste sur la même gallerie
    else
        NEXT_INDEX=$(printf "%03d" $(expr $CURRENT_INDEX + 1)) #index de la prochaine gallerie
    fi
    #création des liens pour les gallerie précédente et suivante
    NEXT_URL=$(echo "${GALLERY_PATH/[0-9][0-9][0-9]/$NEXT_INDEX}")
    PREVIOUS_URL=$(echo "${GALLERY_PATH/[0-9][0-9][0-9]/$PREVIOUS_INDEX}") #quand une var est entre "", elle est interpolée par sa valeur. Considéré comme une chaine de caractères (dans le cas présent) et pas comme une var qui pointe vers qqch
    #echo "/home/sarah/Documents/SHELL/TNE/gal012.html"
    cat <<EOF > $1
<!DOCTYPE html>
<html>
<head>
<a href="$PREVIOUS_URL">GALERIE $PREVIOUS_INDEX</a>
<a href="$NEXT_URL">GALERIE $NEXT_INDEX</a>
<title>Ma galerie</title>
</head>
<body>
$HTML_PICTURE_LIST <!--affichage des images-->
</body>
</html>
EOF
}

#fonction : recherche des images pour la gallerie
function search_pictures {
    local COMPTEUR=1
    local XYZ=$(printf "%03d" "001") #nom chiffre gallerie
    local PICTURE_LIST="" #contient la liste des images
    local DESTINATION_FILE="" #fichier de destination
    for img in $(find $SEARCH_PATH -type f -size +$PICTURE_MIN_SIZE -name "*.$PICTURE_TYPE"); do
        #echo "$COMPTEUR Image trouvée : $img"
        PICTURE_LIST=$(echo -e -n "$PICTURE_LIST\n$img") #ajout de l'image à la liste
        if [ $COMPTEUR -eq $GALLERY_SIZE ]; then
            DESTINATION_FILE=$GALLERY_DESTINATION_DIR/gal${XYZ}.html #{} : précise que XYZ est une variable
            #echo -e -n $PICTURE_LIST
            create_gallery $DESTINATION_FILE $GALLERY_SIZE "$PICTURE_LIST" $GALLERY_PICTURE_SIZE $XYZ $LAST_GALLERY
            XYZ=$(printf "%03d" $(expr $XYZ + 1)) #traitement numérique
            #echo $XYZ
            COMPTEUR=0
            PICTURE_LIST=""
        fi
        COMPTEUR=$(($COMPTEUR+1)) #traitement numérique
    done
    DESTINATION_FILE=$GALLERY_DESTINATION_DIR/gal${XYZ}.html #le dernier fichier
    LAST_GALLERY=1 #flag à 1 : c'est la dernière gallerie
    create_gallery $DESTINATION_FILE $GALLERY_SIZE "$PICTURE_LIST" $GALLERY_PICTURE_SIZE $XYZ $LAST_GALLERY
    #echo -e -n $PICTURE_LIST
}

#create_gallery $GALLERY_DESTINATION_DIR/galerie.html $GALLERY_SIZE "image1.png image2.png image3.png" $GALLERY_PICTURE_SIZE
search_pictures | tee -a result.log
exit

