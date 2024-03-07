#!/usr/bin/bash
SEARCH_PATH="/usr"
PICTURE_MIN_SIZE="10k"
GALLERY_SIZE=25
GALLERY_PICTURE_SIZE=200
PICTURE_TYPE="png"
GALLERY_DESTINATION_DIR="."

while getopts ":a:b:c:d:e:f:h:" opt; do
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
    echo "L'option -$OPTARG est invalide" >&2
    exit 1
    ;;

    \?)
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
    local HTML_PICTURE_LIST=""
    #créer une chaîne qui contient les balises HTML image dans la limite de la taille de la galerie
    for picture in $PICTURE_LIST; do
        HTML_PICTURE_LIST="$HTML_PICTURE_LIST <img src=\"$picture\" width=\"$PICTURE_SIZE\">"
    done
    cat <<EOF > $1
<!DOCTYPE html>
<html>
<head>
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
            create_gallery $DESTINATION_FILE $GALLERY_SIZE "$PICTURE_LIST" $GALLERY_PICTURE_SIZE
            XYZ=$(printf "%03d" $(expr $XYZ + 1)) #traitement numérique
            #echo $XYZ
            COMPTEUR=0
            PICTURE_LIST=""
        fi
        COMPTEUR=$(($COMPTEUR+1)) #traitement numérique
    done
    DESTINATION_FILE=$GALLERY_DESTINATION_DIR/gal${XYZ}.html #le dernier fichier
    create_gallery $DESTINATION_FILE $GALLERY_SIZE "$PICTURE_LIST" $GALLERY_PICTURE_SIZE
    #echo -e -n $PICTURE_LIST
}

#create_gallery $GALLERY_DESTINATION_DIR/galerie.html $GALLERY_SIZE "image1.png image2.png image3.png" $GALLERY_PICTURE_SIZE
search_pictures | tee -a result.log
exit

