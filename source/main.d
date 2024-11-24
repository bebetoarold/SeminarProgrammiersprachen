
import std.stdio;
import std.array;
import std.file;
import std.path;
import std.exception;
import std.regex;
//import std.algorithm;
import std.string;

/** 
 * 
 * usage: searcher [OPTIONS] PATTERN [PATH ...]
-A,--after-context <arg> prints the given number of following lines for each match
-B,--before-context <arg> prints the given number of preceding lines for each match

-c,--color print with colors, highlighting the matched phrase in the output
-C,--context <arg> prints the number of preceding and following lines for each match. this is equivalent to setting --before-context and --after-context
-h,--hidden search hidden files and folders
--help  print this message
-i,--ignore-case search case insensitive
--no-heading prints a single line including the filenamefor each match, instead of grouping matches by file

--PATTERN: the regular expression to search for
--PATHS: the file or directory to search in 
 */


//functions block

void scanSubEntries(string entry){
    foreach(string subEntry; dirEntries(entry, SpanMode.breadth)){
        writeln("Sub Entry: ", subEntry);
        if(isFile(subEntry)){
            writeln("Sub Entry is a file: ", subEntry);
            writeln("No subdirectories to scan further");
        }
        else if(isDir(subEntry)){
            writeln("Sub Entry is a directory: ", subEntry);
            // recursively open directories and get its entries
            scanSubEntries(subEntry);
        }
        else{
            writeln("Sub Entry is invalid: ", subEntry);
        }
    }
}


// unit test block
unittest
{
    
}


void main(string[] args) {


    //Variable list:

    string after_context = "";
    string before_context = "";
    string context ="";
    string color = "";  
    bool hidden = false;
    bool ignore_case = false;
    bool no_heading = false;
    string pattern = "";
    string paths = "";

    string blue = "\033[34m";
    string red = "\033[31m";
    string green = "\033[32m";
    string reset = "\033[0m";  // Reset color to default




  
    //check number param  minimum 2
    if(args.length < 2){
        writeln("Usage: searcher [OPTIONS] --PATTERN PATTERN --PATHS [PATH ...]");
    }
    else{
        for(int i=0; i< args.length; i++){
            if(args[i] == "-A" || args[i] == "--after-context"){
                after_context = args[i+1];
            }
            else if(args[i] == "-B" || args[i] == "--before-context"){
                before_context = args[i+1];
            }
            else if(args[i] == "-C" || args[i] == "--context"){
                context = args[i+1];
            }
            else if(args[i] == "-c" || args[i] == "--color"){
                color = "\033[34m";
            }
            else if(args[i] == "-h" || args[i] == "--hidden"){
                hidden = true;
            }
            else if(args[i] == "-i" || args[i] == "--ignore-case"){
                ignore_case = true;
            }
            else if(args[i] == "--no-heading"){
                no_heading = true;
            }
            else if(args[i] == "--help"){
                writeln("usage: searcher [OPTIONS] PATTERN [PATH ...]");
                writeln("-A,--after-context <arg> prints the given number of following lines for each match");
                writeln("-B,--before-context <arg> prints the given number of preceding lines for each match");
                writeln("-c,--color print with colors, highlighting the matched phrase in the output");
                writeln("-C,--context <arg> prints the number of preceding and following lines for each match. this is equivalent to setting --before-context and --after-context");
                writeln("-h,--hidden search hidden files and folders");
                writeln("--help print this message");
                writeln("-i,--ignore-case search case insensitive");
                writeln("--no-heading prints a single line including the filenamefor each match, instead of grouping matches by file");
                writeln("--PATTERN: the regular expression to search for");
                writeln("--PATH: the file or directory to search in ");
            }
            else if(args[i] == "--PATTERN"){
                for(int j=i+1; j < args.length; j++){
                    
                    if(args[j] == "--PATHS"){
                        break;
                    }
                    else{
                        pattern =pattern~args[j];
                    }
                }
            }
            else if(args[i] == "--PATHS"){
                for(int j=i+1; j < args.length; j++){
                    paths = paths~"|"~args[j];
                }   
            }
        } 

    }

    //display the values
    writeln("After Context: ", after_context);
    writeln("Before Context: ", before_context);
    writeln("Context: ", context);
    writeln("Color: ", color);
    writeln("Hidden: ", hidden);
    writeln("Ignore Case: ", ignore_case);
    writeln("No Heading: ", no_heading);
    writeln("Pattern: ", pattern);
    writeln("Paths: ", paths);

    // check if pattern is empty and or path is emptys
    if(pattern == "" || paths == ""){
        writeln("Pattern and Path are required");
        writeln("Usage: searcher [OPTIONS] PATTERN [PATH ...]");
    }
    else{
        //check if path is a file or directory
        //if file
        //open file
        //read file
        //apply regex
        //print matches number line, number of matches, match, line content
        //else if directory
        //open directory
        //read files
        // recursively open directories 
        //
        //apply regex
        //print matches number line, number of matches, match, line content
        //else
        //print error

        /*
        * handling the separation of the paths in the paths string in the case of multiple paths
        */
      //  string tempPaths=strip(paths);
        string[] pathList = strip(paths).split("|");

        /*
        * handling the PATTERN
        */
       //string tempPattern = std.string.strip(pattern);
        auto regex = regex(strip(pattern));
        writeln("Pattern in regex: ", regex);

         /*
        * checking if the path is a file or a directory
        */

        foreach(path; pathList){
            writeln("Path being handled:",path);
            if(isValidPath(path) && path != ""){
                writeln("Path is valid: ",path);

                if(exists(path)){
                    writeln("Path exists: ", path);
                    if(isDir(path)){
                        writeln("Path is a directory: ", path);
                        foreach(string entry; dirEntries(path, SpanMode.breadth)){
                            writeln("Entry: ", entry);

                            

                            if(isFile(entry)){
                                writeln("Entry is a file: ", entry);

                                //open file and search for pattern
                                auto file = File(entry, "r");
                                string line;
                                int lineNumber = 0;
                                while(!file.eof()){
                                    lineNumber++;
                                    line = file.readln();

                                    auto firstMatch = matchFirst(line, regex);
                                    //assert(!firstMatch.empty, "No match found");
                                    if(!firstMatch.empty){
                                        writeln(green,"Match found in line: ", lineNumber);
                                        writeln(green,"Match: ", firstMatch.hit);
                                        writeln(green,"Line content: ", line);
                                        writeln(reset);
                                    }
                                    
                                }
                        
                            }
                            else if(isDir(entry)){
                                writeln(blue,"Entry is a directory: ", entry);
                                // recursively open directories and get its entries
                                //scanSubEntries(entry);
                               // writeln(blue,"finished scanning subdirectories",path);
                                writeln(reset);

                            }
                            else{
                                writeln(red,"Entry is invalid: ", entry);
                                writeln(reset);

                            }
                        }
                    }
                    else if(isFile(path)){
                        writeln("Path is a file: ", path);
                       
                    }
                    else{
                        writeln(red,"Path is invalid: ", path);
                        writeln(reset);
                    }
                }
                else{
                    writeln(red,"Path does not exist: ", path);
                    writeln(reset);
                }

            }
            else{
                writeln(red,"Path is invalid: ", path);
                writeln(reset);
            }
        }

    


    }


    

}