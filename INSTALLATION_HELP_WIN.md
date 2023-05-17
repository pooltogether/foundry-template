# Installing Software Dependencies on Windows

You may encounter issues installing the following software packages on Windows since they are primarily build for Unix-like operating systems. The following is a short guide to help you get up and running on Windows.

## Prerequisites

1. Make sure you have [git bash](https://gitforwindows.org/) installed. We will need to use this or a similar environment to run all local scripts.
2. Install [chocolatey](https://chocolatey.org/install) (Windows package manager that makes it easier to install **lcov**)

## Installing Foundry

1. Open a **git bash** terminal and run: `curl -L https://foundry.paradigm.xyz | bash
` or follow the instructions [here](https://book.getfoundry.sh/getting-started/installation).

## Installing direnv

1. Install the appropriate .exe for your machine from [direnv releases v2.32.0](https://github.com/direnv/direnv/releases/tag/v2.32.0) (v2.32.1 & v2.32.2 may not work on windows)
2. Follow the remaining steps on [this guide](https://gist.github.com/rmtuckerphx/4ace28c1605300462340ffa7b7001c6d)
3. You should now be able to use **direnv** in a **git bash** terminal!

## Installing lcov

1. Open Windows Powershell in administrator mode.
2. Run `choco install lcov` or follow the instructions [here](https://community.chocolatey.org/packages/lcov)
3. Add the install directory to your PATH variable (default bin is located at: `C:\ProgramData\chocolatey\lib\lcov\tools\bin`)

## Enabling bash commands in NPM scripts

After installing all of these packages you may still not be able to run some of the NPM scripts in this repo (ex. `npm run coverage`) until you enable to use of **git bash** for NPM.

### Enable **git bash** for NPM:

`npm config set script-shell bash`

### Disable **git bash** for NPM:

`npm config delete script-shell`

*(You only need to run this for when you want to go back to the default shell script for NPM.)*

## ***Important!***

Make sure to close and restart your **git bash** terminal after each installation or PATH addition to test the commands. If you do not restart your terminal, the command may not be found.