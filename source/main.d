
import std.stdio;
import std.array;
import std.file;
import std.path;
import std.exception;
import std.regex;
import std.string;
import std.conv;
import core.stdc.stdlib;
import std.datetime;
import std.utf;
import std.parallelism;


/** @brief PARALLEL SEARCHER
 * @brief PARALLEL SEARCHER
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


string printHeading(bool color){
    string blue = "\033[34m";
    string reset = "\033[0m";  // Reset color to default
    string res="";

    if(!color){
        res=("SUMMARY---------------");
    }
    else{
       res= blue~("SUMMARY---------------");
    }
    return res;
}

string printTailing(bool color){
    string blue = "\033[34m";
    string reset = "\033[0m";  // Reset color to default
    string res="";

    if(!color){
        res=("END SUMMARY---------------");
    }
    else{
       res= blue~("END SUMMARY---------------");
    }
    return res; 
}

string reding(Captures!(string) m){
    string red = "\033[31m";
    string reset = "\033[0m";  // Reset color to default
    return red~m.hit~reset;
  
}

string highlightMatch(string line, Regex!char regex, bool color){
    string blue = "\033[34m";
    string red = "\033[31m";
    string green = "\033[32m";
    
    string res="";

    if(!color){
        res=line;
    }
    else{
        //somehow to review the replaceAll function TODO
        res= replaceAll!(reding)(line, regex);
    }
    return res;
}

void  readFile( File file, string entry, Regex!char regex, int after_context, int before_context, int context, bool no_heading, bool color){

                            string blue = "\033[34m";
                            string red = "\033[31m";
                            string green = "\033[32m";
                            string reset = "\033[0m";  // Reset color to default


                                string line;
                                int lineNumber = 0;
                               // string [int] preArray=null;
                               // string [int] postArray=null;
                                int numberMatchedPatternPerFile=0;
                                string [int] arrayMatchedLinesToLineNumber;
                                string [int] keeperArray=null; //holds the whole file content at the end
                            
                            //checking encoding and others
                            try{
                            
                                 while(!file.eof()){
                                    lineNumber++;
                                    line = file.readln();
                                    keeperArray[lineNumber]=line;

                                    auto allMatches=matchAll(line, regex);
                                    if(!allMatches.empty){
                                         //counting number of pattern matched in this line and incrementing counter for the file 
                                        
                                        int count=0;
                                        foreach (_; allMatches) {
                                                count++;
                                            }
                                        numberMatchedPatternPerFile+=count;
                                        arrayMatchedLinesToLineNumber[lineNumber]=line;
                                
                                    }

                                }


                                if(numberMatchedPatternPerFile!=0){
                                    //check if no_heading is set
                                    if(no_heading){
                                        
                                       writeln(printHeading(color),entry,"-------------(",numberMatchedPatternPerFile,")");
                                       writeln(reset);
                            

                                        foreach (kv; parallel(arrayMatchedLinesToLineNumber.byPair,100))
                                        {   
                                             //fetching the context of the matched lines
                                            if(before_context)
                                            {
                                                for(int i=1; i<=before_context; i++){
                                                    if(kv.key-i>0){
                                                        writeln("Before Context of ->", red~entry~reset,":"~green,kv.key-i,reset~":", highlightMatch(keeperArray[to!int(kv.key-i)], regex, color));
                                                    }
                                                }
                                            }
                                            writeln(red~entry~reset,":"~green,kv.key,reset~":",highlightMatch(kv.value, regex, color));
                                                
                                            //fetching the context of the matched lines
                                            if(after_context){
                                                for(int i=1; i<=after_context; i++){
                                                    if(kv.key+i<=keeperArray.length){
                                                        writeln("After Context of ->", red~entry~reset,":"~green,kv.key+i,reset~":", highlightMatch(keeperArray[to!int(kv.key+i)], regex, color));
                                                    }
                                                }
                                            }
                                       
                                        writeln("-------------------------------------------------");
                                        }
                                        writeln(printTailing(color),entry);
                                        writeln(reset);
                                    }
                                    else{
                                         writeln(red~printHeading(color),entry,"-------------(",numberMatchedPatternPerFile,")");
                                        writeln(reset);

                                        foreach (kv; parallel(arrayMatchedLinesToLineNumber.byPair,100))
                                        {
                                             //fetching the context of the matched lines
                                            if(before_context){
                                                for(int i=1; i<=before_context; i++){
                                                    if(kv.key-i>0){
                                                        writeln("Before Context:-> "~green,kv.key-i,reset~":",highlightMatch(keeperArray[to!int(kv.key-i)], regex, color));
                                                    }
                                                }
                                            }

                                            writeln(green~"",kv.key,""~reset,":",highlightMatch(kv.value, regex, color));
                                            
                                             //fetching the context of the matched lines
                                            if(after_context){
                                                for(int i=1; i<=after_context; i++){
                                                    if(kv.key+i<=keeperArray.length){
                                                        writeln("After Context:-> "~green,kv.key+i,reset~":",highlightMatch(keeperArray[to!int(kv.key+i)], regex, color));
                                                    }
                                                }
                                            }

                                        writeln("-------------------------------------------------");
                                        }
                                        writeln(printTailing(color),entry);
                                        writeln(reset);
                                    }


                                }else{
                                    writeln(green, "No match found in this file for::",entry);
                                    writeln(reset);
                                }
                            }catch(UTFException){
                                writeln(red,"File encoding not supported::",entry);
                                writeln(reset);
                            }catch(Exception e){
                                writeln(red,"Error reading file ::",entry);
                                writeln(reset);
                            }
}



// unit test block
unittest
{
    
}


void main(string[] args) {

    auto start = Clock.currTime; // Record start time

    //Variable list:

    int after_context;
    int before_context;
    int context;
    bool color = false;  
    bool hidden = false;
    bool ignore_case = false;
    string flags = "";
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

             after_context= to!int(args[i+1]);
               
            }
            else if(args[i] == "-B" || args[i] == "--before-context"){
               before_context= to!int(args[i+1]);
            }   
            else if(args[i] == "-C" || args[i] == "--context"){
                context= to!int(args[i+1]);
                before_context= to!int(args[i+1]);
                after_context= to!int(args[i+1]);
            }
            else if(args[i] == "-c" || args[i] == "--color"){
                color = true;
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
                writeln("usage(PARALLEL): searcher [OPTIONS] PATTERN [PATH ...]");
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
                exit(0);
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
           // else{
           //      writeln("usage: searcher --help");
           //      exit(0);
            //}
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

        /*
        * handling the separation of the paths in the paths string in the case of multiple paths
        */
      //  string tempPaths=strip(paths);
        string[] pathList = strip(paths).split("|");

        /*
        * handling the PATTERN and case insensitive flag
        */
       //string tempPattern = std.string.strip(pattern);
        if(ignore_case){
            flags = "i";
        }
        auto regex = regex(strip(pattern), flags);
        writeln("Pattern in regex: ", regex);

         /*
        * checking if the path is a file or a directory
        */

        foreach(path; parallel(pathList,1)){
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

                                if(hidden){
                                   if( baseName(entry).startsWith("."))
                                   {
                                     writeln("Hidden file: ", entry);
                                     readFile(File(entry, "r"), entry, regex, after_context, before_context, context, no_heading,color);

                                    }else
                                    {
                                        continue;
                                    }

                                }else{
                                    readFile(File(entry, "r"), entry, regex, after_context, before_context, context, no_heading,color);
                                }

                            }
                            else if(isDir(entry)){
                                writeln(blue,"Entry is a directory: ", entry);
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
                         if(hidden){
                            if( baseName(path).startsWith("."))
                            {
                                writeln("Hidden file: ", path);
                                readFile(File(path, "r"), path, regex, after_context, before_context, context, no_heading,color);

                            }else
                            {
                                continue;
                            }

                            }
                            else if(!hidden){
                                readFile(File(path, "r"), path, regex, after_context, before_context, context, no_heading,color);
                            }
                            else{
                                writeln(green,"No match found in this file:  ", path);
                            }
                       
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
     auto end = Clock.currTime;   // Record end time
    auto duration = end - start; // Calculate duration
    writeln("Execution time: ", duration.total!"msecs", " milliseconds");
    }
    
}