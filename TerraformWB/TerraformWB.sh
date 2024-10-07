#!/bin/bash

####################################### STATIC VARIABLES ########################################

# Text Color
WHITE="\033[0m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
GREEN="\033[0;32m"

# Infinte Loop
ALWAYS_TRUE=true

######################################### REQUIREMENTS ##########################################

echo '''
 _________  _______   ________  ________  ________  ________ ________  ________  _____ ______   ___       __   ________     
|\___   ___\\  ___ \ |\   __  \|\   __  \|\   __  \|\  _____\\   __  \|\   __  \|\   _ \  _   \|\  \     |\  \|\   __  \    
\|___ \  \_\ \   __/|\ \  \|\  \ \  \|\  \ \  \|\  \ \  \__/\ \  \|\  \ \  \|\  \ \  \\\__\ \  \ \  \    \ \  \ \  \|\ /_   
     \ \  \ \ \  \_|/_\ \   _  _\ \   _  _\ \   __  \ \   __\\ \  \\\  \ \   _  _\ \  \\|__| \  \ \  \  __\ \  \ \   __  \  
      \ \  \ \ \  \_|\ \ \  \\  \\ \  \\  \\ \  \ \  \ \  \_| \ \  \\\  \ \  \\  \\ \  \    \ \  \ \  \|\__\_\  \ \  \|\  \ 
       \ \__\ \ \_______\ \__\\ _\\ \__\\ _\\ \__\ \__\ \__\   \ \_______\ \__\\ _\\ \__\    \ \__\ \____________\ \_______\
        \|__|  \|_______|\|__|\|__|\|__|\|__|\|__|\|__|\|__|    \|_______|\|__|\|__|\|__|     \|__|\|____________|\|_______|

TerraformWB is the equivalent of Jonmar's gCloudWB but uses Terraform to create and manage the underlying infrastructure rather than Google Cloud's Cloud SDK.
'''

# Check if the user executed the script correctly
while getopts ":a:" opt; do
    case $opt in
        a) action="$OPTARG"
        ;;
        \?) echo -e "${RED}[ERROR 1]${WHITE} Usage: ./TerraformWB.sh -a {apply|destroy}" && echo "" &&  exit 1
        ;;
        :) echo -e "${RED}[ERROR 2]${WHITE} Usage: ./TerraformWB.sh -a {apply|destroy}" && echo "" && exit 1
        ;;
    esac
done

# Check if the user provided only the required values when executing the script
if [ $OPTIND -ne 3 ]; 
then
    echo -e "${RED}[ERROR 3]${WHITE} Usage: ./TerraformWB.sh -a {apply|destroy}" && echo "" &&  exit 1
fi

echo "${2,,}"

if [[ ${2,,} == "apply" ]] || [[ ${2,,} == "destroy" ]];
then 
    echo ""
else
    echo -e "${RED}[ERROR 4]${WHITE} Usage: ./TerraformWB.sh -a {apply|destroy}" && echo "" &&  exit 1
fi

########################################## TERRAFORM ############################################

#
read -p "$(echo -e ${YELLOW}[REQUIRED]${WHITE} Please enter the project ID of the project where you want to deploy the resources in:) " ProjectID

#
sed -i 's/PROJECT_ID/'"$ProjectID"'/g' ./test/test.tf

#
terraform init

echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Initialized."
echo "" && echo -e "${YELLOW}[WARNING]${WHITE} Validating keys." && echo ""

#
if terraform test;
then

    echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Keys are valid." && echo ""

    #
    if [[ ${2,,} == "apply" ]];
    then
        terraform apply --auto-approve
    else
        terraform destroy --auto-approve
        rm -r .terraform/*
    fi

    #
    sed -i 's/'"$ProjectID"'/PROJECT_ID/g' ./test/test.tf
    echo "" && echo -e "${GREEN}[SUCCESS]${WHITE} Yay it worked!" && exit 0

else

    #
    sed -i 's/'"$ProjectID"'/PROJECT_ID/g' ./test/test.tf
    echo "" && echo -e "${RED}[ERROR 5]${WHITE} Terraform test failed." && echo "" && exit 1

fi 
