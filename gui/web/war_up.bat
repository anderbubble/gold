@echo off

REM -----------------------------------------------------------------
REM -- This batch file will compile all Java source files in the
REM -- current directory, directing the Java compiler to place the
REM -- resulting class files into a destination directory.
REM -----------------------------------------------------------------




REM -----------------------------------------------------------------
REM -- This is the directory specific bit
REM -----------------------------------------------------------------

 
set src=..\src\gold\web\client
set root=WEB-INF\classes

set package=gold\web\client
set jsproot=web
if not exist %root% mkdir %root%





REM -----------------------------------------------------------------
REM -- Now we can enter the main part of this batch file
REM -----------------------------------------------------------------

echo.
echo.
echo ******************************************************
echo **
echo ** Compiling : %package%
echo **
echo ******************************************************
echo.

set destination=%root%\%package%


REM -----------------------------------------------------------------
REM -- The compiler
REM -----------------------------------------------------------------

if exist %destination%\*.class erase %destination%\*.class

C:\j2sdk1.4.1_04\bin\javac  -d %root% -classpath .;C:\Gold\gold_gui\web\WEB-INF\lib\gold.jar;C:\Gold\gold_gui\web\WEB-INF\lib\jdom.jar;C:\jakarta-tomcat-4.1.27\common\lib\servlet.jar %src%\*.java



REM -----------------------------------------------------------------
REM -- make the war
REM -----------------------------------------------------------------

C:\j2sdk1.4.1_04\bin\jar cvf gold.war .

REM -----------------------------------------------------------------
REM -- Finish
REM -----------------------------------------------------------------



REM copy gold.war C:\jakarta-tomcat-4.1.27\webapps\
REM del gold.war

:END
echo.
echo ** Finished
echo.


