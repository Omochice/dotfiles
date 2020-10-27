function download_fonts() {
    local font_name=$1
    local font_download_url=$2
    echo "font name is $font_name"
    echo "url is $font_download_url"
    echo 
    wget $font_download_url -O - > ~/Downloads/downloaded.zip # /dev/null
    [[ -e ~/Downloads/$font_neme ]] && rm -rf ~/Downloads/$font_name
    mkdir ~/Downloads/$font_name
    unzip -d ~/Downloads/$font_name ~/Downloads/downloaded.zip
    rm ~/Downloads/downloaded.zip
    cp ~/Downloads/$font_name/ttf/*.ttf ~/.local/share/fonts/
}

function main() {
    local font_urls='[
    { 
        "name": "CascadiaCode",
        "url": "https://github.com/microsoft/cascadia-code/releases/download/v2009.22/CascadiaCode-2009.22.zip"
    },
    {
        "name": "FiraCode",
        "url": "https://github.com/tonsky/FiraCode/releases/download/5.2/Fira_Code_v5.2.zip"
    }
]'

    local len=$(echo $font_urls | jq length)
    for i in $(seq 0 $((len - 1))); do
        local entry=$(echo $font_urls | jq .[$i])
        local font_name=$(echo $entry | jq -r .name)
        local url=$(echo $entry | jq -r .url)
        download_fonts $font_name $url
    done
}

main
