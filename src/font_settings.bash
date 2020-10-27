function download_fonts() {
    local font_download_url=$1
    local font_name=$(echo $font_download_url | sed -e "s@.*\/@@g" -e "s@\..*@@g")
    echo $font_name
    wget $font_download_url -o ~/Downloads/downloaded.zip
    mkdir ~/Downloads/$font_name
    unzip -d ~/Downloads/$font_name/ ~/Downloads/downloaded.zip
    rm ~/Downloads/downloaded.zip
    cp ~/Downloads/$font_name/ttf/*.ttf ~/.local/share/fonts/
}

function main() {
    local font_urls=(
        "https://github.com/microsoft/cascadia-code/releases/download/v2009.22/CascadiaCode-2009.22.zip"
        "https://github-production-release-asset-2e65be.s3.amazonaws.com/26500787/420bf680-acc0-11ea-83ab-8ec41c29651d?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIWNJYAX4CSVEH53A%2F20201027%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20201027T024540Z&X-Amz-Expires=300&X-Amz-Signature=a9b80bfc9a0ae2bd50857b932036811fca01d859239f7c0aca4b31521c457c56&X-Amz-SignedHeaders=host&actor_id=0&key_id=0&repo_id=26500787&response-content-disposition=attachment%3B%20filename%3DFira_Code_v5.2.zip&response-content-type=application%2Foctet-stream"
    )

    for url in $font_urls; do
        download_fonts $url
    done
}

main
