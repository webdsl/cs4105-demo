# cs4105-demo

### IDE build

- Get an Eclipse with latest WebDSL pluging pre-installed at
http://buildfarm.metaborg.org/view/WebDSL/job/webdsl-eclipsegen/lastSuccessfulBuild/artifact/dist/eclipse/ or use updatesite http://webdsl.org/update to install plugin.
- Import the project into your Eclipse workspace.
- Right-click the project and select 'Convert to a WebDSL Project', click 'Finish' to use default settings.
- Build the project with ctrl+alt+b or cmd+alt+b, this will also deploy and run the application on Tomcat.
- Open the 'Servers' view to manage the Tomcat instance.

### Command-line build

- Download latest WebDSL compiler jar: http://webdsl-test.ewi.tudelft.nl/compiler/webdsl.zip
- Extract the zip file. 
- Add the webdsl/bin directory to your path, or use the full path, and run in the project directory:
`webdsl run cs4105-demo`