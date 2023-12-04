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
# Version       0.2 (20231128)
# Version       0.3 (20231201)

# Put the file in the folder containing the TMs and run as 
# bash pisa-fix-trend-tmx.sh .

# Set the path to the folder containing the TMX or zipped TMX files
folder_path="$1"
if [ -z "$folder_path" ]; then
    echo "No folder provided"
    exit 2
fi

# Find all zip files and extract TMX files into their respective subfolders
find "$folder_path" -type f -name "*.zip" -exec sh -c '
    zip_path="{}"
    base_folder="$(dirname "$zip_path")"
    output_folder="$base_folder"
    unzip -j -o "$zip_path" "*.tmx" -d "$output_folder" &&
    echo "Extracted TMX file from $zip_path to $output_folder"
    rm "$zip_path"
' \;

# Loop through each TMX file in the folder
for file in "$folder_path"/*.tmx; do
    # Check if the file exists
    if [ -e "$file" ]; then
        # Remove "xlf" from the filename
        new_name=$(echo "$file" | sed 's/\.xlf//')
        if [ "$new_name" != "$file" ]; then
            mv "$file" "$new_name"
            file="${new_name}"
        fi
        # Generate the output filenames with "_fix" and "_paragraph" before the period
        output_file="${file%.*}_fix.${file##*.}"
        output_resegmented_file="${file%.*}_paragraph.${file##*.}"
        output_renumbered_file="${file%.*}_renumbered.${file##*.}"

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
    ## Remove leading and trailing paired tags
            s~(<seg>[\s\n]*)&lt;([^&]+)&gt;\s*([^&<]+)\s*&lt;/\2&gt([\s\n]*</seg>);~$1$3$4~g;
    ## Remove double spaces
            s/(<seg>.*?<\/seg>)/$1 =~ s|[ \x{00A0}]+| |gr/ge;
    ## Fixes for the updated source files
            s/Select from the pull\-down menus to answer the question\./Select from the drop\-down menus to answer the question\./g;
            s/Find the range of value that the length of the third side of the triangle can take\./Find the range of values that the length of the third side of the triangle can take\./g;
            s/Type and click on a choice to answer the question\./Type and click on your choice to answer the question\./g;
            s/Click on (&lt;g\d+&gt;)Yes(&lt;\/g\d+&gt;) or (&lt;g\d+&gt;)No(&lt;\/g\d+&gt;) for each of the following balls\./Click on either $1Yes$2 or $3No$4 for each of the following balls\./g;
            s/Refer to &quot;Fan Merchandise&quot; on the right\./Refer to &quot;Z\x{0027}s Fan Merchandise&quot; on the right\./g;
            s/Step (\d+) is performed before Step (\d+)\./The operation in Step $1 is performed before the operation in Step $2\./g;
            s/It increases and decreases<\/seg>/It increases and decreases.\<\/seg>/g;
            s/It strictly increases<\/seg>/It strictly increases\.<\/seg>/g;
            s/It strictly decreases<\/seg>/It strictly decreases\.<\/seg>/g;
            s/It stays the same<\/seg>/It stays the same\.<\/seg>/g;
            s/Each large spike on the graph represents one beat\./Each large spike on the graph represents one beat, and time is measured in seconds\./g;
            s/84\+/85\+/g;
            s/65+/66\+/g;
                        s/The honey is put into a large barrel while it is being harvested\./The honey is put into large barrels while it is being harvested\./g;
            s/How many of the honeycombs were completely full and how many were one\-third full\?/How many of the honeycombs were completely full and how many were about one\-third full\?/g;
            s/The table below summarizes the students’ responses by grade level\./The table below summarises the students’ responses by grade level\./g;
            s/A total of 160 students responded\./All 160 students that were asked responded\./g;
            s/Zedland has two regions: Region A and Region B\./Zedland has exactly two regions: Region A and Region B\./g;
            s/Dave says that Region B has more square kilometers of lowlands than Region A\./Dave says that Region B has more square kilometres of lowlands than Region A\./g;
            s/Practice using the paint calculator by entering the following information:/Practise using the paint calculator by entering the following information:/g;
            s/Based on the formula, how much more paint will Steve need if he chooses the blue paint instead of the green paint\?/Based on the formula, how many times as much paint will Steve need if he chooses the blue paint instead of the green paint\?/g;
            s/9 times more/9 times as much/g;
            s/6 times more/6 times as much/g;
            s/3 times more/3 times as much/g;
            s/2 times more/2 times as much/g;
            s/Assume Maria rides at the same constant speed as she has previously on the path\./Assume Maria rides at the same constant speed as she has previously on the path, and that the battery discharges at a constant rate\./g;
            s/On a sunny day, the solar panel charges the battery at a rate of 60 watts per hour\./On a sunny day, the solar panel charges the battery at a rate of 60 watt\-hours per hour\./g;
            s/Click on one or more boxes to answer the question\./Click on two boxes to answer the question\./g;
            s/The employees also voted on the colors to use in the final design\./The employees also voted on the colours to use in the final design\./g;
            s/Tyre diametre: (\d+) mm/Tyre Diameter: $1 mm/g;
            s/The diametre of each tyre/The diameter of each tyre/g;
            s/Look at the (&lt;g\d+&gt;)tab(&lt;\/g\d+&gt;)\, titled “Angles of Vision\,” on the right\./Look at the $1tab$2 titled “Angles of Vision” on the right\./g;
            s/The equation of the line is (&lt;g\d+&gt;)a(&lt;\/g\d+&gt;) = 115 \– (&lt;g\d+&gt;)s(&lt;\/g\d+&gt;)\, where (&lt;g\d+&gt;)a(&lt;\/g\d+&gt;) is the angle\, in degrees\, and (&lt;g\d+&gt;)s(&lt;\/g\d+&gt;) is the speed of the vehicle\, in kilometres per hour\./The equation of the line is $1a$2&#x00A0;\=&#x00A0;115&#x00A0;\–&#x00A0;$3s$4\, where $5a$6 is the angle\, in degrees\, and $7s$8 is the speed of the vehicle\, in kilometres per hour\./g;
            s/<seg>&lt;br class=&quot;clear(Both)?&quot; \/&gt;/<seg>/g;
            s/&lt;\/g\d+&gt;&lt;br\/&gt; Question<\/seg>/<\/seg>/g;
        ' < "$file" > "${folder_path}/${output_file}"
    
    ## Create a new TMX file with "paragraph" segtype declared.
        sed 's/segtype="sentence"/segtype="paragraph"/' "${folder_path}/${output_file}" > "${folder_path}/${output_resegmented_file}"
    ## Replace the fixed TMX with its copy but with "paragraph" segtype
        mv -f "${folder_path}/${output_resegmented_file}" "${folder_path}/${output_file}"

    ## Renumber tags in the fixed TMX with "paragraph" segtype and create a new file
        if [ -f "${folder_path}/${output_file}" ]; then
            perl -pe '
                s/&lt;g(\d+)&gt;/"&lt;g" . ($1 + 1) . "&gt;"/ge;
                s/&lt;\/g(\d+)&gt;/"&lt;\/g" . ($1 + 1) . "&gt;"/ge;
                s/<seg>&lt;g\d+&gt;/<seg>/g;
                s/&lt;\/?g\d+&gt;<\/seg>/<\/seg>/g' "${folder_path}/${output_file}" > "${folder_path}/${output_renumbered_file}"
        fi
    ## Make a copy of the existing old TMX file with "paragraph" segtype declared.
        if [ "$(grep 'segtype="sentence"' $file)" ]; then
#            mkdir -p "${folder_path}/paragraph"
            sed 's/segtype="sentence"/segtype="paragraph"/' "${folder_path}/${file}" > "${folder_path}/${output_resegmented_file}"
        fi

        echo "Processed: $file -> $output_file"
    fi
done

# Zip tmx files into individual zips
for file in "${folder_path}"/*.tmx; do
    if [ -f "${file}" ]; then
        zip -j -u "${file}.zip" "${file}"
        rm "${folder_path}/${file}"
    fi
done
