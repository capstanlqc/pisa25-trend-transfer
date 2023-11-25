#!/bin/bash

# Description:  This script needs to be run in a folder containg TMX files.
#               It will create a subfolder "fix" and output the results there.
#               If the original TMX had sentence segmentation, it will be output
#               to two files with the only difference being
#               `segtype="sentence"` vs `segtype="paragraph"` in the header.
# 
# Author:       Kos Ivantsov
# Created:      2023-11-25
# Version       0.1 (20231125)


# Set the path to the folder containing the TMX files
folder_path="$1"
if [ -z "$folder_path" ]; then
    echo "No folder provided"
    exit 2
fi
if [ ! -d "${folder_path}/fix" ]; then
    mkdir "${folder_path}/fix"
fi
# Loop through each TMX file in the folder
for file in "$folder_path"/*.tmx; do
    # Check if the file exists
    if [ -e "$file" ]; then
        # Generate the output filenames with "_fix" and "_paragraph" before the period
        output_file="${file%.*}_fix.${file##*.}"
        output_resegmented_file="${file%.*}_paragraph.${file##*.}"

    # Use perl with explicit encoding handling
        perl -CSDA -Mutf8 -pe '
            BEGIN {
                binmode(STDOUT, ":utf8");
                binmode(STDIN, ":encoding(UTF-8)");
            }
    ## Replace digits between <sub> and <sup> tags with their Unicode counterparts
            s/&lt;sub&gt;1&lt;\/sub&gt;/₁/g;
            s/&lt;sub&gt;2&lt;\/sub&gt;/₂/g;
            s/&lt;sub&gt;3&lt;\/sub&gt;/₃/g;
            s/&lt;sub&gt;4&lt;\/sub&gt;/₄/g;
            s/&lt;sub&gt;5&lt;\/sub&gt;/₅/g;
            s/&lt;sub&gt;6&lt;\/sub&gt;/₆/g;
            s/&lt;sub&gt;7&lt;\/sub&gt;/₇/g;
            s/&lt;sub&gt;8&lt;\/sub&gt;/₈/g;
            s/&lt;sub&gt;9&lt;\/sub&gt;/₉/g;
            s/&lt;sub&gt;0&lt;\/sub&gt;/₀/g;
            s/&lt;sup&gt;1&lt;\/sup&gt;/¹/g;
            s/&lt;sup&gt;2&lt;\/sup&gt;/²/g;
            s/&lt;sup&gt;3&lt;\/sup&gt;/³/g;
            s/&lt;sup&gt;4&lt;\/sup&gt;/⁴/g;
            s/&lt;sup&gt;5&lt;\/sup&gt;/⁵/g;
            s/&lt;sup&gt;6&lt;\/sup&gt;/⁶/g;
            s/&lt;sup&gt;7&lt;\/sup&gt;/⁷/g;
            s/&lt;sup&gt;8&lt;\/sup&gt;/⁸/g;
            s/&lt;sup&gt;9&lt;\/sup&gt;/⁹/g;
            s/&lt;sup&gt;0&lt;\/sup&gt;/⁰/g;
    ## Remove space(s) in <br />
            s/&lt;br\s*\/&gt;/&lt;br\/&gt;/g;
    ## Remove <br/> right in the beginning and the end of a segment
            s/<seg>((&lt;br\s*\/&gt;)*\s*)*/<seg>/g;
            s/((&lt;br\s*\/&gt;)*\s*)*<\/seg>/<\/seg>/g;
    ## Remove a series of <br/>
            s/(&lt;br\/&gt;\s*){2,}/ /g;
    ## Replace html tags with <gNUM> based tags. Each pair gets a seq. number, restarts at each segment
            BEGIN{$count=0;}
            s/&lt;([biu]|em|strong|span|sub|sup|mark|small|ins|del|code|cite|abbr|acronym|a)&gt;(.*?)&lt;\/\1&gt;/"&lt;g" . ++$count . "&gt;$2&lt;\/g$count&gt;"/ge;
            $count=0 if eol;
    ## Remove leading and trailing tags
            s/<seg>\s*&lt;g\d+&gt;\s*/<seg>/g;
            s/\s*&lt;\/g\d+&gt;\s*<\/seg>/<\/seg>/g;
    ## Remove double spaces
            s/(<seg>.*?<\/seg>)/$1 =~ s|[ \x{00A0}]+| |gr/ge;
        ' < "$file" > "${folder_path}/fix/${output_file}"
    
    ## Create a new TMX file with "paragraph" segtype declared.
        sed 's/segtype="sentence"/segtype="paragraph"/' "${folder_path}/fix/${output_file}" > "${folder_path}/fix/${output_resegmented_file}"

        echo "Processed: $file -> $output_file"
    fi
done
