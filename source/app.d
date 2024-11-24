import std.stdio;

 /*
     // ANSI escape code for blue text
    string blue = "\033[34m";
    string reset = "\033[0m";  // Reset color to default

    // Check if the correct number of arguments are passed
    if (args.length == 3 && args[1] == "-p") {
        string username = args[2];
        writeln(blue, "Welcome, ", username, "!", reset);
    } else {
        writeln("Usage: mycode -p <username>");
    }
 */

void main()
{

Params: REGEX , FILE/DIRECTORY

//pseudo code

if( file){
    //open file
    //read file
    //apply regex
    //print matches number line, number of matches, match, line content
}
else if(directory){
    //open directory
    //read files
    // recursively open directories 
    //
    //apply regex
    //print matches number line, number of matches, match, line content
}
else{
    //print error


}
